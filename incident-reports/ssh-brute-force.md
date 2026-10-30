# Incident Report: SSH Brute Force

## 1. Thông tin chung

| Mục | Nội dung |
|---|---|
| Loại sự cố | SSH Brute Force (mô phỏng trong lab) |
| Hệ thống bị nhắm tới | Endpoint Ubuntu `webserver` (Wazuh agent ID 000) |
| Nguồn tấn công | Máy Kali Linux trong lab |
| Công cụ tấn công | Hydra v9.5 |
| Rule kích hoạt | Wazuh Rule **5763**, level **10** |
| Case DFIR-IRIS | #775 (tạo tự động) |
| Mức độ | Medium/High (level 10 trên Wazuh) |
| Trạng thái | Đã ngăn chặn |

## 2. Tóm tắt

Máy Kali dùng Hydra thử lần lượt 15 mật khẩu vào tài khoản SSH của máy chủ `webserver`. Wazuh phát hiện chuỗi đăng nhập thất bại và sinh cảnh báo Rule 5763. Shuffle tự động tạo case và task trên DFIR-IRIS, hỏi quản trị viên qua Telegram; sau khi được duyệt, Wazuh Active Response chặn IP máy tấn công bằng iptables.

## 3. Timeline (từ ảnh chụp dashboard, giờ hiển thị của Wazuh)

| Thời gian | Sự kiện | Rule |
|---|---|---|
| 21:22:51 | PAM: User login failed | 5503 |
| 21:22:53 | sshd: authentication failed | 5760 |
| **21:22:57** | **sshd: brute force trying to get access to the system** | **5763 (level 10)** |
| 21:22:59 | sshd: authentication failed (tiếp tục) | 5760 |
| Sau đó | Case tạo tự động; Telegram hỏi duyệt; quản trị viên chọn "Đồng ý"; IP bị chặn | |

> Ghi chú: ảnh chụp cảnh báo (29/09) và ảnh Telegram (30/09) đến từ các lần chạy khác nhau, nên không ghép thành một timeline liên tục.

## 4. Phát hiện và phân tích

- **Chỉ báo:** nhiều sự kiện `authentication failed` liên tiếp từ cùng một IP nguồn trong thời gian ngắn, sau đó Wazuh nâng thành Rule 5763.
- **Dữ liệu trong alert:** `agent.name`, `data.srcip`, `data.srcuser`, `full_log` (dòng `Failed password for ... from <IP> port ... ssh2`), `rule.firedtimes`.
- **Đánh giá thành công/thất bại:** wordlist 15 mật khẩu không chứa mật khẩu đúng nên cuộc tấn công không thành công. [Xác nhận lại: sự kiện `5715 sshd: authentication success` xuất hiện sau chuỗi thất bại là thao tác đăng nhập hợp lệ của quản trị viên.]

## 5. IOC

| Loại | Giá trị |
|---|---|
| IP nguồn | IP máy Kali trong lab (`data.srcip`) |
| Tài khoản bị nhắm tới | Tài khoản SSH của `webserver` |
| Hành vi | ≥ 5 lần đăng nhập thất bại liên tiếp qua SSH |

## 6. Ánh xạ MITRE ATT&CK

| Tactic | Technique | ID |
|---|---|---|
| Credential Access | Brute Force | T1110 |

## 7. Ứng phó

1. **Ghi nhận:** Shuffle tạo case #775 trên DFIR-IRIS kèm 8 task (Alert Validation, Investigate Source, Scope Assessment, Collect Indicators, Containment, Eradication, Recovery, Lessons Learned) gán cho Analyst và Incident Responder.
2. **Xác nhận:** Telegram gửi cảnh báo (Rule ID, mô tả, agent) và hỏi có kích hoạt Active Response không.
3. **Ngăn chặn:** sau khi duyệt, Wazuh Active Response `firewall-drop` thêm luật `DROP` cho IP nguồn trong chain INPUT (xác minh bằng `iptables -L INPUT -n --line-numbers`).
4. **Cập nhật:** Telegram báo "Đã xử lý case", ghi chú được thêm vào case.

## 8. Khuyến nghị

- Tắt đăng nhập SSH bằng mật khẩu, dùng SSH key.
- Giới hạn số lần thử và thời gian khóa (fail2ban hoặc Active Response có timeout tự gỡ chặn).
- Không cho phép đăng nhập SSH trực tiếp bằng tài khoản có quyền cao; hạn chế nguồn truy cập bằng firewall.
- Rà soát Rule 5763 theo môi trường thật để giảm cảnh báo giả.

## 9. Hình ảnh

Xem các Hình 3–10 trong [README](../README.md#5-kịch-bản-1-ssh-brute-force).
