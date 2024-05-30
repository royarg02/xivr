// X Image Viewer Rifle - wrapper for *sxiv with nice features
// Copyright (C) 2024 Anurag Roy
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:xivr/src/read_stdin.dart';
import 'package:xivr/src/user_messages.dart';

List<String> getArguments({
  required final FileSystem filesystem,
  required final ArgParser parser,
  required final ArgResults results,
  required final String imageViewer,
}) {
  const String helpOptionName = 'help';
  const String versionOptionName = 'version';
  const String recursiveOptionName = 'recursive';
  const String startAtOptionName = 'start-at';
  const String stdinOptionName = 'stdin';
  const String thumbnailOptionName = 'thumbnail';

  List<String> paths = List.from(results.rest);
  final List<String> parsedOptions = results.options.where(results.wasParsed).toList();
  final Map<String, String> optionsOverrides = {};

  if (parsedOptions.contains(helpOptionName) || results.arguments.isEmpty) {
    displayHelpMessage(imageViewer);
    return regenerateOptions([helpOptionName], parser, results);
  }

  if (parsedOptions.contains(versionOptionName)) {
    displayVersionMessage();
    return regenerateOptions([versionOptionName], parser, results);
  }

  if (parsedOptions.contains(stdinOptionName) || (paths.length == 1 && paths.contains('-'))) {
    parsedOptions.remove(stdinOptionName);
    paths = [
      // Keep paths passed through stdin before paths as arguments
      ...readStdin().split('\n').where((final path) => path.isNotEmpty),
      ...paths,
    ]..remove('-');
  }

  if (paths.any(filesystem.isDirectorySync)) {
    parsedOptions.add(thumbnailOptionName);
  }

  if (paths.length == 1 && filesystem.isFileSync(paths[0])) {
    final File file = filesystem.file(paths[0]);
    // fallback in case the file doesn't have the valid extension
    if (!pathHasImgExtension(file.path)) {
      parsedOptions.remove(startAtOptionName);
      paths = [file.path];
    } else {
      paths = getSupportedFiles(
        paths: [file.absolute.parent.path],
        filesystem: filesystem,
      );
      final int startAt = paths.indexOf(file.absolute.path) + 1;
      optionsOverrides.addAll({
        startAtOptionName : startAt.toString(),
      });
    }
  } else if (parsedOptions.contains(startAtOptionName)) {
    paths = getSupportedFiles(
      paths: paths,
      filesystem: filesystem,
      recursive: parsedOptions.contains(recursiveOptionName),
    );
  }

  return [
    ...regenerateOptions(parsedOptions, parser, results, optionArgumentOverrides: optionsOverrides),
    ...paths,
  ];
}

List<String> regenerateOptions(
  final List<String> parsedOptions,
  final ArgParser parser,
  final ArgResults results,
  {final Map<String, String> optionArgumentOverrides = const {},}
) {
  // List of option names that accept an optional argument.
  const List<String> optionalArgumentOptionNames = [
    'alpha-layer',
    'anti-alias',
  ];

  final List<String> regeneratedOptions = [];
  for (final String parsedOption in parsedOptions) {
    final Option option = parser.findByNameOrAlias(parsedOption)!;
    String optionArgument = option.abbr != null ? '-${option.abbr}' : '--$parsedOption';
    dynamic optionValue;
    if (option.type != OptionType.flag) {
      optionValue = optionArgumentOverrides.containsKey(parsedOption)
                    ? optionArgumentOverrides[parsedOption]
                    : results.option(parsedOption);
    }
    if (optionalArgumentOptionNames.contains(parsedOption)) {
      if((optionValue as String).isNotEmpty) {
        optionArgument = '$optionArgument=$optionValue';
      }
      optionValue = null;
    }
    regeneratedOptions.addAll([
      optionArgument,
      if (optionValue != null) optionValue.toString(),
    ]);
  }
  return regeneratedOptions;
}

List<String> getSupportedFiles({
  required final List<String> paths,
  required final FileSystem filesystem,
  final bool recursive = false,
}) {
  final List<FileSystemEntity> allEntities = [];
  for (final path in paths) {
    if (filesystem.isDirectorySync(path)) {
      allEntities.addAll(filesystem.directory(path).listSync(recursive: recursive));
    } else {
      allEntities.add(filesystem.file(path));
    }
  }

  final List<String> supportedEntitiesPaths = allEntities
      .map((final entity) => entity.absolute.path)
      .where(pathHasImgExtension)
      .toList()
    ..sort((final a, final b) => a.compareTo(b));

  return supportedEntitiesPaths;
}

bool pathHasImgExtension(final String path) => path.contains(
  RegExp(
    r'\.(jpe?g|png|gif|svg|jxl|webp|tiff|heif|avif|ico|bmp|pam|pbm|ppm|tga|qoi|ff)$',
    caseSensitive: false,
  ),
);
