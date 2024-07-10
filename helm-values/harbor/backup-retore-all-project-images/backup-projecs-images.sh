#!/bin/bash

HARBOR_URL="https://vcr.test.vn"
SKOPEO_DOCKER="vcr.test.vn"
USERNAME="admin"
PASSWORD="12341234**"
BACKUP_DIR="/root/harbor-backup"

# Tạo thư mục backup
mkdir -p "$BACKUP_DIR"

# Lấy danh sách tất cả các project
curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects?page_size=100" > "$BACKUP_DIR/projects.json"

# Lặp qua từng project
projects=$(jq -r '.[].name' "$BACKUP_DIR/projects.json")
for project in $projects; do
    mkdir -p "$BACKUP_DIR/$project"
    curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects/$project" > "$BACKUP_DIR/project_$project.json"
    curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects/$project/repositories" > "$BACKUP_DIR/$project/repositories.json"

    # Lấy danh sách repositories và loại bỏ phần project trong tên repository
    repositories=$(jq -r '.[].name' "$BACKUP_DIR/$project/repositories.json" | sed "s/^$project\///")
    for repo in $repositories; do
        mkdir -p "$BACKUP_DIR/$project/$repo"
        # Mã hóa URL để tránh lỗi NOT_FOUND
        encoded_repo=$(echo "$repo" | sed 's/\//%2F/g')
        curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects/$project/repositories/$encoded_repo/artifacts" > "$BACKUP_DIR/$project/${repo}_artifacts.json"

        tags=$(jq -r '.[] | .tags[]?.name' "$BACKUP_DIR/$project/${repo}_artifacts.json")
        for tag in $tags; do
            skopeo copy --tls-verify=false docker://$SKOPEO_DOCKER/$project/${repo}:${tag} dir:$BACKUP_DIR/$project/$repo/${tag}
        done
    done
done
