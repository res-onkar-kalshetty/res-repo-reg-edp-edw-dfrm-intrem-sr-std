#!/usr/bin/env bash
DFORM_API_URL="https://dataform.googleapis.com/v1beta1"
DFORM_PATH_PARAM="projects/${PROJECT_ID}/locations/${DFORM_LOCATION}/repositories"
DFORM_COMPILATION_NAME=""

set -euxo pipefail
source /workspace/build_vars

apt-get update -y &&
apt-get install -y jq

check_if_dform_exists() {
    dform_name=$1
    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name")
    
    if echo "$response" | grep -q '"name"'; then
        # Dataform repository found
        echo 0
    else
        # Dataform repository not found
        echo 1
    fi
}

check_if_release_config_exists() {
    dform_name=$1
    release_name=$2

    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")

    # Parse the 'name' field from the response and check if it's not null
    parsed_name=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_name" && "$parsed_name" != "null" ]]; then
        echo 0
    else
        echo 1
    fi
}

check_if_workflow_exists() {
    dform_name=$1
    wflw_name=$2

    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/workflowConfigs/$wflw_name")

    # Parse the 'name' field from the response and check if it's not null
    parsed_name=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_name" && "$parsed_name" != "null" ]]; then
        echo 0
    else
        echo 1
    fi
}

create_release_compilation() {
    dform_name=$1
    release_name=$2

    echo "Creating compilation for release $release_name in $dform_name..."
    JSON_PAYLOAD=$(printf '{"releaseConfig": "%s"}' "$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")    

    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/compilationResults")
    
    parsed_res=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_res" && "$parsed_res" != "null" ]]; then
        DFORM_COMPILATION_NAME=$parsed_res
        echo 0
    else
        echo 1
    fi
}


create_release_config() {
    dform_name=$1
    release_name=$2

    echo "Creating release $release_name in $dform_name..."

    if [[ "$release_name" =~ ^test-release- ]]; then
        table_prefix=$(echo $release_name | sed 's/[-. ]/_/g')
        JSON_PAYLOAD=$(printf '{"gitCommitish": "%s", "codeCompilationConfig": {"schemaSuffix": "_%s"}}' "$SHORT_SHA" "$table_prefix")
    elif [[ "$release_name" =~ ^dev-release ]]; then
        JSON_PAYLOAD=$(printf '{"gitCommitish": "%s"}' "$SHORT_SHA")
    else
        JSON_PAYLOAD=$(printf '{"gitCommitish": "%s"}' "$REF_NAME")
    fi 

    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/releaseConfigs/?releaseConfigId=$release_name")
    
    parsed_res=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_res" && "$parsed_res" != "null" ]]; then
        echo 0
    else
        echo 1
    fi
}

update_release_config() {
    dform_name=$1
    release_name=$2
    # Implement the update logic here
    
    echo "Updating release $release_name in $dform_name..."

    if [[ "$release_name" =~ ^test-release- ]]; then
        table_prefix=$(echo $release_name | sed 's/[-. ]/_/g')
        JSON_PAYLOAD=$(printf '{"gitCommitish": "%s", "codeCompilationConfig": {"schemaSuffix": "_%s"}}' "$SHORT_SHA" "$table_prefix")
    elif [[ "$release_name" =~ ^dev-release ]]; then
        JSON_PAYLOAD=$(printf '{"gitCommitish": "%s"}' "$SHORT_SHA")
    else
        JSON_PAYLOAD=$(printf '{"gitCommitish": "%s"}' "$REF_NAME")
    fi 

    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" -X PATCH -d "$JSON_PAYLOAD" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")
    
    parsed_res=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_res" && "$parsed_res" != "null" ]]; then
        echo 0
    else
        echo 1
    fi

}

create_workflow_config() {
    dform_name=$1
    wflw_name=$2
    release_name=$3
    # Implement the create logic here

    echo "Creating workflow $wflw_name in $dform_name..."

    if [[ "$release_name" =~ ^test-release- ]]; then
        JSON_PAYLOAD=$(printf '{"releaseConfig": "%s"}' "$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")
    else
        JSON_PAYLOAD=$(printf '{"releaseConfig": "%s", "cronSchedule": "0 6 * * *", "timeZone": "UTC" }' "$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")
    fi
    
    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" -X POST -d "$JSON_PAYLOAD" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/workflowConfigs/?workflowConfigId=$wflw_name")
    
    parsed_res=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_res" && "$parsed_res" != "null" ]]; then
        echo 0
    else
        echo 1
    fi
}

update_workflow_config() {
    dform_name=$1
    wflw_name=$2
    release_name=$3
    # Implement the update logic as required.

    echo "Updating workflow $wflw_name in $dform_name..."

    JSON_PAYLOAD=$(printf '{"releaseConfig": "%s", "cronSchedule": "0 6 * * *", "timeZone": "UTC" }' "$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")
    # modify the above JSON_PAYLOAD according to the requirement.

    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" -X PATCH -d "$JSON_PAYLOAD" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/workflowConfigs/?workflowConfigId=$wflw_name")
    
    parsed_res=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_res" && "$parsed_res" != "null" ]]; then
        echo 0
    else
        echo 1
    fi
}

patch_release_config_with_compilation_res() {
    dform_name=$1
    release_name=$2

    response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" -X GET \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")
    
    parsed_res=$(echo "$response" | jq -r '.name // empty')

    if [[ -n "$parsed_res" && "$parsed_res" != "null" ]]; then
        new_release_config=$(echo "$response" | jq --arg compilationName "$DFORM_COMPILATION_NAME" '. + { releaseCompilationResult: $compilationName }')
        echo "Updated release config: $new_release_config"

        response=$(curl -s -H "Authorization: Bearer $TOKEN" \
                 -H "Content-Type: application/json" -X PATCH -d "$new_release_config" \
                 "$DFORM_API_URL/$DFORM_PATH_PARAM/$dform_name/releaseConfigs/$release_name")
    
        parsed_res=$(echo "$response" | jq -r '.name // empty')

        if [[ -n "$parsed_res" && "$parsed_res" != "null" ]]; then
            echo 0
        else
            echo 1
        fi
    else
        echo 1
    fi
}


# Obtain the OAuth token
TOKEN=$(gcloud auth print-access-token)

# Define release and workflow names based on branch name
DFORM_RELEASE_NAME=$([[ ! ${REF_NAME} =~ ^feature-(major|minor|patch)-.*$ ]] && echo "${_ENV_}-release" || echo "test-release-$DFORM_COMMITOR")
DFORM_WKFLW_NAME=$([[ ! ${REF_NAME} =~ ^feature-(major|minor|patch)-.*$ ]] && echo "${_ENV_}-workflow" || echo "test-workflow-$DFORM_COMMITOR")

# Check if the release config exists
release_is_exists=$(check_if_release_config_exists "$DFORM_NAME" "$DFORM_RELEASE_NAME")

# If the release config does NOT exist, create it
if [[ $release_is_exists -ne 0 ]]; then
    echo "Release not found! Creating a new release"

    create_release_config "$DFORM_NAME" "$DFORM_RELEASE_NAME"
    release_create_status=$?
    if [[ $release_create_status -ne 0 ]]; then
        echo "Release creation failed! Please validate."
        exit 1
    fi
    echo "Release created!"
else
    echo "Release already exists; Updating the release config $DFORM_RELEASE_NAME"

    update_release_config "$DFORM_NAME" "$DFORM_RELEASE_NAME"
    release_update_status=$?
    if [[ $release_update_status -ne 0 ]]; then
        echo "Release creation failed! Please validate."
        exit 1
    fi
    echo "Release updated!"
fi

echo "Creating new compilation for the release $DFORM_RELEASE_NAME"
create_release_compilation "$DFORM_NAME" "$DFORM_RELEASE_NAME"
compilation_res=$?
if [[ $compilation_res -ne 0 ]]; then
    echo "Compliation creation failed! Please validate."
    exit 1
else
    patch_release_config_with_compilation_res "$DFORM_NAME" "$DFORM_RELEASE_NAME"
    $patch_res=$?
    if [[ $compilation_res -ne 0 ]]; then
        echo "Patching release with compilation failed! Please validate."
        exit 1
    fi
fi
echo "New compilation created!"

workflow_is_exists=$(check_if_workflow_exists "$DFORM_NAME" "$DFORM_WKFLW_NAME")
# release_is_exists=$?

# If the workflow config does NOT exist, create it
if [[ $workflow_is_exists -ne 0 ]]; then
    echo "Workflow not found! Creating a new workflow"

    create_workflow_config "$DFORM_NAME" "$DFORM_WKFLW_NAME" "$DFORM_RELEASE_NAME"
    workflow_create_status=$?
    if [[ $workflow_create_status -ne 0 ]]; then
        echo "Workflow creation failed! Please validate."
        exit 1
    fi
    echo "Workflow created!"
else
    echo "Release already exists; Updated manually if required"
    #  If updates need to be done via CD, add the neccessary calls and checks to the update workflow function
fi

