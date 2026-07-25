#!/usr/bin/env bash
# tasks/merge_feature.sh
# Feature branch verification and merge tool for macOS / Linux.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

FEATURE_BRANCH="$1"

if [ -z "$FEATURE_BRANCH" ]; then
    FEATURE_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ "$FEATURE_BRANCH" = "master" ]; then
        echo -e "\033[31mError: Please specify the feature branch to merge (e.g. ./tasks/merge_feature.sh feature/02-print-recipes)\033[0m"
        exit 1
    fi
fi

echo -e "\033[36m--- Feature Merge Verification Utility (macOS) ---\033[0m"
echo -e "\033[33mTarget Feature Branch:\033[0m \033[1m$FEATURE_BRANCH\033[0m"

cd "$PROJECT_ROOT/frontend"

echo -e "\033[33m1. Running Flutter Static Analysis...\033[0m"
flutter analyze

echo -e "\033[33m2. Updating Graphify Knowledge Graph...\033[0m"
cd "$PROJECT_ROOT"
if command -v graphify &> /dev/null; then
    graphify update .
else
    echo "Graphify CLI not in PATH; skipping graph update step."
fi

echo -e "\033[33m3. Releasing and Merging into master...\033[0m"
git checkout master
git pull origin master 2>/dev/null || true
git merge --no-ff "$FEATURE_BRANCH" -m "Merge branch '$FEATURE_BRANCH' into master"

echo -e "\033[32mSuccessfully merged $FEATURE_BRANCH into master cleanly!\033[0m"
