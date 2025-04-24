#!/bin/bash

# Скрипт для настройки домена и SSL для n8n на сервере

# Настройки
SERVER_IP="95.164.53.138"
SSH_USER="root"
DOMAIN="vm10210.hosted-by.qwins.co"

echo "Настраиваю домен $DOMAIN для n8n на сервере $SERVER_IP..."

# Подключаемся к серверу и выполняем настройку
ssh $SSH_USER@$SERVER_IP << EOL
echo "Подключение установлено, начинаю настройку..."

# Установка Nginx и Certbot для SSL
echo "Устанавливаю Nginx и Certbot..."
apt-get update
apt-get install -y nginx certbot python3-certbot-nginx

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

# Проверяем конфигурацию Nginx
nginx -t

# Если конфигурация верна, перезапускаем Nginx
if [ $? -eq 0 ]; then
    systemctl restart nginx
    
    # Настраиваем брандмауэр
    echo "Настраиваю брандмауэр..."
    apt-get install -y ufw
    ufw allow 'Nginx Full'
    ufw allow ssh
    ufw --force enable
    
    # Получаем SSL-сертификат с помощью Certbot
    echo "Получаю SSL-сертификат..."
    certbot --nginx --non-interactive --agree-tos --email admin@example.com -d $DOMAIN
    
    # Настраиваем автоматическое обновление сертификата
    echo "0 12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
    
    # Обновляем конфигурацию n8n для работы с доменом
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
    
    # Перезапускаем n8n
    echo "Перезапускаю n8n..."
    pm2 restart n8n
    
    echo "Настройка успешно завершена!"
    echo "n8n теперь доступен по адресу: https://$DOMAIN"
else
    echo "Ошибка в конфигурации Nginx."
fi
EOL

# Проверка результата
if [ $? -eq 0 ]; then
    echo "Настройка домена успешно завершена!"
    echo "n8n теперь доступен по адресу: https://$DOMAIN"
else
    echo "Во время настройки домена произошла ошибка. Проверьте логи выше."
fi 