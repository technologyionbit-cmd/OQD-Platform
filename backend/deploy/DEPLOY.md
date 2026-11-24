# نشر الباك اند على Ubuntu VPS

الستاك: Node 20+ ، PostgreSQL ، nginx (reverse proxy) ، systemd.
استبدل `api.example.com` بالدومين الحقيقي.

## 1) تجهيز السيرفر
```bash
sudo apt update && sudo apt install -y nginx postgresql postgresql-contrib git ufw
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
sudo ufw allow OpenSSH && sudo ufw allow 'Nginx Full' && sudo ufw enable
sudo adduser --system --group --home /opt/aqd aqd
sudo mkdir -p /var/lib/aqd/uploads && sudo chown aqd:aqd /var/lib/aqd/uploads && sudo chmod 700 /var/lib/aqd/uploads
```

## 2) قاعدة البيانات
```bash
sudo -u postgres psql <<'SQL'
CREATE ROLE aqd LOGIN PASSWORD 'CHANGE_DB_PASSWORD';
CREATE DATABASE aqd OWNER aqd;
\c aqd
CREATE EXTENSION IF NOT EXISTS citext;
SQL
```

## 3) رفع الكود
```bash
sudo -u aqd git clone <REPO_URL> /opt/aqd/repo
sudo ln -sfn /opt/aqd/repo/backend /opt/aqd/backend
cd /opt/aqd/backend
sudo -u aqd cp deploy/env.production.example .env
sudo chmod 600 .env && sudo -u aqd nano .env     # عبّي القيم (JWT secret, DB password, SMS, CORS)
```

## 4) بناء وتشغيل المايجريشن
```bash
cd /opt/aqd/backend
sudo -u aqd npm ci            # كامل (Prisma CLI و Nest CLI بالـ devDependencies)
sudo -u aqd npm run prisma:generate
sudo -u aqd npm run prisma:deploy
sudo -u aqd npm run build
# اختياري، بيانات أولية فقط إذا بدك:
# sudo -u aqd npm run prisma:seed
```

## 5) خدمة systemd
```bash
sudo cp deploy/aqd-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now aqd-api
sudo systemctl status aqd-api
journalctl -u aqd-api -f          # اللوغ
```

## 6) nginx + HTTPS
```bash
sudo cp deploy/nginx-aqd.conf /etc/nginx/sites-available/aqd
sudo nano /etc/nginx/sites-available/aqd       # غيّر server_name
sudo ln -s /etc/nginx/sites-available/aqd /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.example.com
```

## 7) فحص
```bash
curl https://api.example.com/v1/health
```
وبعدين غيّر عنوان الـ API بتطبيق Flutter ليشير على `https://api.example.com/v1`.

## تحديث لاحقاً
```bash
cd /opt/aqd/repo && sudo -u aqd git pull
cd /opt/aqd/backend
sudo -u aqd npm ci && sudo -u aqd npm run prisma:generate \
  && sudo -u aqd npm run prisma:deploy && sudo -u aqd npm run build
sudo systemctl restart aqd-api
```

## ملاحظات
- `.env` لا يُرفع على git أبداً. الباك اند بيرفض يشتغل بالـ production بدون الـ SMS credentials.
- نسخ احتياطي: `pg_dump aqd` + مجلد `/var/lib/aqd/uploads`.
- الـ docs (`/v1/docs`) مطفية بالـ production افتراضياً.
