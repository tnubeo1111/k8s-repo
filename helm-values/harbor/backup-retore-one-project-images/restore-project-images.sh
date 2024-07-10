#!/bin/bash

HARBOR_URL="https://vcr.test.vn"
SKOPEO_DOCKER="vcr.test.vn"
USERNAME="admin"
PASSWORD="12341234**"
PROJECT_NAME="test"
BACKUP_DIR="/root/test-backup"

# Tạo lại ect
echo "Tạo lại project $PRO_NAME"
curl -k -u $USERNAME:$PASSWORD -X POST "$HARBOR_URL/api/v2.0/projects" \
-H "Content-Type: application/json" \
-d '{"project_name": "'"$PROJECT_NAME"'", "public": true}' \
| jq .

# Lặp qua các thư mục chứa hình ảnh trong backup
for repo_dir in $(ls -d $BACKUP_DIR/*/); do
    repo=$(basename $repo_dir)
    echo "Khôi phục repository $repo"

    for tag_dir in $repo_dir*; do
        tag=$(basename $tag_dir)
        image_name="$SKOPEO_DOCKER/$PROJECT_NAME/$repo:$tag"
        echo "Push image $image_name"

        mkdir -p /tmp/restore_image
        skopeo copy --tls-verify=false dir:$BACKUP_DIR/$repo/$tag docker://$image_name

        docker push $image_name

        # Xóa thư mục tạm
        rm -rf /tmp/restore_image
    done
done

echo "Khôi phục hoàn tất."

