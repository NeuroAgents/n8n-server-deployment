#!/bin/bash

# Скрипт для развертывания n8n на домене dev.neuropolis.ai

# Настройки
SERVER_IP="95.164.53.138"
SSH_USER="root"
DOMAIN="dev.neuropolis.ai"
EMAIL="admin@neuropolis.ai"

echo "Начинаю развертывание n8n на домене $DOMAIN (сервер $SERVER_IP)..."
echo "Будет запрошен пароль для подключения к серверу."

# Создаем временный скрипт для выполнения на сервере
cat > remote_deploy.sh << 'REMOTE_SCRIPT'
#!/bin/bash

# Настройки домена
DOMAIN="dev.neuropolis.ai"
EMAIL="admin@neuropolis.ai"

echo "Начинаю настройку на сервере..."

# Проверяем DNS
echo "Проверяю DNS-настройки..."
RESOLVED_IP=$(dig +short $DOMAIN A)
SERVER_IP=$(hostname -I | awk '{print $1}')

echo "Домен $DOMAIN указывает на IP: $RESOLVED_IP"
echo "IP сервера: $SERVER_IP"

if [ -z "$RESOLVED_IP" ]; then
    echo "ОШИБКА: Домен $DOMAIN не настроен в DNS!"
    echo "Необходимо настроить A-запись для домена, указывающую на IP $SERVER_IP"
    exit 1
fi

# Обновление пакетов
echo "Обновляю системные пакеты..."
apt-get update
apt-get upgrade -y

# Установка необходимых пакетов
echo "Устанавливаю необходимые пакеты..."
apt-get install -y curl git build-essential nginx certbot python3-certbot-nginx

# Настройка Nginx для проксирования запросов к n8n
echo "Настраиваю Nginx..."
cat > /etc/nginx/sites-available/$DOMAIN << NGINX_CONF
server {
    server_name $DOMAIN;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINX_CONF

# Создаем символическую ссылку для активации конфигурации
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверяем конфигурацию Nginx
nginx -t

# Если конфигурация верна, перезапускаем Nginx
if [ $? -eq 0 ]; then
    # Перезапускаем Nginx
    systemctl restart nginx
    
    # Настраиваем брандмауэр
    echo "Настраиваю брандмауэр..."
    apt-get install -y ufw
    ufw allow 'Nginx Full'
    ufw allow ssh
    ufw allow 8080/tcp
    ufw --force enable
    
    # Получаем SSL-сертификат с помощью Certbot
    echo "Получаю SSL-сертификат..."
    certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN
    
    # Настраиваем автоматическое обновление сертификата
    echo "0 12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
    
    # Проверяем, установлен ли Node.js
    if ! command -v node &> /dev/null; then
        echo "Устанавливаю Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
        apt-get install -y nodejs
    fi
    
    # Проверяем, установлен ли PM2
    if ! command -v pm2 &> /dev/null; then
        echo "Устанавливаю PM2..."
        npm install -g pm2
    fi
    
    # Создаем директорию для n8n, если она не существует
    if [ ! -d "/opt/n8n" ]; then
        echo "Создаю директорию для n8n..."
        mkdir -p /opt/n8n
        cd /opt/n8n
        
        # Инициализация проекта
        echo "Инициализация проекта n8n..."
        cat > package.json << EOL
{
  "name": "n8n-server",
  "version": "1.0.0",
  "description": "n8n Workflow Automation",
  "scripts": {
    "start": "n8n start"
  },
  "dependencies": {
    "n8n": "^1.86.1"
  }
}
EOL
        
        # Установка зависимостей
        echo "Установка зависимостей n8n..."
        npm install
        
        # Генерация случайного ключа шифрования
        ENCRYPTION_KEY=$(openssl rand -hex 24)
        
        # Создание файла окружения
        echo "Создание файла конфигурации..."
        cat > .env << EOL
N8N_PORT=8080
N8N_PROTOCOL=https
N8N_HOST=$DOMAIN
N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
N8N_HOST_WEBHOOK_TUNNEL_URL=https://$DOMAIN
WEBHOOK_URL=https://$DOMAIN/
DB_TYPE=sqlite
DB_PATH=./database.sqlite
N8N_DIAGNOSTICS_ENABLED=false
N8N_HIRING_BANNER_ENABLED=false
N8N_VERSION_NOTIFICATIONS_ENABLED=false
EOL
    else
        # Если директория существует, обновляем конфигурацию
        echo "Обновляю конфигурацию n8n..."
        cd /opt/n8n
        
        # Обновляем .env файл для работы с доменом
        sed -i "s|N8N_HOST=.*|N8N_HOST=$DOMAIN|g" .env
        sed -i "s|N8N_PROTOCOL=.*|N8N_PROTOCOL=https|g" .env
        
        if ! grep -q "N8N_HOST_WEBHOOK_TUNNEL_URL" .env; then
            echo "N8N_HOST_WEBHOOK_TUNNEL_URL=https://$DOMAIN" >> .env
        else
            sed -i "s|N8N_HOST_WEBHOOK_TUNNEL_URL=.*|N8N_HOST_WEBHOOK_TUNNEL_URL=https://$DOMAIN|g" .env
        fi
        
        if ! grep -q "WEBHOOK_URL" .env; then
            echo "WEBHOOK_URL=https://$DOMAIN/" >> .env
        else
            sed -i "s|WEBHOOK_URL=.*|WEBHOOK_URL=https://$DOMAIN/|g" .env
        fi
    fi
    
    # Настройка автозапуска с PM2
    echo "Настраиваю автозапуск n8n..."
    cd /opt/n8n
    pm2 start npm --name "n8n" -- start
    pm2 save
    
    # Настройка автозапуска PM2
    pm2 startup
    
    echo "Настройка успешно завершена!"
    echo "n8n теперь доступен по адресу: https://$DOMAIN"
else
    echo "Ошибка в конфигурации Nginx."
fi
REMOTE_SCRIPT

# Делаем скрипт исполняемым
chmod +x remote_deploy.sh

# Копируем скрипт на сервер
echo "Копирую скрипт на сервер..."
scp remote_deploy.sh $SSH_USER@$SERVER_IP:/tmp/

# Выполняем скрипт на сервере
echo "Запускаю скрипт на сервере..."
ssh -t $SSH_USER@$SERVER_IP "bash /tmp/remote_deploy.sh"

# Удаляем временный файл
rm remote_deploy.sh

echo "=============================================================================="
echo "ВАЖНО: Перед запуском скрипта убедитесь, что домен $DOMAIN настроен в DNS"
echo "и указывает на IP-адрес сервера $SERVER_IP"
echo "==============================================================================" 