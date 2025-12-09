#!/bin/bash

# Скрипт для управления Minecraft серверами через Pterodactyl
# Использование: ./manage_server.sh <action> <server_id>

ACTION=${1:-"status"}
SERVER_ID=${2:-"default"}

SERVER_DIR="./servers/$SERVER_ID"

case $ACTION in
  "start")
    echo "Запуск сервера $SERVER_ID..."
    cd "$SERVER_DIR"
    screen -S "minecraft-$SERVER_ID" -d -m java -Xmx1024M -Xms512M -XX:+UseG1GC -jar server.jar nogui
    echo "Сервер $SERVER_ID запущен"
    ;;
    
  "stop")
    echo "Остановка сервера $SERVER_ID..."
    screen -S "minecraft-$SERVER_ID" -X stuff "stop^M"
    sleep 5
    screen -S "minecraft-$SERVER_ID" -X quit
    echo "Сервер $SERVER_ID остановлен"
    ;;
    
  "restart")
    $0 stop $SERVER_ID
    sleep 3
    $0 start $SERVER_ID
    ;;
    
  "status")
    if screen -list | grep -q "minecraft-$SERVER_ID"; then
      echo "Сервер $SERVER_ID: ONLINE"
    else
      echo "Сервер $SERVER_ID: OFFLINE"
    fi
    ;;
    
  "logs")
    if [ -f "$SERVER_DIR/logs/latest.log" ]; then
      tail -f "$SERVER_DIR/logs/latest.log"
    else
      echo "Файл логов не найден"
    fi
    ;;
    
  "backup")
    echo "Создание резервной копии сервера $SERVER_ID..."
    BACKUP_DIR="./backups/$SERVER_ID-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r "$SERVER_DIR/world" "$BACKUP_DIR/"
    cp "$SERVER_DIR/server.properties" "$BACKUP_DIR/"
    echo "Резервная копия создана: $BACKUP_DIR"
    ;;
    
  *)
    echo "Неизвестная команда: $ACTION"
    echo "Доступные команды: start, stop, restart, status, logs, backup"
    ;;
esac
