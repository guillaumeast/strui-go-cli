package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/guillaumeast/strui-go-cli/pkg/stringui"
)

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: strui <command> <args...>")
		os.Exit(1)
	}

	cmd := os.Args[1]
	args := os.Args[2:]

	switch cmd {
	case "width":
		fmt.Println(stringui.Width(args[0]))
	case "height":
		fmt.Println(stringui.Height(args[0]))
	case "clean":
		fmt.Println(stringui.Clean(args[0]))
	case "split":
		if len(args) < 2 {
			fmt.Println("Usage: strui split <string> <separator>")
			os.Exit(1)
		}
		parts := strings.Split(args[0], args[1])
		for _, part := range parts {
			fmt.Println(part)
		}
	case "join":
		separator := ""
		stringsStart := 0
		if len(args) >= 2 && args[0] == "--separator" {
			separator = args[1]
			stringsStart = 2
		}
		fmt.Println(strings.Join(args[stringsStart:], separator))
	case "repeat":
		if len(args) < 2 {
			fmt.Println("Usage: strui repeat <count> <string> [separator]")
			os.Exit(1)
		}
		count, err := strconv.Atoi(args[0])
		if err != nil || count < 0 {
			fmt.Println("Invalid repeat count")
			os.Exit(1)
		}
		separator := ""
		if len(args) == 3 {
			separator = args[2]
		}
		out := strings.Repeat(args[1]+separator, count)
		if separator != "" {
			out = strings.TrimSuffix(out, separator)
		}
		fmt.Println(out)
	case "count":
		if len(args) < 2 {
			fmt.Println("Usage: strui count <value> <string>")
			os.Exit(1)
		}
		fmt.Println(strings.Count(args[1], args[0]))
	default:
		fmt.Println("Unknown command:", cmd)
		os.Exit(1)
	}
}
