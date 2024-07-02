# Gitmoji Auto Release Action

This GitHub Action automates the creation of releases and tags based on Gitmoji and Semantic Versioning (SemVer) using shell script.

## Inputs

- `branch`: The branch to interact with.

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
      uses: <your-username>/gitmoji-auto-release-action@v1
      with:
        branch: ${{ github.ref }}

    - name: Create GitHub Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ steps.auto_release.outputs.tag }}
        release_name: ${{ steps.auto_release.outputs.release_name }}
        body: ${{ steps.auto_release.outputs.release_body }}
        draft: false
        prerelease: false
```