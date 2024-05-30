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
import 'package:platform/platform.dart';
import 'package:xivr/src/user_messages.dart';

typedef CommandExistenceCheckFunction = void Function(String);

String getImageViewer(
  final Platform localPlatform,
  [final CommandExistenceCheckFunction commandExistenceCheckFunction = doesCommandExist,]
) {
  final String imageViewer = localPlatform.environment['IMAGE_VIEWER'] ?? 'nsxiv';
  try {
    commandExistenceCheckFunction(imageViewer);
  } on CommandNotFoundException {
    displayInvalidImageViewerMessage(imageViewer);
    exit(1);
  }
  return imageViewer;
}

void doesCommandExist(final String command) {
  final ProcessResult checkProcessResult = Process.runSync(
    // This is the shell builtin
    'command',
    [
      '-v',
      command,
    ],
    runInShell: true,
  );

  final checkExitCode = checkProcessResult.exitCode;

  if (checkExitCode == 0) {
    return;
  }

  throw CommandNotFoundException(
    exitCode: checkExitCode,
    description: 'Command "$command" was not found on this system.\n',
  );
}

class CommandNotFoundException implements Exception {
  const CommandNotFoundException({
    required this.exitCode,
    required this.description,
  });

  final int exitCode;
  final String? description;

  @override
  String toString() => 'CommandNotFoundException: Error $exitCode'
    '${description == null ? '' : ':\n$description'}';
}
