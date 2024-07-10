#!/bin/bash

HARBOR_URL="https://vcr.test.vn"
SKOPEO_DOCKER="vcr.test.vn"
USERNAME="admin"
PASSWORD="12341234**"
PROJECT_NAME="test"
BACKUP_DIR="/root/test-backup"

mkdir -p "$BACKUP_DIR"

curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects/$PROJECT_NAME" > "$BACKUP_DIR/project_$PROJECT_NAME.json"

curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects/$PROJECT_NAME/repositories" > "$BACKUP_DIR/repositories.json"

repositories=$(jq -r '.[].name' "$BACKUP_DIR/repositories.json" | awk -F'/' '{print $2}')
for repo in $repositories; do
    curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects/$PROJECT_NAME/repositories/${repo}/artifacts" > "$BACKUP_DIR/${repo}_artifacts.json"
    mkdir -p "$BACKUP_DIR/$repo"
    tags=$(jq -r '.[] | .tags[]?.name' "$BACKUP_DIR/${repo}_artifacts.json")
    for tag in $tags; do
        skopeo copy --tls-verify=false docker://$SKOPEO_DOCKER/$PROJECT_NAME/${repo}:${tag} dir:$BACKUP_DIR/$repo/${tag}
    done
done
