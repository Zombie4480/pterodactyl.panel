#!/bin/bash

# Скрипт для установки и инициализации Pterodactyl Panel с поддержкой Minecraft

set -e

echo "========================================="
echo "Инициализация Pterodactyl Panel"
echo "========================================="

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose не установлен. Установка..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Создание необходимых директорий
echo "Создание директорий..."
mkdir -p pterodactyl/var
mkdir -p pterodactyl/storage
mkdir -p pterodactyl/public
mkdir -p wings/config
mkdir -p wings/data
mkdir -p mysql
mkdir -p redis
mkdir -p servers
mkdir -p backups

# Установка прав доступа
chmod -R 755 pterodactyl
chmod -R 755 wings
chmod 755 scripts/*.sh

echo "Запуск Docker контейнеров..."
docker-compose up -d

echo ""
echo "========================================="
echo "Pterodactyl Panel запущен!"
echo "========================================="
echo ""
echo "Доступ к панели:"
echo "  URL: http://localhost"
echo "  Default User: admin@pterodactyl.local"
echo ""
echo "Доступ к Wings:"
echo "  URL: http://localhost:8080"
echo ""
echo "Mysql:"
echo "  Host: mysql"
echo "  User: pterodactyl"
echo "  Password: pterodactyl_password"
echo ""
echo "Redis:"
echo "  Host: redis"
echo "  Port: 6379"
echo ""
echo "========================================="
echo ""
echo "Загрузка Minecraft Egg в Pterodactyl..."
echo "Это можно сделать вручную через админ-панель:"
echo "Admin Panel > Nests > Import Egg"
echo "Файл: pterodactyl/minecraft_egg.json"
echo ""
