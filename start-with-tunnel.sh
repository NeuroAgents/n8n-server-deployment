#!/bin/bash

# Скрипт для запуска n8n с туннелем для доступа извне
# Требуется установка утилиты ngrok (https://ngrok.com/)

# Остановить все текущие процессы ngrok и n8n
pkill -f ngrok || true
pkill -f n8n || true

# Подождать, пока все процессы остановятся
sleep 3

# Проверить, установлен ли ngrok
if ! command -v ngrok &> /dev/null; then
    echo "Ошибка: ngrok не установлен. Пожалуйста, установите ngrok (https://ngrok.com/download)"
    exit 1
fi

# Запустить ngrok на порту 8080
echo "Запуск ngrok на порту 8080..."
ngrok http 8080 > /dev/null &

# Подождать, пока ngrok запустится
sleep 5

# Получить URL ngrok
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'https://[^"]*')

if [ -z "$NGROK_URL" ]; then
  echo "Ошибка: Не удалось получить URL ngrok."
  exit 1
fi

echo "Получен URL ngrok: $NGROK_URL"

# Проверить существование файла .env
if [ ! -f .env ]; then
    echo "Создание файла .env..."
    touch .env
fi

# Обновить файл .env с URL ngrok
sed -i.bak "s|WEBHOOK_TUNNEL_URL=.*|WEBHOOK_TUNNEL_URL=$NGROK_URL|g" .env 2>/dev/null || echo "WEBHOOK_TUNNEL_URL=$NGROK_URL" >> .env
sed -i.bak "s|N8N_HOST_WEBHOOK_TUNNEL_URL=.*|N8N_HOST_WEBHOOK_TUNNEL_URL=$NGROK_URL|g" .env 2>/dev/null || echo "N8N_HOST_WEBHOOK_TUNNEL_URL=$NGROK_URL" >> .env
sed -i.bak "s|WEBHOOK_URL=.*|WEBHOOK_URL=$NGROK_URL/|g" .env 2>/dev/null || echo "WEBHOOK_URL=$NGROK_URL/" >> .env
sed -i.bak "s|N8N_HOST=.*|N8N_HOST=${NGROK_URL#https://}|g" .env 2>/dev/null || echo "N8N_HOST=${NGROK_URL#https://}" >> .env
sed -i.bak "s|N8N_EDITOR_BASE_URL=.*|N8N_EDITOR_BASE_URL=$NGROK_URL|g" .env 2>/dev/null || echo "N8N_EDITOR_BASE_URL=$NGROK_URL" >> .env

# Удалить резервные файлы .env.bak, если они созданы
rm -f .env.bak

echo "Файл .env обновлен с URL ngrok: $NGROK_URL"

# Запустить n8n
echo "Запуск n8n..."
npm start 