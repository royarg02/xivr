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
import 'package:xivr/src/get_image_viewer.dart';

void displayHelpMessage() {
  final String imageViewer = getImageViewer(const LocalPlatform());
  final String helpMessage =
    'Replace "$imageViewer" with "xivr" in the usage information below. '
    'For detailed help run "man $imageViewer".\n';

  stdout.write(helpMessage);
}

void displayVersionMessage() {
  // ignore: do_not_use_environment
  const String xivrVersion = String.fromEnvironment('VERSION', defaultValue: 'undefined');
  const String versionMessage = 'xivr $xivrVersion with ';

  stdout.write(versionMessage);
}

void displayInvalidImageViewerMessage(final String imageViewer) {
  final String invalidImageViewerImage = 'Image viewer "$imageViewer" not found.\n';

  stdout.write(invalidImageViewerImage);
}
