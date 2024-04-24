### Parallel ZIP/RAR Brute Force Cracker

This tool is designed to brute force ZIP and RAR files using parallel processing. It supports both single file cracking and recursive directory traversal.

#### Usage:

```bash
Usage: brute_force.sh [-d <directory>] [-w <wordlist>] [-e <extract_dir>] [-f <file>]

  -d <directory>   : The directory containing RAR or ZIP files.
  -w <wordlist>    : The dictionary file containing potential passwords.
  -e <extract_dir> : Directory where files will be extracted if password is correct.
  -f <file>        : Single RAR or ZIP file to crack.
```

#### Features:
- **Parallel Processing:** Utilizes parallel processing to speed up the cracking process.
- **Supports ZIP and RAR:** Capable of cracking both ZIP and RAR archive formats.
- **Flexible Usage:** Supports cracking a single file or traversing through directories.

#### Example:

```bash
./brute_force.sh -d /path/to/archives -w wordlist.txt -e /path/to/extracted
./brute_force.sh -d /path/to/archives/archive.zip -w wordlist.txt -e /path/to/extracted
```

#### Notes:
- This tool should be used responsibly and only on files you have the legal authority to access.
- The success of cracking depends heavily on the quality and size of the wordlist provided.
