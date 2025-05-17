# 🖨️ **`printui` v1.0.0**

Tiny Unicode‑aware & ANSI‑aware **string CLI** – written in Go – built on top of the public [`stringui`](https://pkg.go.dev/github.com/guillaumeast/stringui) package.

[![Go](https://img.shields.io/badge/language-Go-blue)](https://go.dev/)
[![Type: CLI](https://img.shields.io/badge/type-CLI-lightgrey)](https://en.wikipedia.org/wiki/Command-line_interface)
[![Platform: Unix/Windows](https://img.shields.io/badge/platform-Unix%20%26%20Windows-darkgreen)](https://en.wikipedia.org/wiki/Unix)
[![Status: v1.0.0](https://img.shields.io/badge/status-v1.0.0-brightgreen)](https://github.com/guillaumeast/printui/releases/tag/v1.0.0)

> **`printui`** is the command‑line face of **`stringui`**:  
> think of it as a minimal, UTF‑8‑smart replacement for `cut`, `wc`, or `tr` that actually *understands* emojis and ANSI escapes.  
>   
> The underlying **`stringui`** package is **100 % independent** – import it in *any* Go project without pulling the CLI.

---

## ✨ Features

- Everything from **`stringui`** at the tips of your fingers:
  - clean ANSI escapes
  - measure *visual* width / height
  - split / join / repeat helpers
  - substring count
- **UTF‑8 aware** (CJK, wide & combined emojis)
- **Zero runtime dependencies** – the binary is **fully self‑contained**
- Ships as **one tiny binary** (≈ 3 MB with Go 1.22, CGO off)

---

### 🚀 Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/guillaumeast/printui/master/install/install.sh | sh
```

This will:

- detect your platform (Linux/macOS/Windows, x86_64/arm64),
- download the right binary from the latest release,
- install it to `~/.local/bin` (or a custom path if you set `$DEST`),
- add `~/.local/bin` to `$PATH` if needed,
- and verify the checksum before running anything.

Test it:
```bash
printui width "$(printf "\033[31m1\n1🛑4\n12\033[0m")"  // → 4
```

---

### 📦 Grab the library

```bash
go get github.com/guillaumeast/stringui
```

Then:

```go
import "github.com/guillaumeast/stringui"

fmt.Println(stringui.Width("\033[31m1\n1🛑4\n12\033[0m"))  // → 4
```

---

## 🖥️ CLI usage

`printui` installs a single executable called **`stringui`**  
(muscle‑memory friendly for folks migrating from the C++ version).

| Command                                                | Description                                   |
|--------------------------------------------------------|-----------------------------------------------|
| `stringui width <string>`                              | Return *visual* width (columns) of `string`   |
| `stringui height <string>`                             | Return number of *lines* in `string`          |
| `stringui clean <string>`                              | Remove ANSI *escape sequences*                |
| `stringui split <string> <separator>`                  | Vector‑split `string` on `separator`          |
| `stringui join ?--separator ?<sep> <...strings...>`    | Join `strings` with optional `separator`      |
| `stringui repeat <count> <string> ?<separator>`        | Repeat `string` `count` times                 |
| `stringui count <value> <string>`                      | Count occurrences of `value` in `string`      |

> 📚 See [`go-runewidth`](https://github.com/mattn/go-runewidth) for more details on width computing.

---

## 🧪 Tests

> Requirement: **Docker**

Tests are run locally *and* inside multiple Linux containers to guarantee portability:

```bash
make test          # build + tests + multi‑distro checks
```

---

## 📁 Project structure

```
printui/
├── go.mod
├── go.sum
├── Makefile
├── cmd/
│   └── stringui/       # CLI entry‑point
│       └── main.go
├── pkg/
│   └── stringui/       # public library
│       └── stringui.go
├── scripts/
│   ├── loader.sh
│   └── make.sh
└── tests/
    └── unit.sh
```

---

## 📦 Dependencies

- **Runtime:** none
- **Build‑time:**
  - **Go 1.22+**
  - [`github.com/mattn/go-runewidth`](https://github.com/mattn/go-runewidth) (vendored automatically)

---

## 👤 Author

Made with ❤️ by [@guillaumeast](https://github.com/guillaumeast)
