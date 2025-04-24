# n8n Server Deployment

Репозиторий для развертывания [n8n](https://n8n.io/) - платформы для автоматизации рабочих процессов - на виртуальном сервере.

## Содержимое репозитория

- **deploy.sh** - скрипт для быстрого развертывания n8n с GitHub на сервер
- **setup-server.sh** - скрипт для полной настройки сервера (устанавливает Node.js, PM2 и т.д.)
- **start-with-tunnel.sh** - скрипт для запуска n8n с ngrok туннелем для внешнего доступа
- **env.example** - пример файла конфигурации окружения

## Быстрый старт

### Для локальной разработки

```bash
# Клонирование репозитория
git clone https://github.com/YOUR_USERNAME/n8n-server-deployment.git
cd n8n-server-deployment

# Установка зависимостей
npm install

# Запуск n8n
npm start
```

### Для развертывания на сервере

```bash
# Клонирование репозитория
git clone https://github.com/YOUR_USERNAME/n8n-server-deployment.git
cd n8n-server-deployment

# Запуск скрипта настройки сервера
sudo ./setup-server.sh
```

Или используйте готовый скрипт для быстрого развертывания:

```bash
curl -o- https://raw.githubusercontent.com/YOUR_USERNAME/n8n-server-deployment/main/deploy.sh | bash
```

## Детальная документация

Для подробной информации о развертывании на сервере, см. [README_SERVER.md](README_SERVER.md).

## Доступ извне через ngrok

Для запуска n8n с поддержкой вебхуков через ngrok:

```bash
./start-with-tunnel.sh
```

После запуска n8n будет доступен:

- Локально по адресу: http://localhost:8080
- Внешне по URL ngrok (будет показан в консоли)

## Требования

- Node.js (рекомендуется v16 или выше)
- npm (или yarn)
- Для использования ngrok: установленная утилита ngrok (https://ngrok.com/download)

## Важные замечания

- URL ngrok меняется при каждом перезапуске скрипта
- После перезапуска необходимо обновить URL в настройках внешних сервисов (например, вебхуки Telegram)
- При развертывании на сервере, убедитесь, что открыт нужный порт (по умолчанию 8080)

## Дополнительная информация

- [Документация n8n](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
