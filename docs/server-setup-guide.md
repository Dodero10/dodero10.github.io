# 🚀 Hướng dẫn đầy đủ: Public API Server qua Domain với Nginx Reverse Proxy

## 📋 Tổng quan

Expose local service (chạy trên localhost:PORT) ra internet qua domain với HTTPS.

**Kiến trúc:**

```
Internet → domain.xyz (HTTPS) → Nginx Reverse Proxy → localhost:PORT (Your Service)
```

---

## 🔧 Bước 1: Chuẩn bị

### 1.1. Kiểm tra service đang chạy

```bash
# Kiểm tra service của bạn đang chạy trên port nào (ví dụ: 8080)
curl http://localhost:8080/health

# hoặc
curl http://localhost:3000

# hoặc port bất kỳ mà service của bạn đang dùng
```

**✅ Phải thấy response từ service, không được Connection Refused**

### 1.2. Kiểm tra IP public của server

```bash
curl ifconfig.me
```

Ghi lại IP này, ví dụ: `123.456.789.10`

### 1.3. Trỏ domain về server

Vào DNS provider (Cloudflare, Namecheap, GoDaddy...) và tạo A record:

```
Type: A
Name: api (hoặc subdomain bất kỳ)
Value: 123.456.789.10 (IP public của server)
TTL: Auto
```

Bạn sẽ có subdomain: `api.yourdomain.xyz`

**Chờ 5-10 phút để DNS propagate, sau đó test:**

```bash
# Kiểm tra DNS đã trỏ đúng chưa
nslookup api.yourdomain.xyz

# hoặc
dig api.yourdomain.xyz
```

---

## 🔐 Bước 2: Cài đặt Nginx và SSL

### 2.1. Cài Nginx

```bash
sudo apt update
sudo apt install -y nginx

# Kiểm tra Nginx đang chạy
sudo systemctl status nginx

# Enable Nginx khởi động cùng hệ thống
sudo systemctl enable nginx
```

### 2.2. Cài Certbot để lấy SSL certificate (HTTPS)

```bash
# Cài Certbot
sudo apt install -y certbot python3-certbot-nginx

# Lấy SSL certificate cho domain
sudo certbot --nginx -d api.yourdomain.xyz

# Làm theo hướng dẫn:
# - Nhập email
# - Đồng ý Terms of Service (Y)
# - Chọn redirect HTTP to HTTPS (khuyến nghị: 2)
```

**✅ Certbot sẽ tự động tạo file config và SSL certificate**

---

## ⚙️ Bước 3: Cấu hình Nginx Reverse Proxy

### 3.1. Backup file config cũ (quan trọng!)

```bash
sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.backup
```

### 3.2. Xóa các file config trùng lặp (nếu có)

```bash
# Tìm tất cả file config có domain của bạn
grep -r "api.yourdomain.xyz" /etc/nginx/sites-available/
grep -r "api.yourdomain.xyz" /etc/nginx/sites-enabled/

# Nếu có file riêng (không phải default), xóa nó
sudo rm /etc/nginx/sites-enabled/your-duplicate-file
sudo rm /etc/nginx/sites-available/your-duplicate-file
```

### 3.3. Tạo file config mới

**Option A: Sử dụng file riêng (Khuyến nghị)**

```bash
sudo nano /etc/nginx/sites-available/api-server
```

Paste nội dung sau (thay `api.yourdomain.xyz` và `PORT`):

```nginx
# HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    
    server_name api.yourdomain.xyz;
    
    return 301 https://$host$request_uri;
}

# HTTPS - Main config
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    
    server_name api.yourdomain.xyz;
    
    # SSL Certificate (Certbot tự động thêm)
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.xyz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.xyz/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy to your service
    location / {
        # THAY ĐỔI PORT Ở ĐÂY (8080, 3000, 5000...)
        proxy_pass http://127.0.0.1:8080;
        
        proxy_http_version 1.1;
        
        # WebSocket support (nếu cần streaming)
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Disable buffering (tốt cho streaming/LLM)
        proxy_buffering off;
        proxy_cache off;
        
        # Increase timeouts (tốt cho LLM/long-running tasks)
        proxy_connect_timeout 600s;
        proxy_send_timeout 600s;
        proxy_read_timeout 600s;
    }
    
    # Health check endpoint (optional)
    location /nginx-health {
        access_log off;
        return 200 "Nginx OK\n";
        add_header Content-Type text/plain;
    }
}
```

**Enable site:**

```bash
# Tạo symbolic link
sudo ln -s /etc/nginx/sites-available/api-server /etc/nginx/sites-enabled/

# Test cấu hình
sudo nginx -t

# Nếu OK, reload Nginx
sudo systemctl reload nginx
```

**Option B: Sửa file default**

```bash
# Backup file default
sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.backup

# Xóa toàn bộ nội dung và tạo mới
sudo nano /etc/nginx/sites-enabled/default
```

Paste config tương tự Option A, thay đổi domain và port.

---

## 🧪 Bước 4: Test và Troubleshoot

### 4.1. Test từng bước

```bash
# 1. Test service local
curl http://localhost:8080/health

# 2. Test Nginx config
sudo nginx -t

# 3. Reload Nginx
sudo systemctl reload nginx

# 4. Test từ server (qua domain)
curl https://api.yourdomain.xyz/health

# 5. Test từ máy tính khác
curl https://api.yourdomain.xyz/health
```

### 4.2. Nếu gặp lỗi "conflicting server name"

**Nguyên nhân:** Có nhiều server blocks với cùng `server_name` trên cùng port

**Giải pháp:**

```bash
# Tìm tất cả config có domain
grep -r "api.yourdomain.xyz" /etc/nginx/

# Xóa các file duplicate, chỉ giữ 1 file duy nhất
sudo rm /etc/nginx/sites-enabled/duplicate-file

# Test lại
sudo nginx -t
sudo systemctl reload nginx
```

### 4.3. Nếu gặp lỗi 404 Not Found

**Nguyên nhân:** Server block đang dùng `try_files` thay vì `proxy_pass`

**Giải pháp:**

```bash
# Kiểm tra config của HTTPS block (port 443)
grep -A 20 "listen 443" /etc/nginx/sites-enabled/default

# Phải thấy dòng: proxy_pass http://127.0.0.1:8080
# Nếu thấy: try_files $uri $uri/ =404 --> SAI, cần sửa lại
```

### 4.4. Nếu gặp lỗi 502 Bad Gateway

**Nguyên nhân:** Service không chạy hoặc chạy sai port

```bash
# Kiểm tra service có đang chạy không
curl http://localhost:8080/health

# Kiểm tra port nào đang được dùng
sudo netstat -tlnp | grep 8080
# hoặc
sudo ss -tlnp | grep 8080

# Khởi động lại service nếu cần
```

### 4.5. Xem logs để debug

```bash
# Nginx error log
sudo tail -f /var/log/nginx/error.log

# Nginx access log
sudo tail -f /var/log/nginx/access.log

# Service log (nếu dùng systemd)
sudo journalctl -u your-service-name -f
```

---

## 🔥 Bước 5: Firewall (Quan trọng!)

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (QUAN TRỌNG - không bị khóa máy)
sudo ufw allow 22/tcp

# Allow HTTP và HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Kiểm tra status
sudo ufw status
```

---

## 🚀 Bước 6: Chạy service như systemd service (Optional nhưng khuyến nghị)

Nếu bạn muốn service tự động chạy khi server khởi động:

```bash
# Tạo service file
sudo nano /etc/systemd/system/your-service.service
```

**Ví dụ cho Node.js app:**

```ini
[Unit]
Description=Your API Service
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/your/app
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
```

**Ví dụ cho Python app:**

```ini
[Unit]
Description=Your API Service
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/your/app
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10
Environment=FLASK_ENV=production

[Install]
WantedBy=multi-user.target
```

**Enable và start service:**

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service (tự động chạy khi boot)
sudo systemctl enable your-service

# Start service
sudo systemctl start your-service

# Check status
sudo systemctl status your-service

# Xem logs
sudo journalctl -u your-service -f
```

---

## 🔒 Bước 7: Bảo mật (Optional nhưng khuyến nghị)

### 7.1. Rate limiting

Thêm vào Nginx config:

```nginx
# Thêm ở đầu file, NGOÀI block server
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;

server {
    # ... existing config ...
    
    location / {
        # Giới hạn 100 requests/phút, burst 20
        limit_req zone=api_limit burst=20 nodelay;
        
        # ... existing proxy config ...
    }
}
```

### 7.2. IP whitelist (nếu chỉ cho phép một số IP)

```nginx
location / {
    # Chỉ cho phép một số IP
    allow 192.168.1.0/24;  # Local network
    allow 1.2.3.4;         # Specific IP
    deny all;
    
    # ... existing proxy config ...
}
```

### 7.3. Basic Authentication (username/password)

```bash
# Cài htpasswd
sudo apt install apache2-utils

# Tạo password file
sudo htpasswd -c /etc/nginx/.htpasswd your-username
# Nhập password khi được hỏi
```

Thêm vào Nginx config:

```nginx
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    # ... existing proxy config ...
}
```

---

## 📊 Bước 8: Monitoring và Maintenance

### 8.1. Auto-renew SSL certificate

Certbot tự động setup cronjob, kiểm tra:

```bash
# Test renewal
sudo certbot renew --dry-run

# Xem cronjob
sudo systemctl status certbot.timer
```

### 8.2. Monitor service

```bash
# Check Nginx status
sudo systemctl status nginx

# Check your service status
sudo systemctl status your-service

# Check SSL certificate expiry
sudo certbot certificates
```

### 8.3. Backup config

```bash
# Backup Nginx config
sudo cp -r /etc/nginx /backup/nginx-$(date +%Y%m%d)

# Backup SSL certificates
sudo cp -r /etc/letsencrypt /backup/letsencrypt-$(date +%Y%m%d)
```

---

## ✅ Checklist cuối cùng

- [ ] Service chạy được trên localhost:PORT
- [ ] DNS đã trỏ về IP server
- [ ] Nginx cài đặt và chạy
- [ ] SSL certificate đã được lấy (Certbot)
- [ ] Nginx config có `proxy_pass http://127.0.0.1:PORT` trong block HTTPS (port 443)
- [ ] Không có file config trùng lặp
- [ ] `sudo nginx -t` pass
- [ ] `sudo systemctl reload nginx` thành công
- [ ] `curl https://api.yourdomain.xyz/health` trả về kết quả đúng
- [ ] Firewall đã mở port 80, 443, 22
- [ ] Service chạy như systemd service (optional)

---

## 🆘 Common Issues và Solutions

| Lỗi | Nguyên nhân | Giải pháp |
|-----|------------|-----------|
| `404 Not Found` | Block HTTPS dùng `try_files` thay vì `proxy_pass` | Sửa block HTTPS, thêm `proxy_pass http://127.0.0.1:PORT` |
| `502 Bad Gateway` | Service không chạy hoặc sai port | Check `curl localhost:PORT`, restart service |
| `Connection refused` | Firewall block hoặc service không listen | Check firewall, check service đang listen đúng port |
| `Conflicting server name` | Nhiều server blocks cùng domain | Xóa file config duplicate |
| `SSL certificate error` | SSL chưa được cài hoặc expired | Chạy `sudo certbot --nginx -d domain.xyz` |

---

**🎉 Hoàn thành! API của bạn đã được public ra internet với HTTPS!**

Test bằng cách gọi từ máy tính khác:

```bash
curl https://api.yourdomain.xyz/your-endpoint
```

