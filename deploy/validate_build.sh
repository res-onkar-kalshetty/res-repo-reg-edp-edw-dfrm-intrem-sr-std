#!/usr/bin/env bash
set -euxo pipefail

# validate env value
[[ ! ${_ENV_} =~ ^(prd|dev)$ ]] && echo "Bad ENV value ${_ENV_}. Expected one of prd, dev" && exit 1

# exit if other builds are running.
# other_ongoing_builds=$(gcloud builds list --ongoing  --format='value(id)'  --filter="substitutions.TRIGGER_NAME=(client-impl-scope-build-${_ENV_} client-impl-scope-build-infra-${_ENV_}) AND id!=$BUILD_ID" --region $REGION --project $PROJECT_ID)
# [[ ! -z $other_ongoing_builds ]] && echo -e "Other builds are ongoing. Please wait till the following builds complete \n $other_ongoing_builds" && exit 1

# validate ref syntax
[[ ! ${REF_NAME} =~ ^master$ && ! ${REF_NAME} =~ ^(release-)?v[1-9][0-9]*?\.([0-9]|[1-9][0-9]+)\.([0-9]|[1-9][0-9]+)$ && ! ${REF_NAME} =~ ^feature-(major|minor|patch)-.*$ ]] && echo "Bad ref name $REF_NAME" && exit 1

git config --global user.name "res-data-eng-bot"
git config --global user.email "rsr-data-engg-dataloads@randstadsourceright.com"

git remote set-url origin git@github.com:randstadrisesmart/$REPO_NAME.git

if [[ ${_ENV_} == 'dev' ]]
then
    git fetch origin master
    master_head=$(git rev-parse origin/master)
    [[ $master_head == ${COMMIT_SHA} ]] && echo "$REF_NAME is just created. hence skipping build" && exit 1
fi

export DFORM_COMMITOR=$(git log -1 --pretty=format:'%ae' | cut -d'@' -f1)

# Determine the build image tag
if [[ ${REF_NAME} =~ ^(release-)?v[1-9][0-9]*?\.([0-9]|[1-9][0-9]+)\.([0-9]|[1-9][0-9]+)$ ]]; then
    export DFORM_RELEASE_TAG=$(echo ${REF_NAME} | sed -E "s/(release-)?(v[1-9][0-9]*?\.([0-9]|[1-9][0-9]+)\.([0-9]|[1-9][0-9]+))/\2/g")
    echo $DFORM_RELEASE_TAG
    git fetch --all
    current_version=$(git describe --tags $(git rev-list --tags --max-count=1) | sed -E "s/^v//g") 

    greater_version=$(echo -e $DFORM_RELEASE_TAG"\n"$current_version | sort -r | head -n 1)

    [[ $greater_version != $DFORM_RELEASE_TAG ]] && echo "release version should be greater than or equal to $greater_version. Received version: $DFORM_RELEASE_TAG" && exit 1
fi

project_var='PROJECT_'${_ENV_^^}

export PROJECT=${!project_var}

env | grep -E "^DFORM_|^PROJECT" > /workspace/build_vars