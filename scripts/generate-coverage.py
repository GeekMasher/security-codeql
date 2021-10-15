from ast import parse
import os
import json
import argparse
import subprocess

parser = argparse.ArgumentParser("GenerateCoverage")
parser.add_argument("-l", "--language")

parser.add_argument("-o", "--output")
parser.add_argument("--disable-cache", action="store_true")
parser.add_argument("--output-suite")

arguments = parser.parse_args()

here = os.getcwd()
codeql_folder = "codeql"

language_display = {
    "cpp": "C / CPP",
    "csharp": "CSharp",
    "java": "Java",
    "javascript": "JavaScript / TypeScript",
    "python": "Python",
}
default_suite_order = [
    "default",
    "extended",
    "quality",
    "local-variants",
    "super-extended",
]
default_suites = {
    "default": {
        "name": "Default Query Suite",
        "path": "{language}-code-scanning.qls",
        "type": "builtin",
    },
    "extended": {
        "name": "Security Extended Suite",
        "path": "{language}-security-extended.qls",
        "type": "builtin",
    },
    "quality": {
        "name": "Security and Quality Extended Suite",
        "path": "{language}-security-and-quality.qls",
        "type": "builtin",
    },
    "local-variants": {
        "name": "Security Extended with local variants enabled",
        "path": "{language}/suites/codeql-{language}-local.qls",
    },
    "super-extended": {
        "name": "Security Extended with Experimental and Custom Queries Suite",
        "path": "{language}/suites/codeql-{language}.qls",
    },
}


def getFormattedString(input: str, **data: dict):
    return input.format(**data)


def createSuitesTable(suites: dict, language: str):
    RETVAL = ""
    RETVAL += "| Name | Queries Count | Description | Path |\n"
    RETVAL += "| :--- | :---- | :--- | :--- |\n"

    # for suite, queries in suites.items():
    for suite in default_suite_order:
        queries = suites.get(suite)
        if not queries:
            continue

        data = default_suites.get(suite)
        name = data.get("name")

        path = getFormattedString(data.get("path"), language=language)

        if data.get("type") == "builtin":
            path = path.replace(".qls", "")
            path = path.replace(language + "-", "", 1)
        else:
            path = f"GeekMasher/security-queries/{path}@main"

        RETVAL += f"| `{suite}` | {len(queries)} | {name} | `{path}` |\n"

    return RETVAL


def createQueryTable(suites: dict, language: str):
    full_list = []
    RETVAL = ""
    RETVAL += "| Name | Severity | Path |\n"
    RETVAL += "| :--- | :------- | :--- |\n"

    # for suite, queries in suites.items():
    for suite in default_suite_order:
        queries = suites.get(suite)
        if not queries:
            continue
        for query in queries:
            if query.startswith("codeql"):
                continue
            if query in full_list:
                continue

            query_name = "Unknown"
            query_severity = "Unknown"
            query_severity_scrore = "1.0"

            with open(query, "r") as handle:
                for line in handle:
                    if line.startswith(" * @name"):
                        query_name = line.replace(" * @name ", "").strip()
                    if line.startswith(" * @sub-severity"):
                        query_severity = line.replace(" * @sub-severity ", "").strip()
                    if line.startswith(" * @security-severity"):
                        query_severity_scrore = line.replace(
                            " * @security-severity ", ""
                        ).strip()

            RETVAL += f"| `{query_name}` | {query_severity.title()} / {query_severity_scrore} | `{query}` |\n"

            full_list.append(query)

    return RETVAL


def createMarkdown(
    markdown_path: str, content: str, placeholder: str = "<!-- AUTOMATION -->"
):
    with open(markdown_path, "r") as handle:
        file_data = handle.read()

    start_location = file_data.index(placeholder) + len(placeholder)
    end_location = file_data.index(placeholder, start_location)

    print("Inserting data between: {} <-> {}".format(start_location, end_location))

    new_data = (
        file_data[:start_location] + "\n" + content + "\n\n" + file_data[end_location:]
    )

    with open(markdown_path, "w") as handle:
        handle.write(new_data)


def buildQueries(language: str):
    suites = {}
    for suite, suite_data in default_suites.items():
        suite_path = getFormattedString(suite_data.get("path"), language=language)
        print("Suite :: " + suite_path)

        if suite_data.get("type") is None:
            if not os.path.exists(suite_path):
                print(f"Suite Path does not exist :: {suite_path}")
                print(f"Skipping {suite}...")
                continue

        command = [
            "codeql",
            "resolve",
            "queries",
            suite_path,
            "--format=bylanguage",
            "--additional-packs",
            ".",
        ]

        print(f"Processing :: '{suite}'")

        output_config = suite.replace(".qls", ".json")
        with open(output_config, "w") as handle:
            subprocess.run(command, stdout=handle)

        with open(output_config, "r") as handle:
            query_suite_config = json.load(handle).get("byLanguage", {}).get(language)

        suites[suite] = []
        # DATA[arguments.language][suite] = query_suite_config

        for query_path, _ in query_suite_config.items():
            query_path = query_path.replace(here + "/", "")

            # if not query_path.startswith(codeql_folder):
            #     #  Non-standard CodeQL Query
            #     print(f"Query :: " + query_path)

            suites[suite].append(query_path)

        print(f"Queries Count :: {len(suites[suite])}")
        os.remove(output_config)

    return suites


if __name__ == "__main__":

    DATA = {}
    PLACEHOLDER_SUITES = "<!-- AUTOMATION-SUITES -->"

    languages = []
    if not arguments.language:
        languages = ["cpp", "csharp", "java", "javascript", "python"]
    else:
        languages = [arguments.language]

    for language in languages:
        output_queries = os.path.join(language, "queries.json")
        DATA[language] = {}

        if not os.path.exists(output_queries) or arguments.disable_cache:
            DATA[language] = buildQueries(language)
        else:
            print(f"Reading queries from cache :: {output_queries}")
            with open(output_queries, "r") as handle:
                DATA[language] = json.load(handle)

        output = os.path.join(language, "README.md")

        with open(output_queries, "w") as handle:
            json.dump(DATA[language], handle, indent=2, sort_keys=True)

        print(f"Output :: {output}")

        suite_table = createSuitesTable(DATA.get(language), language)
        createMarkdown(output, suite_table, placeholder=PLACEHOLDER_SUITES)

        query_table = createQueryTable(DATA.get(language), language)
        createMarkdown(output, query_table, placeholder="<!-- AUTOMATION-QUERIES -->")

    full_output = ""
    for language in languages:
        lang = language_display.get(language)
        full_output += f"### Summary - {lang}\n\n"
        full_output += createSuitesTable(DATA.get(language), language)
        full_output += "\n"

    createMarkdown("./README.md", full_output, placeholder=PLACEHOLDER_SUITES)
