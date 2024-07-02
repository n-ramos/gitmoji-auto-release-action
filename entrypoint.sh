#!/bin/bash
set -e

BRANCH=$INPUT_BRANCH
DRAFT=$INPUT_DRAFT
PRERELEASE=$INPUT_PRERELEASE
GITHUB_TOKEN=$GITHUB_TOKEN
REPO_OWNER=$(echo $GITHUB_REPOSITORY | cut -d '/' -f 1)
REPO_NAME=$(echo $GITHUB_REPOSITORY | cut -d '/' -f 2)

# Fetch all tags
git fetch --tags

# Get the latest tag
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

# Get commits since the latest tag
COMMITS=$(git log ${LATEST_TAG}..HEAD --pretty=format:"%s")

PATCH=0
MINOR=0
MAJOR=0

RELEASE_BODY=""

while IFS= read -r COMMIT; do
  if [[ $COMMIT == *":bug:"* ]] || [[ $COMMIT == *":lock:"* ]] || [[ $COMMIT == *":adhesive_bandage:"* ]]; then
    PATCH=$((PATCH+1))
  elif [[ $COMMIT == *":sparkles:"* ]] || [[ $COMMIT == *":rocket:"* ]] || [[ $COMMIT == *":zap:"* ]]; then
    MINOR=$((MINOR+1))
  elif [[ $COMMIT == *":boom:"* ]] || [[ $COMMIT == *":firecracker:"* ]]; then
    MAJOR=$((MAJOR+1))
  fi
  RELEASE_BODY+="- ${COMMIT}\n"
done <<< "$COMMITS"

IFS='.' read -r -a VERSION_PARTS <<< "${LATEST_TAG/v/}"
MAJOR_VERSION=${VERSION_PARTS[0]}
MINOR_VERSION=${VERSION_PARTS[1]}
PATCH_VERSION=${VERSION_PARTS[2]}

if [[ $MAJOR -gt 0 ]]; then
  MAJOR_VERSION=$((MAJOR_VERSION+1))
  MINOR_VERSION=0
  PATCH_VERSION=0
elif [[ $MINOR -gt 0 ]]; then
  MINOR_VERSION=$((MINOR_VERSION+1))
  PATCH_VERSION=0
else
  PATCH_VERSION=$((PATCH_VERSION+1))
fi

NEW_TAG="v${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}"
RELEASE_NAME="Release ${NEW_TAG}"

# Create the new tag
git tag ${NEW_TAG}
git push origin ${NEW_TAG}

# Create a release
API_JSON=$(printf '{"tag_name": "%s", "target_commitish": "%s", "name": "%s", "body": "%s", "draft": %s, "prerelease": %s}' "$NEW_TAG" "$BRANCH" "$RELEASE_NAME" "$RELEASE_BODY" "$DRAFT" "$PRERELEASE")
curl --request POST \
  --url "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases" \
  --header "Authorization: Bearer ${GITHUB_TOKEN}" \
  --header "Content-Type: application/json" \
  --data "$API_JSON"

# Set outputs
echo "tag=${NEW_TAG}" >> $GITHUB_OUTPUT
echo "release_name=${RELEASE_NAME}" >> $GITHUB_OUTPUT
echo -e "release_body=${RELEASE_BODY}" >> $GITHUB_OUTPUT
