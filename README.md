# peek-rename

A macOS-based batch file renaming tool that uses Finder’s **Quick Look (Space-bar preview)** to show each file before renaming.

Designed for **human-in-the-loop** workflows. Instead of bulk renaming blindly, `peek-rename` previews every file, asks for user input, and then renames or copies the file accordingly.

(If you are looking for an AI-based renamer that generates keywords based on file contents or image contents, you can use: [ai-rename-files](https://github.com/PedroLopes/ai-rename-files).)

---

## Features

- Iterates over any file type in a directory
- Uses Finder-style Quick Look preview (`qlmanage -p`)
- Terminal or GUI-based (via applescript) text input
- Optional auto-numbering (`01_`, `02_`, …)
- Append to or replace filenames
- Rename or copy files

---

## Requirements

- macOS
- Bash (compatible with the default macOS Bash 3.2 or higher)
- Quick Look (`qlmanage`, built-in)
- AppleScript (`osascript`, built-in)

No Homebrew or external dependencies required.

---

## Script-based (automatic) installation

```bash
chmod +x install.sh
./install.sh
```

After running this, restart your terminal. 

## Manual installation 
Clone the repository and make the script executable:

```bash
git clone https://github.com/yourname/peek-rename.git
cd peek-rename
chmod +x peek-rename
```

Optionally place it somewhere on your PATH:

```bash
mv peek-rename ~/.local/bin/
```

---

## Basic Usage

```bash
peek-rename <directory-with-files>
```
(Note that if no directory is provided, the current directory is used.)

For each file:
1. The file is previewed using Quick Look (the same as if you press the space bar on Finder)
2. You enter a description
3. The file is renamed (or copied) with this new name as the description

---

## Command-Line Options

Some additional (very helpful) behavior is opt-in via command line arguments.

### Core Options

| Option | Description |
|------|------------|
| `-i`, `--inc` | Auto-number files (`01_`, `02_`, …) |
| `-a`, `--append` | Append text instead of replacing filename |
| `-c`, `--copy` | Copy file instead of renaming |
| `-g`, `--gui` | Use GUI dialog for text input |

---

## GUI Mode (via applescript)

Enable GUI mode with:

```bash
peek-rename --gui
```

Behavior in GUI mode:

1. File is previewed using Quick Look
2. A dialog appears with buttons:
   - Rename: apply description and rename/copy file
   - Skip: skip the file
   - Back: return to the previous file
   - Cancel or Esc: quit immediately (Note: this needs testing)
3. Preview closes after the action

---

## Auto-Numbering

```bash
peek-rename --inc
```

Produces filenames like:

```
01_description.jpg
02_description.jpg
```

---

## Append Mode

```bash
peek-rename --append
```

Preserves the original filename:

```
originalname_description.pdf
```

Can be combined with numbering:

```bash
peek-rename --inc --append
```

```
01_originalname_description.pdf
```

---

## Copy Instead of Rename

```bash
peek-rename --copy
```

- The original file is left untouched
- A new file is created with the new name

---

## Implementation notes

-`qlmanage -p` achieves the same preview mechanism Finder does when you press spacebar
- GUI dialogs are implemented with AppleScript, you can change it to python-based/etc but will require non-shell scripting tools
- Filenames are sanitized to avoid invalid characters (needs testing)

---

## License

GNU General Public License (GPL)

