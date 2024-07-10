#!/bin/bash

HARBOR_URL="https://vcr.test.vn"
SKOPEO_DOCKER="vcr.test.vn"
USERNAME="admin"
PASSWORD="12341234**"
BACKUP_DIR="/root/harbor-backup"

# Lấy danh sách tất cả các project từ thư mục backup
projects=$(jq -r '.[].name' "$BACKUP_DIR/projects.json")

# Lặp qua từng project
for project in $projects; do
    # Tạo project mới nếu chưa tồn tại
    if ! curl -k -u $USERNAME:$PASSWORD "$HARBOR_URL/api/v2.0/projects/$project" | jq -e '.name' > /dev/null; then
        echo "Tạo project: $project"
        curl -k -u $USERNAME:$PASSWORD -X POST "$HARBOR_URL/api/v2.0/projects" \
             -H "Content-Type: application/json" \
             -d "{\"project_name\": \"$project\", \"metadata\": {\"public\": \"true\"}}" \
             -H "Accept: application/json"
    else
        echo "Project $project đã tồn tại."
    fi

    # Lấy danh sách các repository từ thư mục backup
    repositories=$(jq -r '.[].name' "$BACKUP_DIR/$project/repositories.json" | sed "s/^$project\///")
    for repo in $repositories; do
        echo "Khôi phục repository: $project/$repo"

        # Khôi phục các artifacts cho từng repository
        tags=$(jq -r '.[] | .tags[]?.name' "$BACKUP_DIR/$project/${repo}_artifacts.json")
        for tag in $tags; do
            echo "Khôi phục image: $project/$repo:$tag"
            skopeo copy --tls-verify=false dir:$BACKUP_DIR/$project/$repo/${tag} docker://$SKOPEO_DOCKER/$project/${repo}:${tag}
        done
    done
done

echo "Khôi phục dữ liệu hoàn tất!"
