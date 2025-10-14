#!/usr/bin/env sh

BINARY=${1:-strui}
[ "$1" ] && shift

RED=$(printf "\033[31m")
ORANGE=$(printf "\033[38;5;208m")
GREEN=$(printf "\033[32m")
RESET=$(printf "\033[0m")

PASSED=0
FAILED=0

main() {
    run_tests
    print_results
    return $FAILED;
}

test() {

    name=$1
    output=$2
    expected=$3
    if [ "$output" = "$expected" ]; then
        printf "${GREEN}✔${RESET} ${name}\n"
        PASSED=$((PASSED + 1))
        return 0;
    else
        printf "${RED}⤬ ${name}${RESET}\n" >&2
        printf "${ORANGE}     expected → '${expected}'${RESET}\n" >&2
        printf "${ORANGE}     got      → '${output}'${RESET}\n" >&2
        FAILED=$((FAILED + 1))
        return 1;
    fi
}

run_tests() {

    test "repeat()" "$("${BINARY}" repeat 3 "ABC" "-")" "ABC-ABC-ABC"

    input=$(printf "${RED}1\n1234\n12${RESET}\n")
    test "clean()" "$("${BINARY}" clean "${input}")" "$(printf "1\n1234\n12\n")"
    test "width()" "$("${BINARY}" width "${input}")" "4"
    test "height()" "$("${BINARY}" height "${input}")" "3"
    test "count()" "$("${BINARY}" count "-" "0-1-2")" "2"

    test "split()" "$("${BINARY}" split "ABC-ABC-ABC" "-")" "$(printf "ABC\nABC\nABC\n")"
    test "join()" "$("${BINARY}" join --separator "-" "ABC" "ABC" "ABC")" "ABC-ABC-ABC"
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

main

