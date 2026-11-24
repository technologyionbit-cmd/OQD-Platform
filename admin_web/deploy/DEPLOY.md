# نشر لوحة الأدمن (admin.oqdjo.com)

السيرفر: Ubuntu 24.04 (Contabo)، nginx + pm2. الباك اند `aqd-backend` على `127.0.0.1:3001`، والدومين `oqdjo.com` فيه HTTPS.
**ما بنلمس أي تطبيق ثاني على السيرفر**: بنضيف ملف nginx جديد وبس، وبنعدّل سطر `CORS_ORIGINS` بملف `.env` تبع الباك اند.
كل الأوامر بدون nano (cat / sed بس). استبدل `<REPO>` بمسار الريبو على السيرفر.

## 0) DNS (مرة وحدة، من لوحة الدومين)
سجل `A` للاسم `admin` يشير لنفس IP السيرفر (وسجل `AAAA` إذا عندك IPv6). تأكد:
```bash
dig +short admin.oqdjo.com
```

## 1) الباك اند: migration + CORS (مرة وحدة، وبعدها مع كل تحديث)
```bash
cd <REPO>/backend
git pull
npm ci
npx prisma generate
npx prisma migrate deploy        # بينفّذ add_audit_logs و user_suspension
npm run build
```
أضف أصل اللوحة لـ `CORS_ORIGINS` (بدون wildcard، وبدون مسح الأصول الموجودة). شوف القيمة الحالية أول:
```bash
grep '^CORS_ORIGINS=' .env
```
ثم أضف الأصل الجديد بآخر القيمة (مثال: إذا كانت `https://oqdjo.com`):
```bash
sed -i 's|^CORS_ORIGINS=\(.*\)$|CORS_ORIGINS=\1,https://admin.oqdjo.com|' .env
grep '^CORS_ORIGINS=' .env       # تأكد إنه ظهر مرة وحدة
```
> لا تشغّل أمر `sed` مرتين (بيكرر الأصل). وتأكد إنه `NODE_ENV=production` و`TRUST_PROXY=1` موجودين.

أعد تشغيل الباك اند:
```bash
pm2 restart aqd-backend --update-env
pm2 logs aqd-backend --lines 20 --nostream
curl -s https://oqdjo.com/v1/health
```

## 2) ترقية أول حساب لأدمن (مرة وحدة)
الأدمن ما بيسجّل نفسه. غيّر دور حساب موجود (بدّل الرقم برقمك بصيغة +9627XXXXXXXX):
```bash
sudo -u postgres psql aqd_prod -c "UPDATE users SET role='admin' WHERE phone='+9627XXXXXXXX' RETURNING id, full_name, role;"
```
(اسم القاعدة عندك `aqd_prod` حسب `DATABASE_URL`.)

## 3) بناء اللوحة (على جهازك أو على السيرفر إذا فيه Flutter)
```bash
cd <REPO>/admin_web
flutter pub get
dart run build_runner build
flutter gen-l10n
flutter build web --release --wasm
```
الأمر بيعطي نسخة wasm مع fallback تلقائي لـ JavaScript للمتصفحات اللي ما بتدعمها. العنوان الافتراضي للـ API هو `https://oqdjo.com/v1`؛ لتغييره: `--dart-define=API_BASE_URL=...`.

## 4) رفع الملفات
من جهازك (إذا البناء عندك):
```bash
ssh <USER>@<SERVER> "sudo mkdir -p /var/www/admin.oqdjo.com && sudo chown \$USER /var/www/admin.oqdjo.com"
rsync -az --delete build/web/ <USER>@<SERVER>:/var/www/admin.oqdjo.com/
```
(`--delete` بيمسح فقط داخل `/var/www/admin.oqdjo.com/`، مش أي مجلد ثاني.)

## 5) nginx
```bash
sudo cp <REPO>/admin_web/deploy/admin-nocache.conf /etc/nginx/snippets/admin-nocache.conf
sudo cp <REPO>/admin_web/deploy/nginx-admin.conf /etc/nginx/sites-available/admin.oqdjo.com
sudo ln -s /etc/nginx/sites-available/admin.oqdjo.com /etc/nginx/sites-enabled/admin.oqdjo.com
sudo nginx -t && sudo systemctl reload nginx
```
إذا `nginx -t` فشل، **لا تعمل reload** وارجع شوف الخطأ؛ الملفات الثانية ما تأثرت.

## 6) HTTPS
```bash
sudo certbot --nginx -d admin.oqdjo.com
sudo nginx -t && sudo systemctl reload nginx
```
بعدها فعّل HSTS للدومين الفرعي هاد بس (بعد ما تتأكد إنه HTTPS شغال):
```bash
sudo sed -i 's|    # (HSTS is added by you once HTTPS works: see DEPLOY.md.)|    add_header Strict-Transport-Security "max-age=31536000" always;|' /etc/nginx/sites-available/admin.oqdjo.com
sudo nginx -t && sudo systemctl reload nginx
```
> ملاحظة: بنفس `server` فيه `add_header` للـ HSTS لكن الـ locations اللي بتستخدم snippet الـ nocache ما بترث الهيدر. لو بدك HSTS على index.html كمان أضف السطر نفسه لـ `/etc/nginx/snippets/admin-nocache.conf`.

## 7) فحص
```bash
curl -sI https://admin.oqdjo.com/ | grep -iE "HTTP|content-security|x-frame|cache-control"
curl -s -o /dev/null -w "%{http_code}\n" https://admin.oqdjo.com/users        # 200 (SPA fallback)
# الباك اند لازم يرفض الدخول بدون الهيدر (403) ويقبل مع الهيدر:
curl -s -X POST https://oqdjo.com/v1/admin-auth/refresh -H 'Origin: https://admin.oqdjo.com'
curl -s -X POST https://oqdjo.com/v1/admin-auth/refresh -H 'Origin: https://admin.oqdjo.com' -H 'X-Requested-With: aqd-admin'   # 401 (ما في cookie)
```
بعدها افتح `https://admin.oqdjo.com` وسجّل دخول بحساب الأدمن. تأكد من DevTools > Application > Cookies إنه `aqd_admin_rt` موجود وعليه `HttpOnly` و`Secure` و`SameSite=Strict`.

## تحديث لاحق (اللوحة فقط)
```bash
cd <REPO>/admin_web && git pull && flutter build web --release --wasm
rsync -az --delete build/web/ <USER>@<SERVER>:/var/www/admin.oqdjo.com/
```

## ملاحظات
- الـ CSP بالـ nginx مكتوب حسب ما يحتاجه Flutter (wasm + blob workers). إذا شاشة بيضا بالمتصفح، افتح Console وشوف أي مصدر انحجب، وعدّل الـ CSP بملفين (`nginx-admin.conf` و`admin-nocache.conf`).
- بعد كل بناء جديد المتصفح بيجيب `index.html` و`flutter_bootstrap.js` من جديد (no-cache) وباقي الملفات بتتحدّث عبر الـ service worker.
- الـ cookie محصورة بـ `Path=/v1/admin-auth` على `oqdjo.com`، و`admin.oqdjo.com` موقع شقيق (same-site) فبتنبعت مع طلبات الـ API.
