# Security Queries

This repository is where I store and research CodeQL security queries for the community and organisations to use.

## Queries
<!-- AUTOMATION-QUERIES -->
### Queries - C / CPP

| Name | Severity | Path |
| :--- | :------- | :--- |

### Queries - CSharp

| Name | Severity | Path |
| :--- | :------- | :--- |

### Queries - Java

| Name                                                           | Severity      | Path                                             |
| :------------------------------------------------------------- | :------------ | :----------------------------------------------- |
| `Base64 Encoding of Sensitive Information`                     | High / 8.0    | `java/CWE-326/Base64Encryption.ql`               |
| `Hard-coded password field`                                    | Unknown / 9.8 | `java/CWE-798/HardcodedPasswordsInProperties.ql` |
| `Sensitive information exposure through logging`               | Unknown / 8.0 | `java/CWE-532/SensitiveInformation.ql`           |
| `Use of Cryptographically Weak Pseudo-Random Number Generator` | Medium / 6.0  | `java/CWE-338/WeakPRNG.ql`                       |
| `Customized Cross-site scripting`                              | Unknown / 6.1 | `java/CWE-079/XSSJSP.ql`                         |

### Queries - JavaScript / TypeScript

| Name | Severity | Path |
| :--- | :------- | :--- |

### Queries - Python

| Name                                                           | Severity        | Path                                           |
| :------------------------------------------------------------- | :-------------- | :--------------------------------------------- |
| `Code injection`                                               | Critical / 10.0 | `python/CWE-094/CodeInjectionLocal.ql`         |
| `SQL query built from user-controlled sources`                 | Critical / 10.0 | `python/CWE-089/SqlInjectionLocal.ql`          |
| `Deserializing untrusted input`                                | High / 8.0      | `python/CWE-502/UnsafeDeserializationLocal.ql` |
| `Uncontrolled command line`                                    | Critical / 10.0 | `python/CWE-078/CommandInjectionLocal.ql`      |
| `Use of a broken or weak cryptographic algorithm`              | Medium / 5.0    | `python/CWE-327/WeakHashingAlgorithms.ql`      |
| `Dangerous Functions`                                          | Low / 2.5       | `python/CWE-676/DangerousFunctions.ql`         |
| `Insufficient Logging`                                         | Low / 1.0       | `python/CWE-778/InsufficientLogging.ql`        |
| `Hard-coded credentials`                                       | Medium / 5.9    | `python/CWE-798/HardcodedFrameworkSecrets.ql`  |
| `Use of Cryptographically Weak Pseudo-Random Number Generator` | Medium / 6.0    | `python/CWE-338/WeakPRNG.ql`                   |

<!-- AUTOMATION-QUERIES -->
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
