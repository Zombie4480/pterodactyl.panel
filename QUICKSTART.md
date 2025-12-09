#!/bin/bash

# Быстрый старт-гайд для Pterodactyl Minecraft Hosting

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Pterodactyl Minecraft Hosting - Быстрый Старт             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен"
    echo "Установите Docker: https://docs.docker.com/engine/install/"
    exit 1
fi

echo "✅ Docker установлен: $(docker --version)"
echo ""

# Проверка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен"
    echo "Установите Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker Compose установлен: $(docker-compose --version)"
echo ""

# Создание директорий
echo "📁 Создание необходимых директорий..."
mkdir -p pterodactyl/{var,storage,public}
mkdir -p wings/{config,data}
mkdir -p mysql redis servers backups
echo "✅ Директории созданы"
echo ""

# Запуск контейнеров
echo "🚀 Запуск Docker контейнеров..."
docker-compose up -d

# Ожидание инициализации
echo "⏳ Инициализация контейнеров (это может занять 1-2 минуты)..."
sleep 30

# Проверка статуса
echo ""
echo "📊 Статус контейнеров:"
docker-compose ps
echo ""

# Вывод информации об доступе
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              Инструкции по использованию                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Pterodactyl Panel:"
echo "   URL: http://localhost"
echo "   (Создайте администратора при первом входе)"
echo ""
echo "🛠️  Wings Daemon:"
echo "   URL: http://localhost:8080"
echo ""
echo "🎮 Minecraft Server:"
echo "   Host: localhost"
echo "   Port: 25565"
echo ""
echo "💾 MySQL Database:"
echo "   Host: mysql"
echo "   User: pterodactyl"
echo "   Password: pterodactyl_password"
echo ""
echo "📝 Следующие шаги:"
echo ""
echo "1️⃣  Откройте Pterodactyl Panel и создайте админ-аккаунт"
echo "2️⃣  Перейдите в Admin Panel > Nests > Import Egg"
echo "3️⃣  Загрузите файл: pterodactyl/minecraft_egg.json"
echo "4️⃣  Создайте Node для управления серверами"
echo "5️⃣  Создайте новый Minecraft сервер"
echo ""
echo "📖 Для подробной документации:"
echo "   cat README.md"
echo ""
echo "🔍 Просмотр логов:"
echo "   docker-compose logs -f"
echo ""
echo "❌ Остановить контейнеры:"
echo "   docker-compose down"
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✨ Готово! Pterodactyl Minecraft хостинг настроен!        ║"
echo "╚════════════════════════════════════════════════════════════╝"
