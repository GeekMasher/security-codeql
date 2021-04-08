# CodeQL Customisations

This Action allows for users to automatically add their `Customizations.qll` file(s) present in this repository into CodeQL.


## Usage

You need to add this Action between the Initialize stage and Build/Analysis stages

```yaml
# ...
- name: Add CodeQL Customizations
  uses: GeekMasher/security-queries/customize@main
# ...
```

#### Full Example

```yaml
# ...
- name: Initialize CodeQL
  uses: github/codeql-action/init@v1
  with:
    languages: java

- name: Add CodeQL Customizations
  uses: GeekMasher/security-queries/customize@main

- name: Autobuild
  uses: github/codeql-action/autobuild@v1

- name: Perform CodeQL Analysis
  uses: github/codeql-action/analyze@v1
# ...
```