#!/bin/bash
# Active Response: tạm dừng dịch vụ bị lợi dụng (mặc định apache2)

# 1. Đọc dữ liệu JSON do Wazuh Manager gửi xuống
read INPUT_JSON

# 2. Bóc tách tên dịch vụ từ chuỗi JSON
TARGET_SERVICE=$(echo "$INPUT_JSON" | grep -oP '"extra_args":\s*\["\K[^"]+')

# 3. Fallback an toàn: nếu không tìm thấy biến, mặc định dừng apache2
if [ -z "$TARGET_SERVICE" ]; then
    TARGET_SERVICE="apache2"
fi

# 4. Thực thi lệnh dừng dịch vụ
systemctl stop "$TARGET_SERVICE"

# 5. Ghi log để admin theo dõi
echo "$(date '+%Y-%m-%d %H:%M:%S') - Active Response (M1042): Da tam ngung dich vu $TARGET_SERVICE" >> /var/ossec/logs/active-responses.log
