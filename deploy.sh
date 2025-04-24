#!/bin/bash

# Скрипт для развертывания n8n на виртуальном сервере

# Установка зависимостей
echo "Установка необходимых пакетов..."
apt-get update
apt-get install -y curl git nodejs npm

# Клонирование репозитория
echo "Клонирование репозитория с GitHub..."
git clone https://github.com/YOUR_USERNAME/n8n-server-deployment.git
cd n8n-server-deployment

# Установка зависимостей n8n
echo "Установка зависимостей n8n..."
npm install

# Создание файла конфигурации
echo "Настройка конфигурации..."
cat > .env << EOL
N8N_PORT=8080
N8N_PROTOCOL=http
N8N_HOST=localhost
N8N_ENCRYPTION_KEY=YOUR_ENCRYPTION_KEY
EOL

# Запуск n8n
echo "Запуск n8n..."
npm start 