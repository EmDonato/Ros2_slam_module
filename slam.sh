#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
SERVICE_NAME="slam"
RTAB_CONFIG_FILE="${SCRIPT_DIR}/config/slam.yaml"
TOOLBOX_CONFIG_FILE="${SCRIPT_DIR}/config/slam_toolbox_config.yaml"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/slam.txt"

usage() {
    echo "Usage: $0 COMMAND [ALGORITHM]"
    echo
    echo "Commands:"
    echo "  build                  Build the Docker image only"
    echo "  create,  -c [ALGORITHM] Build, create and start the container"
    echo "                          ALGORITHM: rtab (default), toolbox"
    echo "  start,   -s             Start the existing container"
    echo "  stop,    -t             Stop the container"
    echo "  restart, -r             Restart the container"
    echo "  remove,  -x             Stop and remove the container"
    echo "  status                  Show the container status"
    echo "  check                   Check module prerequisites"
    echo "  logs                    Follow the container logs"
    echo "  help,    -h             Show this help message"
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
    [[ -f "${RTAB_CONFIG_FILE}" ]] || die "RTAB-Map configuration not found: ${RTAB_CONFIG_FILE}"
    [[ -f "${TOOLBOX_CONFIG_FILE}" ]] || die "SLAM Toolbox configuration not found: ${TOOLBOX_CONFIG_FILE}"
    docker info >/dev/null 2>&1 || die "Docker daemon is not reachable"

    prepare_runtime_directories
    compose config --quiet || die "Compose configuration is invalid"
}

select_algorithm() {
    local algorithm="${1:-rtab}"

    case "${algorithm}" in
        rtab|rtabmap)
            export SLAM_PACKAGE="rtabmap_bringup"
            export SLAM_LAUNCH_FILE="slam.launch.py"
            export SLAM_CONFIG_FILE="/ws/config/slam.yaml"
            SELECTED_ALGORITHM="rtab"
            ;;
        toolbox|slam_toolbox)
            export SLAM_PACKAGE="slam_toolbox_bringup"
            export SLAM_LAUNCH_FILE="slam_toolbox_online_async.launch.py"
            export SLAM_CONFIG_FILE="/ws/config/slam_toolbox_config.yaml"
            SELECTED_ALGORITHM="toolbox"
            ;;
        *)
            die "Unknown SLAM algorithm '${algorithm}'. Expected 'rtab' or 'toolbox'."
            ;;
    esac
}

build_image() {
    check_dependencies
    echo "[INFO] Building the SLAM image"
    compose build "${SERVICE_NAME}"
}

create_container() {
    select_algorithm "${1:-rtab}"
    check_dependencies

    echo "[INFO] Building and starting SLAM algorithm: ${SELECTED_ALGORITHM}"
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
    echo "[OK] SLAM configurations are present"
    echo "[OK] Database directory is writable"
}

show_logs() {
    check_dependencies
    compose logs --follow "${SERVICE_NAME}"
}

main() {
    if [[ $# -lt 1 ]]; then
        usage
        return 2
    fi

    case "$1" in
        build|--build)
            [[ $# -eq 1 ]] || { usage; return 2; }
            build_image
            ;;
        create|-c|--create)
            [[ $# -le 2 ]] || { usage; return 2; }
            create_container "${2:-rtab}"
            ;;
        start|-s|--start)
            [[ $# -eq 1 ]] || { usage; return 2; }
            start_container
            ;;
        stop|-t|--stop)
            [[ $# -eq 1 ]] || { usage; return 2; }
            stop_container
            ;;
        restart|-r|--restart)
            [[ $# -eq 1 ]] || { usage; return 2; }
            restart_container
            ;;
        remove|-x|--remove)
            [[ $# -eq 1 ]] || { usage; return 2; }
            remove_container
            ;;
        status|--status)
            [[ $# -eq 1 ]] || { usage; return 2; }
            status_container
            ;;
        check|--check)
            [[ $# -eq 1 ]] || { usage; return 2; }
            check_module
            ;;
        logs|--logs)
            [[ $# -eq 1 ]] || { usage; return 2; }
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
