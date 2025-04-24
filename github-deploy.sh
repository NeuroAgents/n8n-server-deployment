#!/bin/bash

# Скрипт для деплоя n8n на сервер с использованием GitHub репозитория

# Настройки сервера
SERVER_IP="95.164.53.138"
SSH_USER="root"
SERVER_DOMAIN="vm10210.hosted-by.qwins.co"
GITHUB_REPO="https://github.com/NeuroAgents/n8n-server-deployment.git"

echo "Начинаю деплой n8n на сервер $SERVER_DOMAIN ($SERVER_IP) из GitHub репозитория..."

# Подготовка удаленного скрипта
echo "Подключаюсь к серверу и выполняю установку с GitHub..."

ssh $SSH_USER@$SERVER_IP << EOL
echo "Подключение установлено, начинаю установку..."

# Обновление пакетов
echo "Обновление системных пакетов..."
apt-get update
apt-get install -y git curl

# Клонирование репозитория
echo "Клонирование GitHub репозитория..."
mkdir -p /opt
cd /opt
if [ -d "n8n" ]; then
  echo "Директория n8n уже существует, обновляю репозиторий..."
  cd n8n
  git pull
else
  echo "Клонирую репозиторий в директорию n8n..."
  git clone $GITHUB_REPO n8n
  cd n8n
fi

# Запуск скрипта установки
echo "Запуск скрипта установки..."
chmod +x setup-server.sh
./setup-server.sh

echo "Установка завершена! n8n должен быть доступен по адресу: http://$SERVER_IP:8080"
EOL

# Проверка результата
if [ $? -eq 0 ]; then
  echo "Деплой успешно завершен!"
  echo "n8n теперь доступен по адресу: http://$SERVER_IP:8080"
else
  echo "Во время деплоя произошла ошибка. Проверьте логи выше."
fi 