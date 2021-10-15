# Python

## Query Suites
<!-- AUTOMATION-SUITES -->
| Name | Queries Count | Description | Path |
| :--- | :---- | :--- | :--- |
| `default` | 26 | Default Query Suite | `code-scanning` |
| `extended` | 31 | Security Extended Suite | `security-extended` |
| `quality` | 153 | Security and Quality Extended Suite | `security-and-quality` |
| `local-variants` | 35 | Security Extended with local variants enabled | `GeekMasher/security-queries/python/suites/codeql-python-local.qls@main` |
| `super-extended` | 37 | Security Extended with Experimental and Custom Queries Suite | `GeekMasher/security-queries/python/suites/codeql-python.qls@main` |


<!-- AUTOMATION-SUITES -->

## Queries

<!-- AUTOMATION-QUERIES -->
| Name | Severity | Path |
| :--- | :------- | :--- |
| `Code injection` | Unknown / 10.0 | `python/CWE-094/CodeInjectionLocal.ql` |
| `SQL query built from user-controlled sources` | Unknown / 10.0 | `python/CWE-089/SqlInjectionLocal.ql` |
| `Deserializing untrusted input` | Unknown / 8.0 | `python/CWE-502/UnsafeDeserializationLocal.ql` |
| `Uncontrolled command line` | Unknown / 10.0 | `python/CWE-078/CommandInjectionLocal.ql` |
| `Use of a broken or weak cryptographic algorithm` | Medium / 5.0 | `python/CWE-327/WeakHashingAlgorithms.ql` |
| `Hard-coded credentials` | Unknown / 5.9 | `python/CWE-798/HardcodedFrameworkSecrets.ql` |


<!-- AUTOMATION-QUERIES -->
