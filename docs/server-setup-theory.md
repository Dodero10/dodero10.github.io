# 📚 Lý thuyết: Giải thích các thành phần trong Server Setup

Tài liệu này giải thích chi tiết về lý thuyết và chức năng của từng thành phần được sử dụng trong [Hướng dẫn Setup Server](server-setup-guide.md).

---

## 🌐 1. DNS (Domain Name System)

### DNS là gì?

DNS là hệ thống phân giải tên miền thành địa chỉ IP. Khi bạn gõ `api.yourdomain.xyz` vào trình duyệt, DNS sẽ chuyển đổi tên miền này thành địa chỉ IP (ví dụ: `123.456.789.10`) để máy tính có thể kết nối đến server.

### Cách hoạt động

```
User gõ: api.yourdomain.xyz
    ↓
DNS Server tra cứu
    ↓
Trả về IP: 123.456.789.10
    ↓
Browser kết nối đến IP đó
```

### A Record

- **Type**: A (Address)
- **Name**: Subdomain (ví dụ: `api`)
- **Value**: IP address của server
- **TTL**: Time To Live - thời gian cache (thường là Auto hoặc 300-3600 giây)

**Ví dụ:**
```
Type: A
Name: api
Value: 123.456.789.10
TTL: Auto
```

Kết quả: `api.yourdomain.xyz` → `123.456.789.10`

### Tại sao cần DNS?

- Người dùng dễ nhớ tên miền hơn là địa chỉ IP
- Có thể thay đổi IP mà không cần thay đổi domain
- Hỗ trợ load balancing (nhiều IP cho một domain)

---

## 🔒 2. SSL/TLS và HTTPS

### SSL/TLS là gì?

**SSL** (Secure Sockets Layer) và **TLS** (Transport Layer Security) là các giao thức mã hóa để bảo mật kết nối giữa client và server.

### HTTPS vs HTTP

- **HTTP**: Dữ liệu được truyền dưới dạng plain text (dễ bị đánh cắp)
- **HTTPS**: Dữ liệu được mã hóa bằng SSL/TLS (an toàn)

### SSL Certificate

SSL Certificate là một file chứng nhận số chứng minh:
- Domain thuộc về bạn
- Kết nối được mã hóa an toàn
- Được cấp bởi Certificate Authority (CA) đáng tin cậy

**Các loại certificate:**

1. **Self-signed**: Tự ký, không được trình duyệt tin cậy (cảnh báo)
2. **Let's Encrypt**: Miễn phí, tự động, được tin cậy
3. **Commercial**: Trả phí, có bảo hiểm và hỗ trợ

### Tại sao cần HTTPS?

- **Bảo mật**: Mã hóa dữ liệu, chống man-in-the-middle attack
- **Xác thực**: Đảm bảo bạn đang kết nối đúng server
- **SEO**: Google ưu tiên HTTPS
- **User Trust**: Trình duyệt hiển thị "Secure" cho HTTPS

---

## 🤖 3. Nginx Reverse Proxy

### Reverse Proxy là gì?

**Reverse Proxy** là một server đứng giữa client và backend server, nhận request từ client và chuyển tiếp đến backend server.

**So sánh với Forward Proxy:**

- **Forward Proxy**: Client → Proxy → Internet (ẩn client)
- **Reverse Proxy**: Internet → Proxy → Backend Server (ẩn backend)

### Kiến trúc

```
Client (Internet)
    ↓
Nginx Reverse Proxy (Port 443 HTTPS)
    ↓
Backend Service (localhost:8080)
```

### Tại sao dùng Nginx Reverse Proxy?

1. **SSL Termination**: Nginx xử lý SSL, backend chỉ cần HTTP
2. **Load Balancing**: Phân tải request đến nhiều backend server
3. **Caching**: Cache static files để giảm tải backend
4. **Security**: Ẩn backend server, chỉ expose Nginx
5. **Compression**: Nén response để tăng tốc độ
6. **Rate Limiting**: Giới hạn số request từ một IP
7. **Logging**: Ghi log tập trung

### Nginx vs Apache

| Tính năng | Nginx | Apache |
|-----------|-------|--------|
| Performance | Rất cao | Cao |
| Memory usage | Thấp | Trung bình |
| Concurrent connections | Rất tốt | Tốt |
| .htaccess support | Không | Có |
| Configuration | Đơn giản | Phức tạp hơn |

---

## 🔐 4. Certbot và Let's Encrypt

### Certbot là gì?

**Certbot** là công cụ tự động để lấy và gia hạn SSL certificate từ Let's Encrypt.

### Let's Encrypt là gì?

**Let's Encrypt** là Certificate Authority (CA) miễn phí, tự động, được tin cậy bởi tất cả trình duyệt.

### Cách hoạt động

1. Certbot yêu cầu certificate cho domain
2. Let's Encrypt xác thực bạn sở hữu domain (qua HTTP challenge)
3. Certificate được cấp và tự động cấu hình vào Nginx
4. Certbot tự động gia hạn certificate (mỗi 90 ngày)

### Tại sao dùng Certbot?

- **Miễn phí**: Không tốn tiền
- **Tự động**: Tự động cấu hình và gia hạn
- **Đáng tin cậy**: Được tin cậy bởi tất cả trình duyệt
- **Dễ dùng**: Chỉ cần 1 lệnh

### Auto-renewal

Certbot tự động setup timer để gia hạn certificate:

```bash
# Kiểm tra timer
sudo systemctl status certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

---

## 🛡️ 5. Firewall (UFW)

### Firewall là gì?

**Firewall** là một hệ thống bảo mật kiểm soát traffic vào/ra server dựa trên rules.

### UFW (Uncomplicated Firewall)

UFW là firewall đơn giản cho Ubuntu/Debian, wrapper của iptables.

### Các port quan trọng

- **22**: SSH (Secure Shell) - để remote vào server
- **80**: HTTP - giao thức web không mã hóa
- **443**: HTTPS - giao thức web có mã hóa

### Tại sao cần Firewall?

- **Bảo mật**: Chặn các port không cần thiết
- **Giảm attack surface**: Chỉ mở port cần thiết
- **DDoS Protection**: Giới hạn số kết nối

### UFW Commands

```bash
# Enable firewall
sudo ufw enable

# Allow port
sudo ufw allow 22/tcp

# Deny port
sudo ufw deny 80/tcp

# Check status
sudo ufw status
```

---

## ⚙️ 6. Systemd

### Systemd là gì?

**Systemd** là hệ thống quản lý service và process trên Linux hiện đại.

### Tại sao dùng Systemd?

1. **Auto-start**: Service tự động chạy khi server boot
2. **Auto-restart**: Tự động restart nếu service crash
3. **Logging**: Ghi log tập trung (`journalctl`)
4. **Dependency**: Quản lý dependencies giữa các service
5. **Resource limits**: Giới hạn CPU, memory

### Systemd Service File Structure

```ini
[Unit]
Description=Your API Service
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/app
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
```

**Giải thích:**

- `[Unit]`: Metadata về service
  - `Description`: Mô tả service
  - `After`: Chạy sau khi network sẵn sàng

- `[Service]`: Cấu hình service
  - `Type`: Loại service (simple, forking, oneshot)
  - `User`: User chạy service
  - `WorkingDirectory`: Thư mục làm việc
  - `ExecStart`: Lệnh khởi động
  - `Restart`: Tự động restart khi crash
  - `RestartSec`: Thời gian chờ trước khi restart
  - `Environment`: Biến môi trường

- `[Install]`: Cấu hình khi enable
  - `WantedBy`: Chạy ở runlevel nào

### Systemd Commands

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service (auto-start on boot)
sudo systemctl enable your-service

# Start service
sudo systemctl start your-service

# Stop service
sudo systemctl stop your-service

# Restart service
sudo systemctl restart your-service

# Check status
sudo systemctl status your-service

# View logs
sudo journalctl -u your-service -f
```

---

## 📝 7. Nginx Configuration Explained

### 7.1. Server Blocks

**Server Block** là một cấu hình cho một domain/subdomain.

```nginx
server {
    listen 443 ssl http2;
    server_name api.yourdomain.xyz;
    # ... config ...
}
```

**Giải thích:**

- `listen 443`: Lắng nghe trên port 443 (HTTPS)
- `ssl`: Bật SSL/TLS
- `http2`: Bật HTTP/2 (nhanh hơn HTTP/1.1)
- `server_name`: Domain name cho server block này

### 7.2. HTTP to HTTPS Redirect

```nginx
server {
    listen 80;
    server_name api.yourdomain.xyz;
    return 301 https://$host$request_uri;
}
```

**Giải thích:**

- `listen 80`: Lắng nghe HTTP (port 80)
- `return 301`: Redirect vĩnh viễn (301 = Permanent Redirect)
- `https://$host$request_uri`: Chuyển sang HTTPS với cùng domain và path

**Tại sao cần?**
- Bảo mật: Buộc tất cả traffic qua HTTPS
- SEO: Google ưu tiên HTTPS

### 7.3. SSL Certificate Directives

```nginx
ssl_certificate /etc/letsencrypt/live/api.yourdomain.xyz/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.xyz/privkey.pem;
include /etc/letsencrypt/options-ssl-nginx.conf;
ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
```

**Giải thích:**

- `ssl_certificate`: File certificate (public key)
- `ssl_certificate_key`: File private key
- `include`: Include file cấu hình SSL mặc định (cipher suites, protocols)
- `ssl_dhparam`: Diffie-Hellman parameters cho Perfect Forward Secrecy

### 7.4. Location Blocks

**Location Block** định nghĩa cách xử lý request cho một path cụ thể.

```nginx
location / {
    proxy_pass http://127.0.0.1:8080;
}
```

**Các loại location:**

- `location /`: Match tất cả paths
- `location /api/`: Match paths bắt đầu với `/api/`
- `location = /exact`: Match chính xác path `/exact`
- `location ~ \.php$`: Match regex (paths kết thúc bằng `.php`)

### 7.5. Proxy Pass

```nginx
proxy_pass http://127.0.0.1:8080;
```

**Giải thích:**

- Chuyển tiếp request đến backend server
- `127.0.0.1`: localhost (chỉ có thể truy cập từ server)
- `8080`: Port của backend service

**Tại sao dùng localhost?**
- Bảo mật: Backend không expose ra internet
- Chỉ Nginx mới có thể truy cập backend

### 7.6. Proxy Headers

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

**Giải thích:**

- `Host $host`: Gửi domain name đến backend (backend cần biết domain)
- `X-Real-IP $remote_addr`: IP thật của client (không phải IP của Nginx)
- `X-Forwarded-For`: Chain của proxies (nếu có nhiều proxy)
- `X-Forwarded-Proto $scheme`: Protocol (http/https) - backend cần biết client dùng HTTPS

**Tại sao cần?**
- Backend cần biết IP thật của client (cho logging, rate limiting)
- Backend cần biết client dùng HTTPS (để generate HTTPS URLs)

### 7.7. WebSocket Support

```nginx
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

**Giải thích:**

- `Upgrade`: Header để upgrade HTTP connection thành WebSocket
- `Connection "upgrade"`: Báo hiệu muốn upgrade connection

**Tại sao cần?**
- WebSocket cần persistent connection (không phải request/response)
- Streaming, real-time apps cần WebSocket

### 7.8. HTTP Version

```nginx
proxy_http_version 1.1;
```

**Giải thích:**

- Sử dụng HTTP/1.1 khi giao tiếp với backend
- HTTP/1.1 hỗ trợ keep-alive (tái sử dụng connection)

**Tại sao cần?**
- WebSocket yêu cầu HTTP/1.1
- Keep-alive giảm overhead của việc tạo connection mới

### 7.9. Buffering và Caching

```nginx
proxy_buffering off;
proxy_cache off;
```

**Giải thích:**

- `proxy_buffering off`: Tắt buffering - gửi response ngay lập tức
- `proxy_cache off`: Tắt caching

**Khi nào tắt?**
- **Streaming**: Cần gửi data ngay lập tức (LLM streaming, video streaming)
- **Real-time**: Cần real-time data, không cache

**Khi nào bật?**
- Static content: Cache để tăng tốc độ
- API responses: Cache để giảm tải backend

### 7.10. Timeouts

```nginx
proxy_connect_timeout 600s;
proxy_send_timeout 600s;
proxy_read_timeout 600s;
```

**Giải thích:**

- `proxy_connect_timeout`: Thời gian chờ kết nối đến backend (600 giây)
- `proxy_send_timeout`: Thời gian chờ gửi request đến backend (600 giây)
- `proxy_read_timeout`: Thời gian chờ đọc response từ backend (600 giây)

**Tại sao tăng timeout?**
- **LLM**: Cần thời gian dài để generate response
- **Long-running tasks**: Các task mất nhiều thời gian
- **Large files**: Upload/download file lớn

**Mặc định:** Thường là 60 giây, có thể quá ngắn cho một số use cases.

### 7.11. Security Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

**Giải thích:**

- `X-Frame-Options "SAMEORIGIN"`: Chống clickjacking - chỉ cho phép embed trong cùng domain
- `X-Content-Type-Options "nosniff"`: Chống MIME type sniffing - trình duyệt không đoán content type
- `X-XSS-Protection "1; mode=block"`: Bật XSS protection của trình duyệt

**Tại sao cần?**
- Bảo mật: Giảm các lỗ hổng bảo mật phổ biến
- Best practice: Security headers là chuẩn trong web security

### 7.12. Health Check Endpoint

```nginx
location /nginx-health {
    access_log off;
    return 200 "Nginx OK\n";
    add_header Content-Type text/plain;
}
```

**Giải thích:**

- `access_log off`: Không ghi log cho endpoint này (giảm noise)
- `return 200`: Trả về HTTP 200 OK
- `add_header Content-Type text/plain`: Set content type

**Tại sao cần?**
- Monitoring: Kiểm tra Nginx có đang chạy không
- Load balancer: Health check endpoint cho load balancer
- Debugging: Nhanh chóng kiểm tra Nginx status

---

## 🚦 8. Rate Limiting

### Rate Limiting là gì?

**Rate Limiting** là giới hạn số lượng request từ một IP trong một khoảng thời gian.

### Cách hoạt động trong Nginx

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;

location / {
    limit_req zone=api_limit burst=20 nodelay;
    # ... proxy config ...
}
```

**Giải thích:**

- `limit_req_zone`: Định nghĩa zone cho rate limiting
  - `$binary_remote_addr`: Key (IP address của client)
  - `zone=api_limit:10m`: Tên zone và kích thước memory (10MB)
  - `rate=100r/m`: Giới hạn 100 requests/phút

- `limit_req`: Áp dụng rate limiting
  - `zone=api_limit`: Sử dụng zone đã định nghĩa
  - `burst=20`: Cho phép burst 20 requests (vượt quá rate limit)
  - `nodelay`: Xử lý burst ngay lập tức (không delay)

### Tại sao cần Rate Limiting?

- **DDoS Protection**: Chống tấn công DDoS
- **API Abuse**: Ngăn abuse API
- **Resource Protection**: Bảo vệ backend khỏi quá tải
- **Cost Control**: Giảm chi phí (nếu dùng cloud service)

---

## 🔐 9. IP Whitelist

### IP Whitelist là gì?

**IP Whitelist** là chỉ cho phép một số IP cụ thể truy cập.

```nginx
location / {
    allow 192.168.1.0/24;  # Local network
    allow 1.2.3.4;         # Specific IP
    deny all;
    
    # ... proxy config ...
}
```

**Giải thích:**

- `allow`: Cho phép IP hoặc subnet
  - `192.168.1.0/24`: Subnet (tất cả IP từ 192.168.1.0 đến 192.168.1.255)
  - `1.2.3.4`: IP cụ thể
- `deny all`: Chặn tất cả IP khác

**Lưu ý:** Rules được đọc từ trên xuống, rule đầu tiên match sẽ được áp dụng.

### Tại sao cần IP Whitelist?

- **Security**: Chỉ cho phép IP đáng tin cậy
- **Internal API**: Chỉ cho phép truy cập từ internal network
- **Admin Panel**: Bảo vệ admin panel

---

## 🔑 10. Basic Authentication

### Basic Authentication là gì?

**Basic Authentication** là xác thực bằng username/password đơn giản.

```nginx
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    # ... proxy config ...
}
```

**Giải thích:**

- `auth_basic`: Bật basic authentication
- `auth_basic_user_file`: File chứa username/password (được hash)

**Tạo password file:**

```bash
sudo htpasswd -c /etc/nginx/.htpasswd username
```

### Tại sao dùng Basic Auth?

- **Simple**: Dễ setup, không cần database
- **Quick Protection**: Bảo vệ nhanh chóng
- **Internal Tools**: Phù hợp cho internal tools

**Lưu ý:** Basic Auth không an toàn bằng OAuth/JWT, nhưng đủ cho một số use cases.

---

## 📊 11. Monitoring và Logging

### Nginx Logs

**Access Log**: Ghi lại tất cả requests

```bash
sudo tail -f /var/log/nginx/access.log
```

**Format:**
```
IP - - [timestamp] "METHOD /path HTTP/version" status size "referer" "user-agent"
```

**Error Log**: Ghi lại errors

```bash
sudo tail -f /var/log/nginx/error.log
```

### Systemd Logs

```bash
# View logs của service
sudo journalctl -u your-service -f

# View logs với filter
sudo journalctl -u your-service --since "1 hour ago"
```

### Tại sao cần Logging?

- **Debugging**: Tìm lỗi khi có vấn đề
- **Monitoring**: Theo dõi traffic, errors
- **Security**: Phát hiện attacks
- **Analytics**: Phân tích usage patterns

---

## 🔄 12. SSL Certificate Auto-renewal

### Tại sao cần gia hạn?

SSL certificates từ Let's Encrypt có thời hạn **90 ngày**, cần gia hạn định kỳ.

### Cách hoạt động

Certbot tự động setup systemd timer để gia hạn:

```bash
# Kiểm tra timer
sudo systemctl status certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

**Quy trình:**

1. Timer chạy mỗi ngày
2. Kiểm tra certificate còn hạn không (còn < 30 ngày)
3. Nếu cần, tự động gia hạn
4. Reload Nginx để áp dụng certificate mới

### Tại sao tự động?

- **Không quên**: Không cần nhớ gia hạn
- **Zero downtime**: Gia hạn không làm gián đoạn service
- **Best practice**: Luôn có certificate hợp lệ

---

## 🎯 Tóm tắt

### Kiến trúc tổng thể

```
Internet
    ↓ (HTTPS - Port 443)
Domain (DNS → IP)
    ↓
Nginx Reverse Proxy
    ├─ SSL Termination
    ├─ Rate Limiting
    ├─ Security Headers
    └─ Proxy Headers
    ↓ (HTTP - Port 8080)
Backend Service (localhost)
```

### Luồng request

1. **Client** gửi request đến `https://api.yourdomain.xyz`
2. **DNS** resolve domain thành IP
3. **Firewall** kiểm tra port 443 được mở
4. **Nginx** nhận request trên port 443
5. **SSL/TLS** decrypt request
6. **Nginx** áp dụng rate limiting, security headers
7. **Nginx** forward request đến backend (localhost:8080)
8. **Backend** xử lý và trả response
9. **Nginx** nhận response, thêm security headers
10. **SSL/TLS** encrypt response
11. **Client** nhận response đã mã hóa

### Các thành phần quan trọng

| Thành phần | Chức năng | Tại sao quan trọng |
|------------|-----------|-------------------|
| **DNS** | Resolve domain → IP | Người dùng cần domain dễ nhớ |
| **SSL/TLS** | Mã hóa kết nối | Bảo mật dữ liệu |
| **Nginx** | Reverse proxy | SSL termination, load balancing, security |
| **Certbot** | Auto SSL certificate | Miễn phí, tự động |
| **Firewall** | Chặn port không cần | Giảm attack surface |
| **Systemd** | Quản lý service | Auto-start, auto-restart |

---

## 📖 Tài liệu tham khảo

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Certbot Documentation](https://eff-certbot.readthedocs.io/)
- [Systemd Documentation](https://www.freedesktop.org/software/systemd/man/)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)

---

**💡 Tip:** Đọc tài liệu này kết hợp với [Hướng dẫn Setup Server](server-setup-guide.md) để hiểu cả lý thuyết và thực hành!

