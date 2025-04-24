#!/bin/bash

# Скрипт для инициализации репозитория Git и загрузки на GitHub

# Проверка наличия переменных
if [ -z "$1" ]; then
  echo "Ошибка: Не указано имя пользователя GitHub"
  echo "Использование: $0 ИМЯ_ПОЛЬЗОВАТЕЛЯ [ТОКЕН_GITHUB]"
  exit 1
fi

GITHUB_USER=$1
REPO_NAME="n8n-server-deployment"
TOKEN=""

# Если токен передан как аргумент
if [ ! -z "$2" ]; then
  TOKEN=$2
fi

# Инициализировать репозиторий
echo "Инициализация локального репозитория Git..."
git init

# Добавить файлы
echo "Добавление файлов в репозиторий..."
git add .
git commit -m "Начальная настройка n8n для сервера"

# Создать репозиторий на GitHub
echo "Создание репозитория на GitHub..."
if [ -z "$TOKEN" ]; then
  # Без токена - ручное создание
  echo "Пожалуйста, создайте репозиторий '$REPO_NAME' на GitHub через веб-интерфейс"
  echo "https://github.com/new"
  read -p "Нажмите Enter после создания репозитория..."
else
  # С токеном - автоматическое создание через API
  curl -H "Authorization: token $TOKEN" \
       -d "{\"name\":\"$REPO_NAME\", \"description\":\"Локальная настройка n8n для развертывания на виртуальном сервере\"}" \
       https://api.github.com/user/repos
fi

# Добавление удаленного репозитория
echo "Добавление удаленного репозитория..."
git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git

# Загрузка на GitHub
echo "Загрузка кода на GitHub..."
if [ -z "$TOKEN" ]; then
  # Без токена - обычный push
  git push -u origin master
else
  # С токеном - push через HTTPS с токеном
  git push -u https://$GITHUB_USER:$TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git master
fi

echo "Готово! Репозиторий создан и код загружен на GitHub."
echo "URL вашего репозитория: https://github.com/$GITHUB_USER/$REPO_NAME" 