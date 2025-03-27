#!/bin/bash
set -e

# === CONFIG ===
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHART_SOURCE_DIR="${SCRIPT_DIR}/helm-chart-sources"
CHART_FILE="${CHART_SOURCE_DIR}/Chart.yaml"
VALUES_FILE="${CHART_SOURCE_DIR}/values.yaml"
REPO_URL=${REPO_URL:-"https://forwardmeasure.github.io/nvidia-triton-inference-server-helm-chart"}

# === DEFAULTS ===
DO_TAG=true
DO_PUSH=true
DO_BRANCH=true
BASE_BRANCH="develop"

# === PARSE ARGS ===
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --version) VERSION_OVERRIDE="$2"; shift ;;
    --message) COMMIT_MSG="$2"; shift ;;
    --base-branch) BASE_BRANCH="$2"; shift ;;
    --no-tag) DO_TAG=false ;;
    --no-push) DO_PUSH=false ;;
    --no-branch) DO_BRANCH=false ;;
    *) echo "❌ Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# === Extract image tag from values.yaml ===
IMAGE_TAG=$(grep imageName "${VALUES_FILE}" | sed -n 's/.*:\(.*\)/\1/p' | tr -d '"')

if [[ -z "$IMAGE_TAG" ]]; then
  echo "❌ Could not extract image tag from values.yaml"
  exit 1
fi

# === Determine new version ===
CURRENT_VERSION=$(grep "^version:" "$CHART_FILE" | awk '{print $2}')

if [[ -n "$VERSION_OVERRIDE" ]]; then
  NEW_VERSION="$VERSION_OVERRIDE"
else
  IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
  PATCH=$((PATCH + 1))
  NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
fi

# === Update Chart.yaml ===
echo "🔧 Updating Chart.yaml: version=${NEW_VERSION}, appVersion=${IMAGE_TAG}"
sed -i'' -E "s/^version: .*/version: ${NEW_VERSION}/" "$CHART_FILE"
sed -i'' -E "s/^appVersion: .*/appVersion: "${IMAGE_TAG}"/" "$CHART_FILE"

# === Set default commit message ===
COMMIT_MSG=${COMMIT_MSG:-"Release chart version ${NEW_VERSION}"}
RELEASE_BRANCH="release/v${NEW_VERSION}"
RELEASE_TAG="v${NEW_VERSION}"

cd "$SCRIPT_DIR"

echo "🔍 Linting Helm chart..."
helm lint "${CHART_SOURCE_DIR}"

echo "📦 Packaging Helm chart version ${NEW_VERSION}..."
helm package "${CHART_SOURCE_DIR}"

echo "⬇️ Fetching latest index.yaml from ${BASE_BRANCH} to preserve previous versions..."
git fetch origin "${BASE_BRANCH}"
git show origin/${BASE_BRANCH}:index.yaml > old-index.yaml || touch old-index.yaml

echo "🧾 Merging new chart into index.yaml..."
helm repo index . --url "${REPO_URL}" --merge old-index.yaml
rm -f old-index.yaml

echo "📂 Committing changes to Git..."
git add .
git commit -m "${COMMIT_MSG}"

if $DO_BRANCH; then
  echo "🌿 Creating release branch: ${RELEASE_BRANCH}"
  git checkout -b "${RELEASE_BRANCH}"
fi

if $DO_TAG; then
  echo "🏷️  Tagging release as: ${RELEASE_TAG}"
  git tag "${RELEASE_TAG}"
fi

if $DO_PUSH; then
  echo "🚀 Pushing branch and tag to remote..."
  git config push.default current
  if $DO_BRANCH; then git push -u origin "${RELEASE_BRANCH}"; fi
  if $DO_TAG; then git push origin "${RELEASE_TAG}"; fi
else
  echo "⚠️  Push skipped (--no-push was set)"
fi

echo "✅ Helm chart version ${NEW_VERSION} packaged and index updated!"
