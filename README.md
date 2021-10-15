# Security Queries

This repository is where I store and research CodeQL security queries for the community and organisations to use.

## Queries
<!-- AUTOMATION -->


<!-- ENDAUTOMATION -->

## Suites
<!-- AUTOMATION-SUITES -->
### Summary - C / CPP

| Name             | Queries Count | Description                                                  | Path                                                         |
| :--------------- | :------------ | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `default`        | 37            | Default Query Suite                                          | `code-scanning`                                              |
| `extended`       | 67            | Security Extended Suite                                      | `security-extended`                                          |
| `quality`        | 151           | Security and Quality Extended Suite                          | `security-and-quality`                                       |
| `super-extended` | 67            | Security Extended with Experimental and Custom Queries Suite | `GeekMasher/security-queries/cpp/suites/codeql-cpp.qls@main` |

### Summary - CSharp

| Name             | Queries Count | Description                                                  | Path                                                               |
| :--------------- | :------------ | :----------------------------------------------------------- | :----------------------------------------------------------------- |
| `default`        | 46            | Default Query Suite                                          | `code-scanning`                                                    |
| `extended`       | 61            | Security Extended Suite                                      | `security-extended`                                                |
| `quality`        | 166           | Security and Quality Extended Suite                          | `security-and-quality`                                             |
| `super-extended` | 76            | Security Extended with Experimental and Custom Queries Suite | `GeekMasher/security-queries/csharp/suites/codeql-csharp.qls@main` |

### Summary - Java

| Name             | Queries Count | Description                                                  | Path                                                                 |
| :--------------- | :------------ | :----------------------------------------------------------- | :------------------------------------------------------------------- |
| `default`        | 42            | Default Query Suite                                          | `code-scanning`                                                      |
| `extended`       | 61            | Security Extended Suite                                      | `security-extended`                                                  |
| `quality`        | 181           | Security and Quality Extended Suite                          | `security-and-quality`                                               |
| `local-variants` | 72            | Security Extended with local variants enabled                | `GeekMasher/security-queries/java/suites/codeql-java-local.qls@main` |
| `super-extended` | 96            | Security Extended with Experimental and Custom Queries Suite | `GeekMasher/security-queries/java/suites/codeql-java.qls@main`       |

### Summary - JavaScript / TypeScript

| Name             | Queries Count | Description                                                  | Path                                                                       |
| :--------------- | :------------ | :----------------------------------------------------------- | :------------------------------------------------------------------------- |
| `default`        | 74            | Default Query Suite                                          | `code-scanning`                                                            |
| `extended`       | 84            | Security Extended Suite                                      | `security-extended`                                                        |
| `quality`        | 182           | Security and Quality Extended Suite                          | `security-and-quality`                                                     |
| `super-extended` | 90            | Security Extended with Experimental and Custom Queries Suite | `GeekMasher/security-queries/javascript/suites/codeql-javascript.qls@main` |

### Summary - Python

| Name             | Queries Count | Description                                                  | Path                                                                     |
| :--------------- | :------------ | :----------------------------------------------------------- | :----------------------------------------------------------------------- |
| `default`        | 26            | Default Query Suite                                          | `code-scanning`                                                          |
| `extended`       | 31            | Security Extended Suite                                      | `security-extended`                                                      |
| `quality`        | 153           | Security and Quality Extended Suite                          | `security-and-quality`                                                   |
| `local-variants` | 36            | Security Extended with local variants enabled                | `GeekMasher/security-queries/python/suites/codeql-python-local.qls@main` |
| `super-extended` | 31            | Security Extended with Experimental and Custom Queries Suite | `GeekMasher/security-queries/python/suites/codeql-python.qls@main`       |



<!-- AUTOMATION-SUITES -->

## Tools

### Scripts

This folder contains scripts that I use to make my life easier (all store in the `./scripts` directory).

| Name (path)                        | Description                                                                                      |
| :--------------------------------- | :----------------------------------------------------------------------------------------------- |
| [`update.sh`](./scripts/update.sh) | Updates CodeQL CLI automatically                                                                 |
| [`scan.py`](./scripts/scan.py)     | Script to automatically create and store CodeQL databases. VSCode tasks for workspace available. |


### `customize` Action

This action is used to easily inject customisations into CodeQL.
See the [README](./customize) for more information.
