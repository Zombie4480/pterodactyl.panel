#!/bin/bash

# Скрипт для запуска серверов Minecraft через Pterodactyl
# Использование: ./start_minecraft_server.sh <server_id> <memory> <max_players>

SERVER_ID=${1:-"default"}
MEMORY=${2:-"1024"}
MAX_PLAYERS=${3:-"20"}
PORT=${4:-"25565"}

echo "========================================="
echo "Запуск Minecraft сервера на Pterodactyl"
echo "========================================="
echo "Server ID: $SERVER_ID"
echo "Memory: ${MEMORY}M"
echo "Max Players: $MAX_PLAYERS"
echo "Port: $PORT"
echo "========================================="

# Создание директории для сервера если её нет
SERVER_DIR="./servers/$SERVER_ID"
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

# Проверка наличия server.jar
if [ ! -f "server.jar" ]; then
    echo "Скачивание Minecraft сервера..."
    wget https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/133/downloads/paper-1.20.4-133.jar -O server.jar
fi

# Проверка eula.txt
if [ ! -f "eula.txt" ]; then
    echo "eula=true" > eula.txt
fi

# Создание server.properties если его нет
if [ ! -f "server.properties" ]; then
    cat > server.properties << EOF
#Minecraft server properties
server-port=$PORT
server-ip=0.0.0.0
max-players=$MAX_PLAYERS
level-name=world
gamemode=survival
difficulty=normal
pvp=true
enable-command-blocks=true
enable-rcon=true
rcon-port=25575
rcon-password=rcon_password
motd=§c§lPterodactyl§r §b§lMinecraft§r Server
EOF
fi

echo "Запуск сервера..."
java -Xmx${MEMORY}M -Xms$((MEMORY / 2))M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar server.jar nogui
