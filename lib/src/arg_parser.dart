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

final ArgParser cliParser = ArgParser()
    ..addOption('framerate', abbr: 'A')
    ..addFlag('animate', abbr: 'a', negatable: false)
    // The "bar" flags are unusual due to backwards compatibility
    ..addFlag('bar', negatable: false)
    ..addFlag('no-bar', abbr: 'b', negatable: false)
    ..addFlag('clean-cache', abbr: 'c', negatable: false)
    ..addOption('embed', abbr: 'e')
    ..addFlag('fullscreen', abbr: 'f', negatable: false)
    ..addOption('gamma', abbr: 'G')
    ..addOption('geometry', abbr: 'g')
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addFlag('stdin', abbr: 'i', negatable: false)
    ..addOption('name', abbr: 'N')
    ..addOption('start-at', abbr: 'n')
    ..addFlag('stdout', abbr: 'o', negatable: false)
    ..addFlag('private', abbr: 'p', negatable: false)
    ..addFlag('quiet', abbr: 'q', negatable: false)
    ..addFlag('recursive', abbr: 'r', negatable: false)
    ..addOption('ss-delay', abbr: 'S')
    ..addOption('scale-mode', abbr: 's')
    // The long form is xivr only
    ..addFlag('enable-thumbnail', abbr: 't', negatable: false)
    ..addOption('thumbnail')
    ..addFlag('version', abbr: 'v', negatable: false)
    ..addFlag('zoom-100', abbr: 'Z', negatable: false)
    ..addOption('zoom', abbr: 'z')
    ..addFlag('null', abbr: '0', negatable: false)
    ..addOption('anti-alias')
    ..addOption('alpha-layer')
    ..addOption('cache-allow')
    ..addOption('cache-deny');
