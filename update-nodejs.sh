#!/bin/bash

# Скрипт для обновления Node.js на сервере

# Настройки
SERVER_IP="95.164.53.138"
SSH_USER="root"

echo "Начинаю обновление Node.js на сервере $SERVER_IP..."
echo "Будет запрошен пароль для подключения к серверу."

# Создаем временный скрипт для выполнения на сервере
cat > remote_update.sh << 'REMOTE_SCRIPT'
#!/bin/bash

# Останавливаем n8n
echo "Останавливаю n8n..."
pm2 stop n8n
pm2 delete n8n

# Удаляем старую версию Node.js
echo "Удаляю старую версию Node.js..."
apt-get remove -y nodejs
rm -rf /etc/apt/sources.list.d/nodesource.list*

# Устанавливаем Node.js 18.x
echo "Устанавливаю Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Проверяем версию Node.js
echo "Проверяю установленную версию Node.js:"
node -v
npm -v

# Переустанавливаем глобальные пакеты
echo "Устанавливаю PM2..."
npm install -g pm2

# Переходим в директорию n8n
cd /opt/n8n

# Обновляем зависимости
echo "Обновляю зависимости n8n..."
rm -rf node_modules package-lock.json
npm install

# Запускаем n8n
echo "Запускаю n8n..."
pm2 start npm --name "n8n" -- start
pm2 save

echo "Обновление Node.js завершено!"
echo "Проверьте, что n8n теперь работает по адресу: https://dev.neuropolis.ai"
REMOTE_SCRIPT

# Делаем скрипт исполняемым
chmod +x remote_update.sh

# Копируем скрипт на сервер
echo "Копирую скрипт на сервер..."
scp remote_update.sh $SSH_USER@$SERVER_IP:/tmp/

# Выполняем скрипт на сервере
echo "Запускаю скрипт на сервере..."
ssh -t $SSH_USER@$SERVER_IP "bash /tmp/remote_update.sh"

# Удаляем временный файл
rm remote_update.sh

echo "Обновление завершено! Проверьте, что n8n теперь доступен по адресу: https://dev.neuropolis.ai" 