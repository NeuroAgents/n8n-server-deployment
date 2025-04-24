# Руководство по использованию n8n Server Deployment

Данное руководство поможет вам правильно настроить и использовать этот репозиторий для развертывания n8n на виртуальном сервере.

## Содержание

1. [Настройка репозитория](#настройка-репозитория)
2. [Локальное использование](#локальное-использование)
3. [Настройка сервера](#настройка-сервера)
4. [Подготовка GitHub Actions](#подготовка-github-actions)
5. [Рабочие процессы n8n](#рабочие-процессы-n8n)
6. [Работа с базами данных](#работа-с-базами-данных)
7. [Использование ngrok](#использование-ngrok)

## Настройка репозитория

### Вариант 1: Загрузка в свой репозиторий

Выполните следующие шаги:

```bash
# Клонирование репозитория локально
git clone https://github.com/ИСХОДНЫЙ_РЕПОЗИТОРИЙ/n8n-server-deployment.git
cd n8n-server-deployment

# Запуск скрипта для создания нового репозитория
./init-git.sh ВАШЕ_ИМЯ_ПОЛЬЗОВАТЕЛЯ [ТОКЕН_GITHUB]
```

### Вариант 2: Прямое использование

Просто используйте `git clone` и при необходимости измените URL репозитория:

```bash
git clone https://github.com/ИСХОДНЫЙ_РЕПОЗИТОРИЙ/n8n-server-deployment.git
cd n8n-server-deployment
```

## Локальное использование

Для локальной разработки и тестирования:

```bash
# Установка зависимостей
npm install

# Копирование файла конфигурации
cp env.example .env

# Запуск n8n
npm start
```

## Настройка сервера

### Полная автоматическая настройка:

```bash
# Подключение к серверу
ssh user@server

# Запуск скрипта настройки
wget -O setup-server.sh https://raw.githubusercontent.com/ВАШЕ_ИМЯ_ПОЛЬЗОВАТЕЛЯ/n8n-server-deployment/main/setup-server.sh
chmod +x setup-server.sh
sudo ./setup-server.sh
```

### Настройка с GitHub:

```bash
# Клонирование репозитория на сервере
git clone https://github.com/ВАШЕ_ИМЯ_ПОЛЬЗОВАТЕЛЯ/n8n-server-deployment.git
cd n8n-server-deployment

# Установка зависимостей и запуск
npm install
cp env.example .env
# Редактирование .env файла
npm start
```

## Подготовка GitHub Actions

Для настройки автоматического деплоя через GitHub Actions:

1. Добавьте секреты в настройках репозитория:

   - `SSH_PRIVATE_KEY`: Приватный ключ для доступа к серверу
   - `SERVER_IP`: IP-адрес сервера
   - `SSH_USER`: Имя пользователя на сервере

2. Убедитесь, что ветка `main` выбрана основной для вашего репозитория.

3. При каждом пуше в ветку `main` будет выполняться автоматическое развертывание.

## Рабочие процессы n8n

Рабочие процессы n8n хранятся в директории `data`. При использовании GitHub Actions, они будут сохраняться на сервере в директории `/opt/n8n/data`.

Для бэкапа рабочих процессов:

```bash
# На сервере
cd /opt/n8n
tar -czf workflows_backup.tar.gz data
```

## Работа с базами данных

По умолчанию n8n использует SQLite, но можно настроить другие базы данных:

### PostgreSQL:

Добавьте в `.env`:

```
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=username
DB_POSTGRESDB_PASSWORD=password
```

### MySQL:

Добавьте в `.env`:

```
DB_TYPE=mysqldb
DB_MYSQLDB_HOST=localhost
DB_MYSQLDB_PORT=3306
DB_MYSQLDB_DATABASE=n8n
DB_MYSQLDB_USER=username
DB_MYSQLDB_PASSWORD=password
```

## Использование ngrok

Для создания внешнего доступа через ngrok:

```bash
# Установите ngrok, если его нет
# https://ngrok.com/download

# Запустите n8n через туннель
./start-with-tunnel.sh
```

### Важно!

- URL ngrok меняется при каждом перезапуске
- После изменения URL, обновите все внешние интеграции (вебхуки)
