# configs/

Các file cấu hình do nhóm tự viết hoặc chỉnh sửa. Đã loại bỏ thông tin nhạy cảm (URL Webhook, API key, token Telegram).

| File | Mô tả |
|---|---|
| `wazuh/auditd-webshell.rules` | Luật auditd bắt `execve` và `connect` của `www-data` |
| `wazuh/ossec-fim-snippet.xml` | FIM realtime web root và integration Webhook sang Shuffle |
| `wazuh/local_rules_webshell.xml` | Rule 100500–100520 phát hiện và tương quan webshell |
| `active-response/mitre-m1018-lock-webdir.sh` | Khóa quyền ghi thư mục web |
| `active-response/mitre-m1042-suspend-service.sh` | Tạm dừng dịch vụ (Apache2) |

> Trước khi upload thêm file mới (ví dụ export workflow Shuffle), mở bằng trình soạn thảo và tìm `key`, `token`, `apikey`, `password`, `url` để xóa thông tin thật.
