# n8n Server Deployment

Репозиторий для развертывания [n8n](https://n8n.io/) - платформы для автоматизации рабочих процессов - на виртуальном сервере.

## Статус GitHub Actions
![GitHub Actions Workflow Status](https://github.com/NeuroAgents/n8n-server-deployment/actions/workflows/deploy.yml/badge.svg)

## Настройка GitHub Actions для деплоя

Репозиторий настроен для автоматического развертывания на сервер при каждом пуше в ветку main. Для успешного деплоя необходимо настроить следующие секреты в настройках репозитория:

1. Перейдите в [настройки секретов репозитория](https://github.com/NeuroAgents/n8n-server-deployment/settings/secrets/actions)
2. Добавьте следующие секреты:
   - **SSH_PRIVATE_KEY**: Ваш приватный SSH-ключ для доступа к серверу
   - **SERVER_IP**: IP-адрес вашего сервера
   - **SSH_USER**: Имя пользователя на сервере

После настройки секретов, каждый пуш в ветку main будет автоматически запускать процесс деплоя.

## Содержимое репозитория

- **deploy.sh** - скрипт для быстрого развертывания n8n с GitHub на сервер
- **setup-server.sh** - скрипт для полной настройки сервера (устанавливает Node.js, PM2 и т.д.)
- **start-with-tunnel.sh** - скрипт для запуска n8n с ngrok туннелем для внешнего доступа
- **env.example** - пример файла конфигурации окружения

## Ручное развертывание на сервере

Если вы хотите развернуть n8n на сервере вручную:

```bash
# Подключение к серверу
ssh user@YOUR_SERVER_IP

# Скачивание скрипта установки
wget -O setup-server.sh https://raw.githubusercontent.com/NeuroAgents/n8n-server-deployment/main/setup-server.sh
chmod +x setup-server.sh

# Запуск установки
sudo ./setup-server.sh
```

## Доступ извне через ngrok

Для запуска n8n с поддержкой вебхуков через ngrok:

```bash
./start-with-tunnel.sh
```

## Подробная документация

- [Инструкция по развертыванию на сервере](README_SERVER.md)
- [Руководство пользователя](GUIDE.md)
- [GitHub Actions настройка](.github/workflows/deploy.yml)
