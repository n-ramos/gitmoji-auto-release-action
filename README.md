# Gitmoji Auto Release Action

This GitHub Action automates the creation of releases and tags based on Gitmoji and Semantic Versioning (SemVer) using shell script.

## Inputs

- `branch`: The branch to interact with.
- `draft`: Indicate if the release should be marked as a draft.
- `prerelease`: Indicate if the release should be marked as a prerelease.

## Outputs

- `tag`: The created tag.
- `release_name`: The name of the release.
- `release_body`: The body of the release.

## Example usage

```yaml
name: Auto Release

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main
      - develop

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Gitmoji Auto Release
      id: auto_release
      uses: n-ramos/gitmoji-auto-release-action@v1
      with:
        branch: ${{ github.ref }}
        draft: false
        prerelease: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}