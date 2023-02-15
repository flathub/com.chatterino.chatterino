#/bin/env bash
set -e

COMMIT_YAML_PATH=".modules[3].sources[0].commit"

git checkout branch/nightly
git pull

CURRENT_COMMIT=$(yq -r "$COMMIT_YAML_PATH" com.chatterino.chatterino.yml)
LATEST_COMMIT=$(git ls-remote --refs https://github.com/chatterino/chatterino2/ master | awk '{print substr($1,0,7);}')

if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
    echo "Already on latest commit"
else 
    echo "Updating $CURRENT_COMMIT > $LATEST_COMMIT"

    git checkout -b "bump-commit-$LATEST_COMMIT"

    yq -yi "$COMMIT_YAML_PATH = \"$LATEST_COMMIT\"" com.chatterino.chatterino.yml

    git add com.chatterino.chatterino.yml
    git commit -m "Bump commit to $LATEST_COMMIT"
    git push

    gh pr create -B branch/nightly -f
fi
