import os
import sys
import json
import shutil
import argparse
import requests
import subprocess
from urllib.parse import urlparse


__HERE__ = os.path.abspath(os.path.dirname(__file__))
__CWD__ = os.getcwd()
__VERSION__ = "0.1.0"
__BANNER__ = f"""\
 _____                      _ _         _____                 _           
/  ___|                    (_) |       |  _  |               (_)          
\ `--.  ___  ___ _   _ _ __ _| |_ _   _| | | |_   _  ___ _ __ _  ___  ___ 
 `--. \/ _ \/ __| | | | '__| | __| | | | | | | | | |/ _ \ '__| |/ _ \/ __|
/\__/ /  __/ (__| |_| | |  | | |_| |_| \ \/' / |_| |  __/ |  | |  __/\__ \\
\____/ \___|\___|\__,_|_|  |_|\__|\__, |\_/\_\\\\__,_|\___|_|  |_|\___||___/
                                   __/ |                                  
                                  |___/         {__VERSION__}
"""

# CodeQL Scanning and Utility tool
parser = argparse.ArgumentParser(description="CodeQL Scanning and Utility tool")

parser.add_argument("-n", "--name", help="Project Name")


parser_codeql = parser.add_argument_group("CodeQL")
parser_codeql.add_argument(
    "-l",
    "--lang",
    "--language",
    help="Language",
)
parser_codeql.add_argument(
    "--binary",
    default=os.path.join(__CWD__, "codeql"),
    help="The binary folder",
)
parser_codeql.add_argument(
    "--suite",
    help="The Query Suite",
)
parser_codeql.add_argument(
    "--databases",
    default=os.path.join(__CWD__, "databases"),
    help="The database folder",
)
parser_codeql.add_argument(
    "--results",
    default=os.path.join(__CWD__, "results"),
    help="The results folder",
)
parser_codeql.add_argument(
    "--sources",
    default=os.path.join(__CWD__, "sources"),
    help="The results folder",
)
parser_codeql.add_argument(
    "--command",
    help="The build command",
)
parser_codeql.add_argument(
    "--qlpacks",
    default=__CWD__,
    help="The QLPack folder",
)
parser_codeql.add_argument("--disable-database-deletion", action="store_false")
parser_codeql.add_argument("--experimental", action="store_true")

parser_github = parser.add_argument_group("GitHub")
parser_github.add_argument("-o", "--org", "--organisation", help="Organisation Name")
parser_github.add_argument("-r", "--repo", "--repository", help="GitHub Repository")
parser_github.add_argument(
    "-t", "--token", default=os.environ.get("GITHUB_TOKEN"), help="GitHub Token"
)
parser_github.add_argument("-b", "--branch", help="GitHub Branch")
parser_github.add_argument(
    "--download-sarif", action="store_true", help="Download SARIF file"
)


def repositorySpliting(url: str):
    url = url.split("/")
    return (url[-1], url[-2])


def cloneRepository(url: str, path: str, branch: str = "main", token: str = None):
    print(f"Cloning {url}")

    if token:
        instance = urlparse(url)
        url = f"https://{token}@{instance.netloc}{instance.path}.git"

    cmd = ["git", "clone", "-b", branch, url, path]

    with open(os.devnull, "w") as devnull:
        subprocess.call(cmd, stdout=devnull, stderr=devnull)

    if os.path.exists(path):
        print(f"Cloned {url}")
    else:
        print(f"Failed to clone {url}")
        raise Exception(f"Failed to clone {url}")


def getGitRef(path: str):
    cmd = ["git", "branch", "--show-current"]
    return subprocess.check_output(cmd, cwd=path).decode("utf-8").strip()


def getGitHash(path: str):
    cmd = ["git", "rev-parse", "HEAD"]
    return subprocess.check_output(cmd, cwd=path).decode("utf-8").strip()


def getGitHubRepositoryDefaultBranch(org: str, repo: str, token: str):
    url = f"https://api.github.com/repos/{org}/{repo}/branches"
    r = requests.get(
        url,
        headers={"Authorization": f"token {token}"},
        # params={"protected": "true"},
    )
    data = r.json()

    if r.status_code == 200 and len(data) > 0:
        for branch in data:
            if branch["name"] in ["main", "master"]:
                return branch["name"]
    #  Default is 'main'
    return "main"


def getPullRequestFromBase(org: str, repo: str, branch: str, token: str):
    url = f"https://api.github.com/repos/{org}/{repo}/pulls"
    r = requests.get(
        url,
        headers={
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json",
        },
        params={"state": "open", "sort": "updated"},
    )
    data = r.json()

    if r.status_code == 200 and len(data) > 0:
        for pr in data:
            if pr.get("head", {}).get('ref') == branch:
                return pr.get("id")

    # print(f"Failed to get pull request from base {branch}")
    return None


def getCodeScanningSARIF(org: str, repo: str, ref: str, token: str):
    url = f"https://api.github.com/repos/{org}/{repo}/code-scanning/analyses"
    r = requests.get(
        url,
        headers={
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json",
        },
        params={"ref": ref, "tool_name": "CodeQL"},
    )
    data = r.json()

    sarif_url = None
    if r.status_code == 200 and len(data) > 0:
        sarif_url = data[0].get("url")

    if sarif_url:
        # Request the SARIF file
        r = requests.get(
            sarif_url,
            headers={
                "Authorization": f"token {token}",
                "Accept": "application/sarif+json",
            },
        )
        data = r.json()

        if r.status_code == 200 and len(data) > 0:
            return data

    # print(f"Failed to get pull request from base {branch}")
    return None


if __name__ == "__main__":
    arguments = parser.parse_args()
    print(__BANNER__)

    if arguments.repo:
        arguments.name, arguments.org = repositorySpliting(arguments.repo)

        if not arguments.branch:
            arguments.branch = getGitHubRepositoryDefaultBranch(
                arguments.org, arguments.name, arguments.token
            )
    else:
        if not arguments.branch:
            arguments.branch = "main"

    if not arguments.suite and arguments.lang:
        arguments.suite = arguments.lang + "-security-extended"

    project_path = os.path.join(arguments.sources, arguments.name)
    project_database = os.path.join(arguments.databases, arguments.name)
    project_result = os.path.join(arguments.results, f"{arguments.name}-queries.sarif")

    print("-" * 64)
    print(f"[+] Project         :: {arguments.name}")
    print(f"[+] Org/User        :: {arguments.org}")
    print(f"[+] Repository      :: {arguments.repo}")
    print(f"[+] Repository      :: {arguments.branch}")
    print(f"[+] Language        :: {arguments.lang}")
    print(f"[+] Path            :: {project_path}")
    print(f"[+] CodeQL DB       :: {project_database}")
    print(f"[+] CodeQL Suite    :: {arguments.suite}")
    print(f"[+] CodeQL Packs    :: {arguments.binary}")
    print("-" * 64)

    print("[+] Creating all required directories")
    if arguments.databases:
        os.makedirs(arguments.databases, exist_ok=True)
    if arguments.results:
        os.makedirs(arguments.results, exist_ok=True)
    if arguments.sources:
        os.makedirs(arguments.sources, exist_ok=True)

    if not os.path.exists(project_path):
        print("[+] Project does not exist...")

        if arguments.repo:
            cloneRepository(
                arguments.repo, project_path, arguments.branch, arguments.token
            )
        else:
            print("[-] No repository provided")
            sys.exit(1)
    else:
        print("[+] Project already exists...")

    git_ref = getGitRef(project_path)
    git_hash = getGitHash(project_path)

    print(f"[+] Git Branch (SHA): {git_ref} ({git_hash})")

    if arguments.download_sarif and arguments.repo:
        print("[+] Check SARIF from GitHub...")

        pull_request = getPullRequestFromBase(
            arguments.org, arguments.name, arguments.branch, arguments.token
        )

        if pull_request:
            print(f"[+] Pull Request ID :: {pull_request}")
            git_ref = f"refs/pulls/{pull_request}/head"
        else:
            git_ref = f"refs/heads/{arguments.branch}"

        print(f"[+] Reference :: " + git_ref)

        print(f"[+] Downloading SARIF file from GitHub...")
        sarif = getCodeScanningSARIF(
            arguments.org, arguments.name, git_ref, arguments.token
        )

        if sarif:
            if os.path.exists(project_result):
                print(f"[+] Deleting {project_result}")
                os.remove(project_result)

            print(f"[+] Saving {project_result}")
            with open(project_result, "w") as f:
                json.dump(sarif, f, indent=4)

    else:
        if arguments.lang not in ['cpp', 'csharp', 'go', 'java', 'javascript', 'python']:
            print(f"[!] Language not supported :: {arguments.lang}")
            exit(1)

        if os.path.exists(project_database):
            print("[+] Database already exists...")
            shutil.rmtree(project_database)
            print("[+] Database deleted!")

        print("[+] Creating database...")
        cmd_create = [
            "codeql",
            "database",
            "create",
            project_database,
            "-s",
            project_path,
            "--language",
            arguments.lang,
            "--search-path",
            arguments.binary,
        ]
        subprocess.call(cmd_create)

        print("[+] Updating database...")
        cmd_update = [
            "codeql",
            "database",
            "upgrade",
            project_database,
            "--search-path",
            arguments.binary,
        ]
        subprocess.call(cmd_update)

        print("[+] Analyzing database...")
        cmd_analyze = [
            "codeql",
            "database",
            "analyze",
            "--ram",
            "8000",
            "--threads",
            "4",
            "--rerun",
            "--format",
            "sarif-latest",
            "--output",
            project_result,
            "--search-path",
            arguments.qlpacks,
            project_database,
            arguments.suite,
        ]
        subprocess.call(cmd_analyze)

    # Open VSCode SARIF file
    if os.path.exists(project_result):
        print("[+] Opening SARIF file in VSCode...")
        cmd_open = [
            "code",
            "--reuse-window",
            project_result,
        ]
        subprocess.call(cmd_open)
