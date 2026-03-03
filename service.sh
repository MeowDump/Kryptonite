#!/system/bin/sh

CONFIG_DIR="/data/adb/display"
CONFIG_FILE="$CONFIG_DIR/customize.txt"
LOG_FILE="$CONFIG_DIR/debug.log"

DEFAULT_SATURATION="1.5"
DEFAULT_CONTRAST="0.7"

mkdir -p "$CONFIG_DIR"
touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

parse_config() {
    SATURATION="$DEFAULT_SATURATION"
    CONTRAST="$DEFAULT_CONTRAST"
    RESET="false"

    if [ -f "$CONFIG_FILE" ]; then
        while IFS= read -r line; do
            key=$(echo "$line" | cut -d= -f1 | tr -d ' ')
            val=$(echo "$line" | cut -d= -f2 | tr -d ' ')
            case "$key" in
                saturation)
                    case "$val" in
                        ''|*[!0-9.]*)
                            log "Invalid saturation value '$val', using default."
                            ;;
                        *) SATURATION="$val" ;;
                    esac
                    ;;
                contrast)
                    case "$val" in
                        ''|*[!0-9.]*)
                            log "Invalid contrast value '$val', using default."
                            ;;
                        *) CONTRAST="$val" ;;
                    esac
                    ;;
                reset)
                    [ "$val" = "true" ] && RESET="true"
                    ;;
            esac
        done < "$CONFIG_FILE"
    else
        echo "saturation=$DEFAULT_SATURATION" > "$CONFIG_FILE"
        echo "contrast=$DEFAULT_CONTRAST" >> "$CONFIG_FILE"
        log "Config not found. Created with default values."
    fi
}

apply_settings() {
    if ! service list | grep -iq surfaceflinger; then
        log "SurfaceFlinger not available. Skipping tweak application."
        return
    fi

    if [ "$RESET" = "true" ]; then
        log "Resetting saturation and contrast to defaults."
        service call SurfaceFlinger 1022 f "$DEFAULT_SATURATION" >> "$LOG_FILE" 2>&1
        service call SurfaceFlinger 1023 f "$DEFAULT_CONTRAST" >> "$LOG_FILE" 2>&1
        log "Reset complete."
    else
        log "Applying saturation: $SATURATION"
        service call SurfaceFlinger 1022 f "$SATURATION" >> "$LOG_FILE" 2>&1

        log "Applying contrast: $CONTRAST"
        service call SurfaceFlinger 1023 f "$CONTRAST" >> "$LOG_FILE" 2>&1

        log "Tweaks applied."
    fi
}

wait_for_boot() {
    log "Waiting for Android to finish booting..."
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done
    log "Initialising, please wait."
}

main() {
    log "••••• Saturation & Contrast Tweaker Started •••••"
    wait_for_boot
    parse_config
    apply_settings
    log "••••• Tweaker Done •••••"
    log " "
    log " "
    
}

main