#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
SERVICE_NAME="slam"
CONFIG_FILE="${SCRIPT_DIR}/config/slam.yaml"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/slam.txt"

usage() {
    echo "Usage: $0 COMMAND"
    echo
    echo "Commands:"
    echo "  build                Build the Docker image only"
    echo "  create,  -c          Build, create and start the container"
    echo "  start,   -s          Start the existing container"
    echo "  stop,    -t          Stop the container"
    echo "  restart, -r          Restart the container"
    echo "  remove,  -x          Stop and remove the container"
    echo "  status               Show the container status"
    echo "  check                Check module prerequisites"
    echo "  logs                 Follow the container logs"
    echo "  help,    -h          Show this help message"
}

die() {
    local message="$1"

    mkdir -p "${LOG_DIR}"
    echo "[ERROR] ${message}" >&2
    echo "[ERROR] ${message}" >> "${LOG_FILE}"
    exit 1
}

compose() {
    docker compose --file "${COMPOSE_FILE}" "$@"
}

prepare_runtime_directories() {
    mkdir -p "${DATA_DIR}" "${LOG_DIR}"
    [[ -w "${DATA_DIR}" ]] || die "Database directory is not writable: ${DATA_DIR}"
}

check_dependencies() {
    command -v docker >/dev/null 2>&1 || die "Docker is not installed"
    docker compose version >/dev/null 2>&1 || die "Docker Compose is not available"
    [[ -f "${COMPOSE_FILE}" ]] || die "Compose file not found: ${COMPOSE_FILE}"
    [[ -f "${CONFIG_FILE}" ]] || die "SLAM configuration not found: ${CONFIG_FILE}"
    docker info >/dev/null 2>&1 || die "Docker daemon is not reachable"

    prepare_runtime_directories
    compose config --quiet || die "Compose configuration is invalid"
}

build_image() {
    check_dependencies
    echo "[INFO] Building the SLAM image"
    compose build "${SERVICE_NAME}"
}

create_container() {
    check_dependencies
    echo "[INFO] Building and starting the SLAM container"
    compose up --detach --build "${SERVICE_NAME}"
}

start_container() {
    check_dependencies
    echo "[INFO] Starting the SLAM container"
    compose start "${SERVICE_NAME}"
}

stop_container() {
    check_dependencies
    echo "[INFO] Stopping the SLAM container"
    compose stop "${SERVICE_NAME}"
}

restart_container() {
    check_dependencies
    echo "[INFO] Restarting the SLAM container"
    compose restart "${SERVICE_NAME}"
}

remove_container() {
    check_dependencies
    echo "[INFO] Stopping and removing the SLAM container"
    compose rm --stop --force "${SERVICE_NAME}"
}

status_container() {
    check_dependencies
    compose ps "${SERVICE_NAME}"
}

check_module() {
    check_dependencies
    echo "[OK] Docker is available"
    echo "[OK] Docker daemon is running"
    echo "[OK] Compose configuration is valid"
    echo "[OK] SLAM configuration is present"
    echo "[OK] Database directory is writable"
}

show_logs() {
    check_dependencies
    compose logs --follow "${SERVICE_NAME}"
}

main() {
    if [[ $# -ne 1 ]]; then
        usage
        return 2
    fi

    case "$1" in
        build|--build)
            build_image
            ;;
        create|-c|--create)
            create_container
            ;;
        start|-s|--start)
            start_container
            ;;
        stop|-t|--stop)
            stop_container
            ;;
        restart|-r|--restart)
            restart_container
            ;;
        remove|-x|--remove)
            remove_container
            ;;
        status|--status)
            status_container
            ;;
        check|--check)
            check_module
            ;;
        logs|--logs)
            show_logs
            ;;
        help|-h|--help)
            usage
            ;;
        *)
            echo "Unknown command: $1" >&2
            usage
            return 2
            ;;
    esac
}

main "$@"
