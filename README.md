# WAZUH-SHUFFLE-DFIR-IRIS-SOC-LAB
# Hệ thống giám sát Endpoint tích hợp phản ứng sự cố tự động và quản lý ticket

> Giám sát endpoint Windows bằng **Wazuh SIEM**, tự động hóa tiếp nhận cảnh báo qua **Shuffle SOAR**, quản lý case trên **TheHive** và gửi thông báo qua **Telegram**.

**Công nghệ:** Wazuh · Shuffle · TheHive · Telegram · Windows · Ubuntu · Kali Linux
**Thời gian thực hiện:** [MM/YYYY – MM/YYYY]
**Tác giả:** Hồ Sỹ Huân

---

## 1. Tóm tắt

[3-4 câu: bài toán, giải pháp, công nghệ, kết quả chính.]

Ví dụ: Dự án xây dựng một luồng SOC thu nhỏ: Wazuh phát hiện hành vi bất thường trên endpoint Windows, gửi cảnh báo qua Webhook sang Shuffle, Shuffle tự động tạo case trên TheHive và gửi thông báo Telegram. Hệ thống được kiểm thử với [2] kịch bản tấn công (SSH Brute Force, Web Shell), thời gian từ lúc có cảnh báo đến lúc tạo ticket là [X] giây.

## 2. Mục tiêu và phạm vi

**Mục tiêu**
- [Giảm thao tác thủ công khi tiếp nhận và ghi nhận cảnh báo]
- [Chuẩn hóa thông tin sự cố vào ticket]
- [Mục tiêu khác]

**Phạm vi**
- Bao gồm: [giám sát endpoint Windows, tự động tạo ticket, thông báo]
- Không bao gồm: [chặn tự động, tích hợp threat intel, môi trường production]

## 3. Kiến trúc hệ thống

![Sơ đồ kiến trúc](images/architecture.png)

*Hình 1: Luồng dữ liệu từ endpoint đến ticket và thông báo.*

```
Endpoint (Wazuh Agent) → Wazuh Manager → Webhook → Shuffle → TheHive
                                                          └→ Telegram
```

**Các máy trong lab**

| Máy | Hệ điều hành | Vai trò | IP (nội bộ lab) |
|---|---|---|---|
| wazuh-server | Ubuntu [xx.04] | Wazuh Manager / Indexer / Dashboard | [192.168.x.x] |
| win-endpoint | Windows [10/11] | Endpoint được giám sát (Wazuh Agent) | [192.168.x.x] |
| shuffle-server | Ubuntu | Shuffle SOAR | [192.168.x.x] |
| thehive-server | Ubuntu | TheHive | [192.168.x.x] |
| kali | Kali Linux | Máy tấn công mô phỏng | [192.168.x.x] |

## 4. Triển khai

### 4.1. Cài đặt Wazuh và agent
- [Phiên bản Wazuh đã dùng]
- [Cách cài agent trên Windows, đăng ký với Manager]
- [Cấu hình bổ sung nếu có, ví dụ Sysmon]

![Dashboard Wazuh](images/wazuh-dashboard.png)

*Hình 2: Agent Windows đã kết nối thành công.*

### 4.2. Cấu hình gửi cảnh báo qua Webhook
- [Khối `<integration>` trong `ossec.conf`, mức rule tối thiểu gửi đi]
- [Vấn đề gặp phải và cách xử lý]

```xml
<!-- Trích đoạn cấu hình (đã xóa thông tin nhạy cảm) -->
<integration>
  <name>shuffle</name>
  <hook_url>http://[SHUFFLE_IP]:3001/api/v1/hooks/[HOOK_ID]</hook_url>
  <level>[3]</level>
  <alert_format>json</alert_format>
</integration>
```

### 4.3. Xây dựng workflow trên Shuffle
Mô tả từng bước (node) trong workflow:

1. **Webhook**: nhận cảnh báo JSON từ Wazuh.
2. **[Trích xuất]**: lấy Rule ID, severity, source IP, timestamp, agent.
3. **[Enrichment (nếu có)]**: [VirusTotal / AbuseIPDB ...]
4. **TheHive**: tạo case/alert với các trường [title, severity, tags, mô tả].
5. **Telegram**: gửi tin nhắn tóm tắt sự cố.

![Workflow Shuffle](images/shuffle-workflow.png)

*Hình 3: Workflow tự động xử lý cảnh báo.*

### 4.4. Kết nối TheHive và Telegram
- [Cách tạo API key TheHive, bot Telegram, chat ID. KHÔNG đưa token thật vào repo]

![Case trên TheHive](images/thehive-case.png)

*Hình 4: Case được tạo tự động từ cảnh báo Wazuh.*

## 5. Kịch bản kiểm thử

### Kịch bản 1: SSH Brute Force
- **Mô phỏng:** [công cụ và lệnh, ví dụ Hydra từ Kali nhắm vào máy mục tiêu]
- **Kết quả mong đợi:** [Wazuh phát hiện nhiều lần đăng nhập thất bại]
- **Kết quả thực tế:** [Rule ID nào kích hoạt, mức severity]
- **Chi tiết:** xem [incident-reports/ssh-brute-force.md](incident-reports/ssh-brute-force.md)

### Kịch bản 2: Web Shell
- **Mô phỏng:** [cách đặt web shell, cách truy cập]
- **Kết quả mong đợi:** [Wazuh phát hiện file/hành vi đáng ngờ]
- **Kết quả thực tế:** [Rule ID, severity]
- **Chi tiết:** xem [incident-reports/web-shell.md](incident-reports/web-shell.md)

## 6. Kết quả và đánh giá

| Chỉ số | Giá trị |
|---|---|
| Số kịch bản phát hiện được / đã thử | [2 / 2] |
| Thời gian từ tấn công đến cảnh báo | [X giây] |
| Thời gian từ cảnh báo đến ticket (tự động) | [X giây] |
| Thời gian làm thủ công tương đương | [X phút] |
| Số cảnh báo giả (false positive) ghi nhận | [X] |

[1-2 đoạn nhận xét ngắn: hệ thống làm tốt gì, số liệu nói lên điều gì.]

## 7. Hạn chế và hướng phát triển

- [Chưa có enrichment bằng threat intelligence]
- [Chưa có playbook tự động ngăn chặn (chặn IP, cô lập máy)]
- [Mới kiểm thử trên môi trường lab, số kịch bản còn ít]
- Hướng phát triển: [thêm kịch bản, ánh xạ MITRE ATT&CK đầy đủ, viết custom rule...]

## 8. Bài học rút ra

- [Điều bạn học được về SIEM/SOAR]
- [Khó khăn lớn nhất và cách giải quyết]

## 9. Tài liệu tham khảo

- Wazuh Documentation: https://documentation.wazuh.com
- Shuffle Documentation: https://shuffler.io/docs
- TheHive Documentation: https://docs.strangebee.com
- MITRE ATT&CK: https://attack.mitre.org

---

> **Lưu ý:** Dự án thực hiện trong môi trường lab cô lập, chỉ phục vụ mục đích học tập.
