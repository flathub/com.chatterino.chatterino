#/bin/env bash
set -e

COMMIT_YAML_PATH=".modules[3].sources[0].commit"

LATEST_COMMIT=$(git ls-remote --refs https://github.com/chatterino/chatterino2/ master | awk '{print substr($1,0,7);}')

COMMIT_BRANCH_NAME="bump-commit-$LATEST_COMMIT"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT_BRANCH" = "$COMMIT_BRANCH_NAME" ]; then
    echo "New commit PR already exists, trying to merge"
    gh pr merge "$COMMIT_BRANCH_NAME" -m -d
    echo "Merged!"

    gh pr list --json title,number -q '.[] | select(.title | contains("Bump commit to")) | .number' | xargs -L 1 gh pr close

    git checkout beta
else
    git checkout beta
    git pull

    CURRENT_COMMIT=$(yq -r "$COMMIT_YAML_PATH" com.chatterino.chatterino.yml)

    if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
        echo "Already on latest commit"
    else
        echo "Updating $CURRENT_COMMIT > $LATEST_COMMIT"

        git checkout -b $COMMIT_BRANCH_NAME

        yq -yi "$COMMIT_YAML_PATH = \"$LATEST_COMMIT\"" com.chatterino.chatterino.yml

        git add com.chatterino.chatterino.yml
        git commit -m "Bump commit to $LATEST_COMMIT"
        git push --set-upstream origin $COMMIT_BRANCH_NAME

        gh pr create -B beta -b 'This PR was automatically created by a script.' -f
    fi
fi

