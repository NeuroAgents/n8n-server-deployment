#!/bin/bash

# Скрипт для настройки сервера и установки n8n

# Обновление пакетов
echo "Обновление системных пакетов..."
apt-get update
apt-get upgrade -y

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
apt-get install -y curl git build-essential

# Установка Node.js и npm
echo "Установка Node.js и npm..."
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Проверка версий
echo "Проверка установленных версий:"
node -v
npm -v

# Установка PM2 для управления процессами
echo "Установка PM2..."
npm install -g pm2

# Настройка firewall
echo "Настройка firewall..."
apt-get install -y ufw
ufw allow ssh
ufw allow 8080/tcp
ufw --force enable

# Создание директории для n8n
echo "Создание директории для n8n..."
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

# Создание файла окружения
echo "Создание файла конфигурации..."
cat > .env << EOL
N8N_PORT=8080
N8N_PROTOCOL=http
N8N_HOST=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
N8N_ENCRYPTION_KEY=$(openssl rand -hex 24)
DB_TYPE=sqlite
DB_PATH=./database.sqlite
N8N_DIAGNOSTICS_ENABLED=false
N8N_HIRING_BANNER_ENABLED=false
N8N_VERSION_NOTIFICATIONS_ENABLED=false
EOL

# Настройка PM2 для автоматического запуска
echo "Настройка автозапуска n8n..."
pm2 start npm --name "n8n" -- start
pm2 startup
pm2 save

echo "Настройка сервера завершена!"
echo "n8n доступен по адресу: http://$(curl -s ifconfig.me || hostname -I | awk '{print $1}'):8080"
echo "Для управления используйте команды:"
echo "  - Старт:    pm2 start n8n"
echo "  - Стоп:     pm2 stop n8n"
echo "  - Рестарт:  pm2 restart n8n"
echo "  - Статус:   pm2 status"
echo "  - Логи:     pm2 logs n8n" 