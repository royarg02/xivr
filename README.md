<!-- markdownlint-disable-file MD014 -->
# xivr

**X** **I**mage **V**iewer **R**ifle

A [Dart][1] command line application that acts as a wrapper for any image viewer
that has the same CLI as **\*sxiv**(either [nsxiv][2] or [sxiv][3]). By default,
it attempts to launch **nsxiv** which can be changed by setting the
`IMAGE_VIEWER` environment variable to the desired program.

## Features

- Forks the image viewer so as to not block the current shell session.
- Opens in thumbnail mode if any argument is a directory.
- If the argument is a single compatible file, opens all compatible files in its
parent directory which can be browsed around.

## Runtime dependencies

- [nsxiv][2] or the binary set in the `IMAGE_VIEWER` environment variable.
- [util-linux][4].

## Building and installation

- Set up the **Dart SDK**, [instructions are available here][5].
- Compile the application:

  ```shell
  $ cd xivr
  $ dart compile exe bin/xivr.dart -o <INSTALL_LOCATION_PREFERABLY_IN_PATH>/xivr
  ```

- Run the application:

  ```shell
  $ xivr
  ```

[1]: https://dart.dev
[2]: https://nsxiv.codeberg.page/
[3]: https://github.com/xyb3rt/sxiv
[4]: https://github.com/util-linux/util-linux
[5]: https://dart.dev/get-dart
