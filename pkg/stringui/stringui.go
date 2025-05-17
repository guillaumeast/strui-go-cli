package stringui

import (
	"strings"

	"github.com/mattn/go-runewidth"
)

func Clean(input string) string {
	// Fast path: no ESC => nothing to clean.
	if !strings.ContainsRune(input, '\x1b') { // '\x1b' == '\033'
		return input
	}

	runes := []rune(input)
	out := make([]rune, 0, len(runes)) // pre-allocate full length

	for i := 0; i < len(runes); {
		if runes[i] == '\x1b' && i+1 < len(runes) && runes[i+1] == '[' {
			i += 2
			for i < len(runes) && !(runes[i] >= '@' && runes[i] <= '~') {
				i++
			}
			if i < len(runes) {
				i++
			}
			continue
		}
		out = append(out, runes[i])
		i++
	}
	return string(out)
}

func Width(input string) int {
	cleaned := Clean(input)
	maxWidth := 0
	for line := range strings.Lines(cleaned) { // Go 1.24 iter.Seq
		if width := runewidth.StringWidth(line); width > maxWidth {
			maxWidth = width
		}
	}
	return maxWidth
}

func Height(input string) int {
	if len(input) == 0 {
		return 0
	}
	return strings.Count(Clean(input), "\n") + 1
}
