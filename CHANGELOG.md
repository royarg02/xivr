<!-- markdownlint-disable-file MD041 -->
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
