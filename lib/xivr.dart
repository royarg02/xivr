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

import 'dart:io';
import 'package:args/args.dart';
import 'package:file/local.dart';
import 'package:platform/platform.dart';
import 'package:xivr/src/arg_parser.dart';
import 'package:xivr/src/get_arguments.dart';
import 'package:xivr/src/get_image_viewer.dart';

void main(final List<String> args) async {
  final String imageViewer = getImageViewer(const LocalPlatform());

  final ArgParser parser = cliParser;
  late final ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } on ArgParserException catch (exception) {
    stdout.writeln(exception.message);
    exit(1);
  }

  final List<String> arguments = getArguments(
    filesystem: const LocalFileSystem(),
    parser: parser,
    results: argResults,
    imageViewer: imageViewer,
  );

  await Process.start(
    'setsid',
    [
      '-f',
      imageViewer,
      ...arguments,
    ],
    mode: ProcessStartMode.inheritStdio,
  );
}
