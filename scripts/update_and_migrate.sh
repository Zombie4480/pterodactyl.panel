#!/bin/bash

# Скрипт для обновления и миграции Pterodactyl Panel и Minecraft серверов

set -e

echo "========================================="
echo "Pterodactyl Panel - Обновление и Миграция"
echo "========================================="

# Функция для логирования
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Функция для ошибок
error() {
    echo "❌ ОШИБКА: $1" >&2
    exit 1
}

ACTION=${1:-"help"}

case $ACTION in
    "backup")
        log "Создание полной резервной копии..."
        
        BACKUP_DIR="backups/full-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        
        log "Резервная копия Pterodactyl..."
        docker-compose exec -T mysql mysqldump -u root -p$DB_ROOT_PASSWORD pterodactyl > "$BACKUP_DIR/pterodactyl.sql"
        
        log "Резервная копия серверов..."
        if [ -d "servers" ]; then
            tar -czf "$BACKUP_DIR/servers.tar.gz" servers/
        fi
        
        log "Резервная копия данных Pterodactyl..."
        tar -czf "$BACKUP_DIR/pterodactyl-data.tar.gz" pterodactyl/
        
        log "✅ Резервная копия создана: $BACKUP_DIR"
        ;;
        
    "update-panel")
        log "Обновление Pterodactyl Panel..."
        docker-compose pull pterodactyl-panel
        docker-compose up -d pterodactyl-panel
        log "✅ Panel обновлена"
        ;;
        
    "update-wings")
        log "Обновление Pterodactyl Wings..."
        docker-compose pull pterodactyl-wings
        docker-compose up -d pterodactyl-wings
        log "✅ Wings обновлены"
        ;;
        
    "update-minecraft-image")
        log "Обновление Docker образа Minecraft..."
        
        # Проверка наличия нового образа
        MINECRAFT_VERSION=${2:-"1.20.4"}
        MINECRAFT_BUILD=${3:-"133"}
        
        log "Скачивание Paper $MINECRAFT_VERSION build $MINECRAFT_BUILD..."
        curl -o /tmp/paper-$MINECRAFT_VERSION.jar \
            "https://api.papermc.io/v2/projects/paper/versions/$MINECRAFT_VERSION/builds/$MINECRAFT_BUILD/downloads/paper-$MINECRAFT_VERSION-$MINECRAFT_BUILD.jar"
        
        if [ -f "/tmp/paper-$MINECRAFT_VERSION.jar" ]; then
            log "✅ Образ Minecraft успешно загружен"
        else
            error "Не удалось загрузить образ Minecraft"
        fi
        ;;
        
    "clean")
        log "Очистка неиспользуемых Docker ресурсов..."
        docker system prune -f
        log "✅ Очистка завершена"
        ;;
        
    "restore")
        BACKUP_PATH=${2:-""}
        if [ -z "$BACKUP_PATH" ]; then
            error "Укажите путь к резервной копии: $0 restore <path>"
        fi
        
        log "Восстановление из резервной копии: $BACKUP_PATH"
        
        # Остановить контейнеры
        log "Остановка контейнеров..."
        docker-compose down
        
        # Восстановить БД
        if [ -f "$BACKUP_PATH/pterodactyl.sql" ]; then
            log "Восстановление БД..."
            docker-compose up -d mysql
            sleep 10
            docker-compose exec -T mysql mysql -u root -p$DB_ROOT_PASSWORD < "$BACKUP_PATH/pterodactyl.sql"
        fi
        
        # Восстановить серверы
        if [ -f "$BACKUP_PATH/servers.tar.gz" ]; then
            log "Восстановление серверов..."
            rm -rf servers/
            tar -xzf "$BACKUP_PATH/servers.tar.gz"
        fi
        
        # Восстановить данные
        if [ -f "$BACKUP_PATH/pterodactyl-data.tar.gz" ]; then
            log "Восстановление данных..."
            rm -rf pterodactyl/
            tar -xzf "$BACKUP_PATH/pterodactyl-data.tar.gz"
        fi
        
        log "✅ Восстановление завершено"
        ;;
        
    "migrate-server")
        SERVER_ID=${2:-""}
        if [ -z "$SERVER_ID" ]; then
            error "Укажите ID сервера: $0 migrate-server <server_id>"
        fi
        
        log "Миграция сервера $SERVER_ID..."
        
        # Создать резервную копию сервера
        log "Резервная копия сервера..."
        ./scripts/manage_server.sh backup $SERVER_ID
        
        # Обновить конфигурацию
        log "Обновление конфигурации..."
        if [ -f "servers/$SERVER_ID/server.properties" ]; then
            # Добавить новые параметры если их нет
            if ! grep -q "max-tick-time" "servers/$SERVER_ID/server.properties"; then
                echo "max-tick-time=60000" >> "servers/$SERVER_ID/server.properties"
            fi
        fi
        
        log "✅ Миграция завершена"
        ;;
        
    "status")
        log "Статус контейнеров:"
        docker-compose ps
        echo ""
        log "Статус дисковой памяти:"
        df -h | grep -E "^/|Filesystem"
        echo ""
        log "Использование памяти Docker:"
        docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}"
        ;;
        
    "help"|*)
        cat << EOF
Pterodactyl Panel - Скрипт обновления и миграции

Использование: $0 <action> [options]

Доступные действия:

  backup                  - Создать полную резервную копию
  
  update-panel            - Обновить Pterodactyl Panel
  
  update-wings            - Обновить Pterodactyl Wings
  
  update-minecraft-image  - Обновить образ Minecraft
                           Опции: $0 update-minecraft-image <version> <build>
                           Пример: $0 update-minecraft-image 1.20.4 133
  
  clean                   - Очистить неиспользуемые Docker ресурсы
  
  restore                 - Восстановить из резервной копии
                           Опции: $0 restore <path>
                           Пример: $0 restore backups/full-20231209-120000
  
  migrate-server          - Мигрировать сервер Minecraft
                           Опции: $0 migrate-server <server_id>
                           Пример: $0 migrate-server server1
  
  status                  - Показать статус всех сервисов
  
  help                    - Показать эту справку

Примеры:

  # Создать резервную копию перед обновлением
  $0 backup

  # Обновить все компоненты
  $0 update-panel
  $0 update-wings

  # Очистить неиспользуемые ресурсы
  $0 clean

  # Восстановить систему из резервной копии
  $0 restore backups/full-20231209-120000

EOF
        ;;
esac
