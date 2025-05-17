#!/usr/bin/env sh

# ────────────────────────────────────────────────────────────────
# IPKG HEADER
# ────────────────────────────────────────────────────────────────

get_deps() {
    echo ""
}

# ────────────────────────────────────────────────────────────────
# VARIABLES
# ────────────────────────────────────────────────────────────────

FRAMES="⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏"
DELAY=0.05
PAUSED="false"
DEFAULT_MESSAGE="Loading..."
MESSAGE=""
SPINNER_PID=""

# ────────────────────────────────────────────────────────────────
# PUBLIC
# ────────────────────────────────────────────────────────────────

loader_start() {

    message="${1:-$DEFAULT_MESSAGE}"

    [ "${PAUSED}" = "false" ] && MESSAGE="${message}"

    PAUSED="false"
    loader_stop

    # Create process
    {
        while true; do
            for frame in $FRAMES; do
                printf "\r\033[K%s %s" "${ORANGE}${frame}${NONE}" "${ORANGE}${MESSAGE}${NONE}"
                sleep $DELAY || sleep 1
            done
        done
    } &

    # Save process ID
    SPINNER_PID=$!
}

loader_pause() {
    
    PAUSED="true"
    loader_stop
}

loader_stop() {

    if [ -n "$SPINNER_PID" ] && kill -0 "$SPINNER_PID" >/dev/null 2>&1; then
        kill "$SPINNER_PID" >/dev/null 2>&1
        wait "$SPINNER_PID" >/dev/null 2>&1
        SPINNER_PID=""
        printf "\r\033[K"
    fi
}

loader_is_active() {

    [ -n "$SPINNER_PID" ] || return 1
}

# ────────────────────────────────────────────────────────────────
# TEST (uncomment to test)
# ────────────────────────────────────────────────────────────────

# test_loader() {
#     ORANGE="$(printf '\033[38;5;208m')"
#     NONE="$(printf '\033[0m')"

#     loader_start "Testing loader..."
#     sleep 2

#     loader_pause
#     echo "Hi, everything fine?"
#     loader_start

#     sleep 2
#     loader_stop
#     echo "That's it!"
# }; test_loader

