# Инструкция по развертыванию n8n на виртуальном сервере

## Предварительные требования

- Linux-сервер (Ubuntu/Debian рекомендуется)
- Права суперпользователя (sudo)
- Открытый порт 8080 (или другой, который вы укажете в конфигурации)

## Шаги по развертыванию

### 1. Установка необходимых пакетов

```bash
sudo apt-get update
sudo apt-get install -y curl git nodejs npm
```

### 2. Клонирование репозитория

```bash
git clone https://github.com/YOUR_USERNAME/n8n-server-deployment.git
cd n8n-server-deployment
```

### 3. Настройка конфигурации

Создайте файл `.env` в корне проекта:

```bash
cat > .env << EOL
N8N_PORT=8080
N8N_PROTOCOL=http
N8N_HOST=YOUR_SERVER_IP_OR_DOMAIN
N8N_ENCRYPTION_KEY=YOUR_SECRET_KEY
EOL
```

Замените `YOUR_SERVER_IP_OR_DOMAIN` на IP-адрес или доменное имя вашего сервера.
Замените `YOUR_SECRET_KEY` на случайную строку для шифрования.

### 4. Установка зависимостей

```bash
npm install
```

### 5. Запуск n8n

#### Для тестового запуска:

```bash
npm start
```

#### Для запуска в фоновом режиме с помощью PM2:

```bash
# Установка PM2
npm install -g pm2

# Запуск n8n через PM2
pm2 start npm --name "n8n" -- start

# Настройка автозапуска при перезагрузке
pm2 startup
pm2 save
```

## Доступ к n8n

После запуска n8n будет доступен по адресу:

```
http://YOUR_SERVER_IP_OR_DOMAIN:8080
```

## Возможные проблемы

1. **Порт занят**: Если порт 8080 занят, измените значение `N8N_PORT` в файле `.env`
2. **Доступ извне**: Убедитесь, что порт открыт в настройках брандмауэра
3. **Проблемы с соединением**: Проверьте настройки в файле `.env`, убедитесь, что `N8N_HOST` указан корректно

## Обновление n8n

Для обновления n8n выполните:

```bash
cd n8n-server-deployment
git pull
npm install
pm2 restart n8n
```
