#!/usr/bin/env python3
import os
import glob
import shutil
import argparse

parser = argparse.ArgumentParser("AddCustomisations")
parser.add_argument(
    "--debug", action="store_true", default=os.environ.get("DEBUG", False)
)

parser.add_argument("-p", "--codeql-qlpacks")
# TODO: Better way of finding the current action path
parser.add_argument(
    "-c",
    "--customisation-path",
    default=os.path.abspath(os.path.dirname(__file__) + "/.."),
)

arguments = parser.parse_args()


def findCodeQLCustomization(codeql_qlpack: str) -> dict:
    codeql_customizations = {}

    # Find Customizations.qll in QLPack
    for qlpack in os.listdir(codeql_qlpack):
        if not qlpack.startswith("codeql-"):
            continue
        customization_file = os.path.join(codeql_qlpack, qlpack, "Customizations.qll")
        if not os.path.exists(customization_file):
            continue

        language = qlpack.replace("codeql-", "").lower()

        # GoLang (go == golang)
        if language == "go":
            language = "golang"

        codeql_customizations[language] = customization_file

    return codeql_customizations


def findSecurityQueries(security_queries_path: str) -> dict:
    security_queries = {}
    for language in os.listdir(security_queries_path):
        full_path = os.path.join(security_queries_path, language)
        customization_file = os.path.join(full_path, "Customizations.qll")
        if not os.path.exists(customization_file):
            continue

        security_queries[language] = customization_file

    return security_queries


if __name__ == "__main__":
    codeql_qlpack = None

    action_path_environment = os.path.join(os.environ.get("CODEQL_DIST", ""), "qlpacks")

    if arguments.codeql_qlpacks:
        if not os.path.exists(arguments.codeql_qlpacks):
            print("Provided CodeQL QLPacks path is invalid")
            exit(1)
        codeql_qlpack = arguments.codeql_qlpacks
    elif os.path.exists(action_path_environment):
        codeql_qlpack = action_path_environment
    else:
        # Actions Deafult: /opt/hostedtoolcache/CodeQL/*/x64/codeql/qlpacks
        paths = glob.glob("/opt/hostedtoolcache/CodeQL/*/x64/codeql/qlpacks")
        if len(paths) == 0:
            print("CodeQL QLPack couldn't be found")
            exit(1)

        codeql_qlpack = paths[0]

    print("CodeQL QLPack :: " + codeql_qlpack)

    codeql_customizations = findCodeQLCustomization(codeql_qlpack)
    security_queries = findSecurityQueries(arguments.customisation_path)

    if arguments.debug:
        print("CodeQL Customization Languages & Files:")
        for lang, path in codeql_customizations.items():
            print(" {:>12} :: {}".format(lang, path))

    print("Current Action path :: " + arguments.customisation_path)

    # Replace the CodeQL file with Current Action
    for lang, path in security_queries.items():

        if not codeql_customizations.get(lang):
            print("CodeQL QLPack Customizations.qll file does not exist")
            continue

        if arguments.debug:
            print(
                " {:>12} :: {} -> {}".format(
                    lang, path, codeql_customizations.get(lang)
                )
            )

        shutil.copyfile(path, codeql_customizations.get(lang))
