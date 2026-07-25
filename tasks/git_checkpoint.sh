#!/usr/bin/env bash
# tasks/git_checkpoint.sh
# Staging and checkpointing helper script for macOS / Linux.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

echo -e "\033[36m--- Git Checkpoint Utility (macOS) ---\033[0m"
echo -e "\033[33mCurrent Branch:\033[0m \033[1m$BRANCH\033[0m"

# Stage all changes
git add -A
echo -e "\033[33mStaged all changes.\033[0m"
git status --short

if [ -z "$1" ]; then
    read -p "Enter commit message: " msg
else
    msg="$1"
fi

if [ -z "$msg" ]; then
    echo -e "\033[31mCommit message cannot be empty! Aborting.\033[0m"
    exit 1
fi

git commit -m "$msg"
echo -e "\033[32mCommit completed successfully.\033[0m"

read -p "Push to origin/$BRANCH? (y/N): " push_confirm
if [[ "$push_confirm" =~ ^[Yy]$ ]]; then
    git push origin "$BRANCH"
    echo -e "\033[32mPushed cleanly to origin/$BRANCH.\033[0m"
fi
