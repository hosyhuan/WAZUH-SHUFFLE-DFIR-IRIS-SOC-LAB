#!/bin/bash
# Active Response: khóa quyền ghi thư mục web (chống tạo/sửa thêm file độc hại)
read INPUT_JSON
TARGET_DIR=$(echo "$INPUT_JSON" | grep -oP '"extra_args":\s*\["\K[^"]+')
[ -z "$TARGET_DIR" ] && TARGET_DIR="/var/www/html"

LOG=/var/ossec/logs/active-responses.log   # chỉnh theo đường dẫn log thực tế trên máy bạn

if [ -d "$TARGET_DIR" ]; then
    chmod -R a-w "$TARGET_DIR"
    echo "$(date '+%F %T') - Locked write permission on $TARGET_DIR" >> "$LOG"
    exit 0
else
    echo "$(date '+%F %T') - Directory not found: $TARGET_DIR" >> "$LOG"
    exit 1
fi
