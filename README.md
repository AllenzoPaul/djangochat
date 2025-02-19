# Django Chat Application Deployment using Gunicorn and Nginx

## Prerequisites

- Ubuntu Server
- Python & Django installed
- PostgreSQL database configured
- Domain name (optional)

---

## 1. Update & Install Required Packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install python3-pip python3-venv nginx postgresql postgresql-contrib -y
```

---

## 2. Set Up PostgreSQL

```bash
sudo -u postgres psql
```

Inside PostgreSQL shell, create a database and user:

```sql
CREATE DATABASE djangochat;
CREATE USER djangouser WITH PASSWORD 'yourpassword';
ALTER ROLE djangouser SET client_encoding TO 'utf8';
ALTER ROLE djangouser SET default_transaction_isolation TO 'read committed';
ALTER ROLE djangouser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE djangochat TO djangouser;
\q
```

Update Django **settings.py**:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'djangochat',
        'USER': 'djangouser',
        'PASSWORD': 'yourpassword',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

Apply migrations:

```bash
python manage.py migrate
```

---

## 3. Set Up Virtual Environment & Install Dependencies

```bash
cd /home/allenzo/djangochat
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 4. Collect Static Files & Set Up Media Files

```bash
python manage.py collectstatic
```

Update **settings.py**:

```python
STATIC_ROOT = BASE_DIR / "staticfiles"
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / "media"
```

Create directories:

```bash
mkdir staticfiles media
chmod -R 755 staticfiles media
```

---

## 5. Set Up Gunicorn

Install Gunicorn:

```bash
pip install gunicorn
```

Run Gunicorn manually to test:

```bash
gunicorn --bind 0.0.0.0:8000 djangochat.wsgi:application
```

To run Gunicorn as a service, create a systemd file:

```bash
sudo nano /etc/systemd/system/djangochat.service
```

Paste this content:

```ini
[Unit]
Description=Django Gunicorn Service
After=network.target

[Service]
User=allenzo
Group=www-data
WorkingDirectory=/home/allenzo/djangochat
ExecStart=/home/allenzo/djangochat/venv/bin/gunicorn --workers 3 --bind unix:/home/allenzo/djangochat/djangochat.sock djangochat.wsgi:application

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable djangochat
sudo systemctl start djangochat
sudo systemctl status djangochat
```

---

## 6. Configure Nginx as a Reverse Proxy

Create a new Nginx configuration file:

```bash
sudo nano /etc/nginx/sites-available/djangochat
```

Paste this content:

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location /static/ {
        root /home/allenzo/djangochat;
    }

    location /media/ {
        root /home/allenzo/djangochat;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/allenzo/djangochat/djangochat.sock;
    }
}
```

Enable the configuration:

```bash
sudo ln -s /etc/nginx/sites-available/djangochat /etc/nginx/sites-enabled
```

Test Nginx and restart:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

## 7. Secure with SSL (Optional but Recommended)

Install Certbot for Let's Encrypt:

```bash
sudo apt install certbot python3-certbot-nginx -y
```

Get an SSL certificate:

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Set up auto-renewal:

```bash
sudo certbot renew --dry-run
```

---

## 8. Check if Everything is Running

- **Check Nginx:**
  ```bash
  sudo systemctl status nginx
  ```

- **Check Gunicorn:**
  ```bash
  sudo systemctl status djangochat
  ```

- **Check if website is running:**
  ```bash
  curl -I http://yourdomain.com
  ```

---

## 9. Restart Services if Needed

```bash
sudo systemctl restart gunicorn
sudo systemctl restart nginx
```

---

##  Deployment Complete!

Your Django project is now running with **Gunicorn**, **Nginx**, and **PostgreSQL**. 
