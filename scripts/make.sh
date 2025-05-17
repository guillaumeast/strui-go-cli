#!/usr/bin/env sh

RED=$(printf "\033[31m")
ORANGE=$(printf "\033[38;5;208m")
CYAN=$(printf "\033[36m")
GREEN=$(printf "\033[32m")
GREY=$(printf "\033[90m")
RESET=$(printf "\033[0m")

# ------------ PATHS ---------------
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_DIR="${SCRIPT_DIR}/.."

TARGET=stringui
SRC="${REPO_DIR}/cmd/${TARGET}"
BUILD_DIR="${REPO_DIR}/bin"

# ---------- PLATFORMS -------------
HOST_OS="$(go env GOOS)"
HOST_ARCH="$(go env GOARCH)"
OS_MATRIX="darwin linux windows"
ARCH_MATRIX="arm64 amd64"

# ------------ TESTS ---------------
UNIT_TESTS_FILE="${REPO_DIR}/tests/unit.sh"
IMAGES="alpine ubuntu debian fedora archlinux mageia kalilinux/kali-rolling opensuse/leap opensuse/tumbleweed parrotsec/core"
VOLUME_LOCAL="${REPO_DIR}/tests/volume"
VOLUME_DOCKER="/volume"
BINARY_TEST_PATH="${VOLUME_DOCKER}/binary"
PASSED=0
FAILED=0

main()
{
    command="$1"
    if [ -z "$command" ]; then
        printf "${RED}⤬ Usage: ${0} <command> <opt:os> <opt:arch>${RESET}\n" >&2
        return 1
    fi

    . "${REPO_DIR}/scripts/loader.sh"

    [ -n "$2" ] && HOST_OS="$2"
    [ -n "$3" ] && HOST_ARCH="$3"

    if   [ "${command}" = "clean" ]; then
        printf "\n🧹  ${ORANGE}Cleaning...${RESET}\n"
        rm -r "${BUILD_DIR}" 2>/dev/null || true
    	printf "${GREEN}✔${RESET} Cleaned${RESET}\n"
    elif [ "${command}" = "local-build" ]; then
        printf "\n📦  ${ORANGE}Compiling...${RESET}\n"
        mkdir -p "${BUILD_DIR}"
        build
    elif [ "${command}" = "cross-build" ]; then
        printf "\n🌍  ${ORANGE}Cross-compiling...${RESET}\n"
        mkdir -p "${BUILD_DIR}"
        cross_build
    elif [ "${command}" = "install" ]; then
        printf "\n🛠️  ${ORANGE}Installing...${RESET}\n"
        install
    elif [ "${command}" = "test" ]; then
        test
    elif [ "${command}" = "uninstall" ]; then
        printf "\n🗑️  ${ORANGE}Uninstalling...${RESET}\n"
        uninstall
    else
        printf "${RED}⤬ Unknown command: ${command}${RESET}\n" >&2
        return 1
    fi
}

# ────────────────────────────────────────────────────────────────
# BUILD
# ────────────────────────────────────────────────────────────────

cross_build()
{
    for os in $OS_MATRIX; do
        for arch in $ARCH_MATRIX; do
            HOST_OS="$os" HOST_ARCH="$arch" build;
        done
    done
}

build()
{
    out="${BUILD_DIR}/$(get_bin_file_name)"

    if GOOS="$HOST_OS" GOARCH="$HOST_ARCH" CGO_ENABLED=0 \
        go build -o "${out}" "${SRC}"; then
		printf "${GREEN}✔${RESET} Built → ${GREEN}${out}${RESET}\n"
    else
        printf "${RED}⤬${RESET} Failed → ${RED}${out}${RESET}\n"
    fi
}

# ────────────────────────────────────────────────────────────────
# INSTALL / UNINSTALL
# ────────────────────────────────────────────────────────────────

install()
{
    bin_path="${BUILD_DIR}/$(get_bin_file_name)"
    install_dir="$(get_install_dir)"
    cli_path="${install_dir}/$(get_cli_file_name)"

    if ! mkdir -p "${install_dir}"; then
        printf "${RED}⤬ Error: Unable to create install dir: ${install_dir}${RESET}\n" >&2
        return 1
    fi

    if cp "${bin_path}" "${cli_path}" && chmod +x "${cli_path}"; then
    	printf "${GREEN}✔${RESET} Installed to ${CYAN}${cli_path}${RESET}\n"
    else
        printf "${RED}⤬ Error: Unable to copy ${bin_path} → ${cli_path}${RESET}\n" >&2
        return 1
	fi
    
    case ":$PATH:" in
        *:"${install_dir}":*) ;;
        *) printf "${ORANGE}⚠️  Warning: ${install_dir} is not in your PATH${RESET}\n" >&2 ;;
    esac
}

uninstall()
{
    if rm -f "$(get_install_dir)/$(get_cli_file_name)"; then
    	printf "${GREEN}✔${RESET} Uninstalled${RESET}\n"
    else
        printf "${RED}⤬ Failed to uninstall${RESET}\n" >&2
        return 1
	fi
}

# ────────────────────────────────────────────────────────────────
# TESTS
# ────────────────────────────────────────────────────────────────

test()
{
    printf "\n🧪  ${ORANGE}Testing (local)...${RESET}\n"

    sh "${UNIT_TESTS_FILE}" "${BUILD_DIR}/$(get_bin_file_name)" || exit 1

    printf "\n🐳  ${ORANGE}Testing (Docker)...${RESET}\n"

    test_in_docker
    return_value=$?

    printf "\n🧹 ${ORANGE}Cleaning test files...${RESET}\n"

    [ -d "${VOLUME_LOCAL}" ] && rm -rf "${VOLUME_LOCAL}"

    printf "${GREEN}✔${RESET} Done\n"
    return $return_value
}

test_in_docker()
{    
    PASSED=0
    FAILED=0

    mkdir -p "${VOLUME_LOCAL}" || exit 1
    cp "${UNIT_TESTS_FILE}" "${VOLUME_LOCAL}/unit.sh"
    HOST_OS="linux"

    for image in $IMAGES; do
        for arch in $ARCH_MATRIX; do

            [ "$image" = "archlinux" ] && [ "$arch" = "arm64" ] && continue

            loader_start "Testing   → [${arch}] ${image}..."
            HOST_ARCH="${arch}"
            cp "${BUILD_DIR}/$(get_bin_file_name)" "${VOLUME_LOCAL}/$(get_bin_file_name)"

            if docker run --rm \
                --platform "linux/${arch}" \
                -v "${VOLUME_LOCAL}:${VOLUME_DOCKER}" \
                "$image" \
                sh "${VOLUME_DOCKER}/unit.sh" "${VOLUME_DOCKER}/$(get_bin_file_name)" >/dev/null; then
                PASSED=$((PASSED + 1))
                loader_stop
    	        printf "${GREEN}✔${RESET} Passed  → ${GREEN}[${arch}] ${image}${RESET}\n"
            else
                FAILED=$((FAILED + 1))
                loader_stop
    	        printf "${RED}⤬${RESET} Failed  → ${RED}[${arch}] ${image}${RESET}\n" >&2
            fi
        done
    done

    print_results

    return $FAILED
}

# ────────────────────────────────────────────────────────────────
# HELPERS
# ────────────────────────────────────────────────────────────────

get_extension()
{
    [ "$HOST_OS" = "windows" ] && echo ".exe"
}

get_bin_file_name()
{
    echo "${TARGET}-${HOST_OS}-${HOST_ARCH}$(get_extension)"
}

get_cli_file_name()
{
    echo "${TARGET}$(get_extension)"
}

get_install_dir()
{
    case "$HOST_OS" in
        windows)
            echo "/usr/local/bin"
            ;;
        linux|darwin)
            if [ "$(id -u)" -eq 0 ] || [ -z "${HOME}" ]; then
                echo "/usr/local/bin"
                return 0
            else
                echo "${HOME}/.local/bin"
            fi
            ;;
        *)
            echo "/usr/local/bin"
            ;;
    esac
}

print_results() {
    
    printf -- "----------------\n"
    printf "${GREEN}✔${RESET} PASSED  → ${PASSED}\n"
    printf "${RED}⤬${RESET} FAILED  → ${FAILED}\n"

    color=$RED
    text="❌ SOME FAILED"
    if [ "$FAILED" = 0 ]; then
        color=$GREEN
        text="✅ ALL PASSED"
    fi

    printf "${color}----------------${RESET}\n"
    printf "${color}${text}${RESET}\n"
    printf "${color}----------------${RESET}\n"
}

# ────────────────────────────────────────────────────────────────
# Run
# ────────────────────────────────────────────────────────────────

main "$@"

