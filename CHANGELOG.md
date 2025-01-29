<!-- markdownlint-disable-file MD041 -->
## 1.2.0

- Supports `nsxiv` v33.
  - Adds `bar` flag, `-b` still implies `--no-bar`.
  - Supports new `cache-allow` and `cache-deny` options.
  - Renames `class` option to `name` with the shorthand unchanged.
  - `thumbnail` is now an option accepting an optional `no` as argument. As such
  same [caveats](https://github.com/royarg02/xivr#caveats) now apply.
  - The flag with `-t` shorthand is now named `enable-thumbnail`. This is
  **xivr** only, as the parser doesn't support flags without names.
- Files are now ordered case-insensitively.
- Bumps Dart SDK to `3.6.0`.

## 1.1.2

- Fix missing position when it is not given and a supported file is provided
among multiple supported files.

## 1.1.1

- Fix tests for CI.

## 1.1.0

- Fix error for options with optional arguments, with some caveats.
  - Still requires specifying an empty argument, for e.g., `--alpha-layer=`
- Add check for the specified image viewer(either `nsxiv` or `IMAGE_VIEWER`)
availablity on system.
- Handle error for invalid option.
- Add `xivr` version to version message.
- Bumps Dart SDK to `3.4.0`.

## 1.0.2

- Shows additional help message when not given any arguments.

## 1.0.1

- No functionality changes.
- Lowers Dart SDK constraint to fix ArchLinux package build.
- Some CI and documentation updates.

## 1.0.0

- Initial version.
