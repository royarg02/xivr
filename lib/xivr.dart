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

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:platform/platform.dart';

List<String> parseArguments({
  required final List<String> args,
  required final FileSystem filesystem,
  required final Platform platform,
}) {
  final ArgParser parser = ArgParser()
    ..addOption('framerate', abbr: 'A')
    ..addFlag('animate', abbr: 'a', negatable: false)
    ..addFlag('no-bar', abbr: 'b', negatable: false)
    ..addFlag('clean-cache', abbr: 'c', negatable: false)
    ..addOption('embed', abbr: 'e')
    ..addFlag('fullscreen', abbr: 'f', negatable: false)
    ..addOption('gamma', abbr: 'G')
    ..addOption('geometry', abbr: 'g')
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addFlag('stdin', abbr: 'i', negatable: false)
    ..addOption('class', abbr: 'N')
    ..addOption('start-at', abbr: 'n')
    ..addFlag('stdout', abbr: 'o', negatable: false)
    ..addFlag('private', abbr: 'p', negatable: false)
    ..addFlag('quiet', abbr: 'q', negatable: false)
    ..addFlag('recursive', abbr: 'r', negatable: false)
    ..addOption('ss-delay', abbr: 'S')
    ..addOption('scale-mode', abbr: 's')
    ..addFlag('thumbnail', abbr: 't', negatable: false)
    ..addFlag('version', abbr: 'v', negatable: false)
    ..addFlag('zoom-100', abbr: 'Z', negatable: false)
    ..addOption('zoom', abbr: 'z')
    ..addFlag('null', abbr: '0', negatable: false)
    ..addOption('anti-alias')
    ..addOption('alpha-layer');

  final ArgResults argResults = parser.parse(args);

  final String imageViewer = platform.environment['IMAGE_VIEWER'] ?? 'nsxiv';

  final int? framerate = int.tryParse(argResults.option('framerate') ?? '');
  final bool animate = argResults.flag('animate');
  final bool noBar = argResults.flag('no-bar');
  final bool cleanCache = argResults.flag('clean-cache');
  final String? embed = argResults.option('embed');
  final bool fullscreen = argResults.flag('fullscreen');
  final int? gamma = int.tryParse(argResults.option('gamma') ?? '');
  final String? geometry =  argResults.option('geometry');
  final bool help = argResults.flag('help');
  final bool stdin = argResults.flag('stdin') || (argResults.rest.length == 1 && argResults.rest[0] == '-');
  final String? className = argResults.option('class');
  final bool stdout = argResults.flag('stdout');
  final bool private = argResults.flag('private');
  final bool quiet = argResults.flag('quiet');
  final bool recursive = argResults.flag('recursive');
  final double? ssDelay = double.tryParse(argResults.option('ss-delay') ?? '');
  final String? scaleMode = argResults.option('scale-mode');
  final bool version = argResults.flag('version');
  final bool zoom100 = argResults.flag('zoom-100');
  final int? zoom = int.tryParse(argResults.option('zoom') ?? '');
  final bool nullSeparator = argResults.flag('null');
  final String? antiAlias = argResults.option('anti-alias');
  final String? alphaLayer = argResults.option('alpha-layer');
  int? startAt = int.tryParse(argResults.option('start-at') ?? '');
  bool thumbnail = argResults.flag('thumbnail');
  List<String> paths = argResults.rest;

  if (help) {
    printStdout(
      'Replace "$imageViewer" with "xivr" in the usage information below. '
      'For detailed help run "man $imageViewer".\n'
    );
  } else if (version) {
    printStdout('xivr with ');
  } else {
    if (stdin) {
      // Keep paths passed through stdin before paths as arguments
      paths = [
        ...readStdin().split('\n').where((final path) => path.isNotEmpty),
        ...paths,
      ]..remove('-');
    }

    thumbnail = thumbnail || paths.any(filesystem.isDirectorySync);

    if (paths.length == 1 && filesystem.isFileSync(paths[0])) {
      final File file = filesystem.file(paths[0]);
      // fallback in case the file doesn't have the valid extension
      if (!pathHasImgExtension(path: file.path)) {
        startAt = null;
        paths = [file.path];
      } else {
        paths = getSupportedFiles(
          paths: [file.absolute.parent.path],
          filesystem: filesystem,
        );
        startAt = paths.indexOf(file.absolute.path) + 1;
      }
    } else if (startAt != null) {
      paths = getSupportedFiles(
        paths: paths,
        filesystem: filesystem,
        recursive: recursive,
      );
    }
  }

  final List<String> arguments = [
    imageViewer,
    if (framerate != null) ...['-A', framerate.toString()],
    if (animate) '-a',
    if (noBar) '-b',
    if (cleanCache) '-c',
    if (embed != null) ...['-e', embed],
    if (fullscreen) '-f',
    if (gamma != null) ...['-G', gamma.toString()],
    if (geometry != null) ...['-g', geometry],
    if (help) '-h',
    // inputs from stdin have been already dealt with
    if (className != null) ...['-N', className],
    if (startAt != null) ...['-n', startAt.toString()],
    if (stdout) '-o',
    if (private) '-p',
    if (quiet) '-q',
    if (recursive) '-r',
    if (ssDelay != null) ...['-S', ssDelay.toString()],
    if (scaleMode != null) ...['-s', scaleMode],
    if (thumbnail) '-t',
    if (version) '-v',
    if (zoom100) '-Z',
    if (zoom != null) ...['-z', zoom.toString()],
    if (nullSeparator) '-0',
    if (antiAlias != null) '--anti-alias=$antiAlias',
    if (alphaLayer != null) '--alpha-layer=$alphaLayer',
    ...paths,
  ];

  return arguments;
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
      .where((final path) => pathHasImgExtension(path: path))
      .toList()
    ..sort((final a, final b) => a.compareTo(b));

  return supportedEntitiesPaths;
}

Future<void> runChildProcess({required final List<String> arguments}) async {
  await Process.start(
    'setsid',
    [
      '-f',
      ...arguments,
    ],
    mode: ProcessStartMode.inheritStdio,
  );
}

String readStdin({final Encoding encoding = systemEncoding}) {
  final List<int> input = [];
  while (true) {
    final int byte = stdin.readByteSync();
    if (byte < 0) {
      break;
    }
    input.add(byte);
  }
  return encoding.decode(input);
}

void printStdout(final String message) {
  stdout.write(message);
}

bool pathHasImgExtension({required final String path}) => path.contains(
  RegExp(
    r'\.(jpe?g|png|gif|svg|jxl|webp|tiff|heif|avif|ico|bmp|pam|pbm|ppm|tga|qoi|ff)$',
    caseSensitive: false,
  ),
);
