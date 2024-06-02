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
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';
import 'package:xivr/src/arg_parser.dart' as arg_parser;
import 'package:xivr/src/get_arguments.dart';
import 'package:xivr/src/get_image_viewer.dart';

List<String> testGetArguments({
  required final List<String> args,
  required final FileSystem filesystem,
  // ignore: prefer_expression_function_bodies
}) {
  return getArguments(
    filesystem: filesystem,
    parser: arg_parser.cliParser,
    results: arg_parser.cliParser.parse(args),
    // image viewer is nsxiv by default
    imageViewer: 'nsxiv',
  );
}

Future<void> testDoesCommandExist(final String _) => Future.value();

void main() {
  late FileSystem fakeFileSystem;
  late CommandExistenceCheckFunction commandExistenceTestFunction;
  setUp(() {
    fakeFileSystem = MemoryFileSystem();
    commandExistenceTestFunction = testDoesCommandExist;
  });

  group('Image viewer', () {
    test('defaults to nsxiv', () async {
      expect(
        getImageViewer(
          FakePlatform(environment: {}),
          commandExistenceTestFunction,
        ),
        'nsxiv',
      );
    });

    test('uses environment variable to override', () async {
      const String expected = 'abc';
      expect(
        getImageViewer(
          FakePlatform(environment: {'IMAGE_VIEWER' : expected}),
          commandExistenceTestFunction,
        ),
        expected,
      );
    });
  });

  group('Parsing arguments', () {
    group('happens properly', () {
      // --help and --version would ignore other provided options
      final List<String> testShortArguments = [
        '-A', '25',
        '-a',
        '-b',
        '-c',
        '-e', 'abc',
        '-f',
        '-G', '21',
        '-g', '1920x1080',
        '-N', 'hello',
        '-n', '12',
        '-o',
        '-p',
        '-q',
        '-r',
        '-S', '0.37',
        '-s', 'd',
        '-t',
        '-Z',
        '-z', '85',
        '-0',
        // these don't have short form equivalents
        '--anti-alias=no',
        '--alpha-layer=no',
      ];

      final List<String> testLongArguments = [
        '--framerate', '25',
        '--animate',
        '--no-bar',
        '--clean-cache',
        '--embed', 'abc',
        '--fullscreen',
        '--gamma', '21',
        '--geometry', '1920x1080',
        '--class', 'hello',
        '--start-at', '12',
        '--stdout',
        '--private',
        '--quiet',
        '--recursive',
        '--ss-delay', '0.37',
        '--scale-mode', 'd',
        '--thumbnail',
        '--zoom-100',
        '--zoom', '85',
        '--null',
        '--anti-alias=no',
        '--alpha-layer=no',
      ];

      final List<String> expectedArguments = testShortArguments;
      test('short form', () {
        final List<String> determinedArguments = testGetArguments(
          args: testShortArguments,
          filesystem: fakeFileSystem,
        );
        expect(determinedArguments, expectedArguments);
      });

      test('long form', () {
        final List<String> determinedArguments = testGetArguments(
          args: testLongArguments,
          filesystem: fakeFileSystem,
        );
        expect(determinedArguments, expectedArguments);
      });
    });

    test('options with optional arguments are sent properly', () {
      final List<String> testArguments = [
        '--anti-alias=',
        '--alpha-layer=',
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );

      expect(determinedArguments.contains('--anti-alias'), true);
      expect(determinedArguments.contains('--alpha-layer'), true);
    });

    test('options with optional arguments are sent properly with arguments', () {
      final List<String> testArguments = [
        '--anti-alias', 'abc',
        '--alpha-layer', 'xyz',
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );

      expect(determinedArguments.contains('--anti-alias=abc'), true);
      expect(determinedArguments.contains('--alpha-layer=xyz'), true);
    });

    test('displays additional help message and takes priority over version', () {
      final List<String> testArguments = [
        '--help',
        '--version',
      ];
      final List<String> outputs = [];

      IOOverrides.runZoned(
        () {
          testGetArguments(args: testArguments, filesystem: fakeFileSystem);
          expect(
            outputs.contains(
              'Replace "nsxiv" with "xivr" in the usage information below. '
              'For detailed help run "man nsxiv".\n'
            ),
            true,
          );
          expect(outputs.contains('xivr with '), false);
        },
        stdout: () => FakeStdout(outputs: outputs),
      );
    });

    test('displays additional help message when run without any arguments', () {
      final List<String> testArguments = [];
      final List<String> outputs = [];

      IOOverrides.runZoned(
        () {
          testGetArguments(args: testArguments, filesystem: fakeFileSystem);
          expect(
            outputs.contains(
              'Replace "nsxiv" with "xivr" in the usage information below. '
              'For detailed help run "man nsxiv".\n'
            ),
            true,
          );
        },
        stdout: () => FakeStdout(outputs: outputs),
      );
    });

    test('displays additional version message', () {
      final List<String> testArguments = [
        '--version',
      ];
      final List<String> outputs = [];

      IOOverrides.runZoned(
        () {
          testGetArguments(args: testArguments, filesystem: fakeFileSystem);
          // version is undefined by default
          expect(outputs.contains('xivr undefined with '), true);
        },
        stdout: () => FakeStdout(outputs: outputs),
      );
    });

    test('ignores provided position when only a single file is given', () {
      final String initialPosition = 12.toString();
      final File validFile = fakeFileSystem.file('/file.png')..createSync();

      final List<String> testArguments =[
        '-n', initialPosition,
        validFile.path,
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );
      final int indexOfStartAt = determinedArguments.indexOf('-n') + 1;
      expect(determinedArguments[indexOfStartAt] != initialPosition, true);
    });

    test('adds position when not given and a file is given among multiple supported files', () {
      fakeFileSystem.file('/image1.png').createSync();
      final File validFile = fakeFileSystem.file('/image2.png')..createSync();
      fakeFileSystem.file('/image3.png').createSync();
      final List<String> testArguments = [
        validFile.path,
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );
      expect(testArguments.contains('-n'), false);
      expect(determinedArguments.contains('-n'), true);
    });

    test('does not ignore provided position when a directory is given', () {
      final String initialPosition = 12.toString();
      final Directory testDirectory = fakeFileSystem.directory('/testDirectory')..createSync();
      final List<String> testArguments = [
        '-n', initialPosition,
        testDirectory.path,
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );
      final int indexOfStartAt = determinedArguments.indexOf('-n') + 1;
      expect(determinedArguments[indexOfStartAt] == initialPosition, true);
    });

    test('does not ignore provided position when multiple files are given', () {
      final String initialPosition = 12.toString();
      final File validFile1 = fakeFileSystem.file('/image1.png')..createSync();
      final File validFile2 = fakeFileSystem.file('/image2.png')..createSync();
      final List<String> testArguments = [
        '-n', initialPosition,
        validFile1.path,
        validFile2.path,
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );
      final int indexOfStartAt = determinedArguments.indexOf('-n') + 1;
      expect(determinedArguments[indexOfStartAt] == initialPosition, true);
    });

    test('ignores provided position when an unsupported file is given', () {
      final String initialPosition = 12.toString();
      final File invalidFile = fakeFileSystem.file('/invalidFile')..createSync();
      final List<String> testArguments = [
        '-ab',
        '-n', initialPosition,
        '--alpha-layer=no',
        invalidFile.path,
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );
      expect(determinedArguments.contains('-n'), false);
      expect(determinedArguments.contains(initialPosition), false);
      expect(determinedArguments.contains('-a'), true);
      expect(determinedArguments.contains('-b'), true);
      expect(determinedArguments.contains('--alpha-layer=no'), true);
    });

    test('turns thumbnail mode on when any argument is a directory', () {
      final Directory testDirectory = fakeFileSystem.directory('/testDirectory')..createSync();
      final File testFile = fakeFileSystem.file('/image.png')..createSync();

      final List<String> testArguments = [
        testDirectory.path,
        testFile.path,
      ];
      final List<String> determinedArguments = testGetArguments(
        args: testArguments,
        filesystem: fakeFileSystem,
      );
      expect(testArguments.contains('-t'), false);
      expect(determinedArguments.contains('-t'), true);
    });
  });

  group('Stdin handling', () {
    test('does not include any stdin flag for child process', () {
      final List<List<String>> testArgumentsList = [
        ['-'],
        ['-i'],
        ['--stdin'],
      ];

      IOOverrides.runZoned(
        () {
          for (final List<String> arguments in testArgumentsList) {
            final List<String> determinedArguments = testGetArguments(
              args: arguments,
              filesystem: MemoryFileSystem(),
            );
            expect(determinedArguments.contains('-'), false);
            expect(determinedArguments.contains('-i'), false);
            expect(determinedArguments.contains('--stdin'), false);
          }
        },
        stdin: () => FakeStdin(inputs: []),
      );
    });

    test('accepts inputs when "-" is the only argument', () {
      final List<int> fakeStdinInputs  = [65, -1];
      final List<String> testArguments = [
        '-',
      ];

      IOOverrides.runZoned(
        () {
          expect(fakeStdinInputs.isEmpty, false);
          testGetArguments(
            args: testArguments,
            filesystem: MemoryFileSystem(),
          );
          expect(fakeStdinInputs.isEmpty, true);
        },
        stdin: () => FakeStdin(inputs: fakeStdinInputs),
      );
    });

    test('does not accept inputs when "-" is not the only argument', () {
      final List<int> fakeStdinInputs = [65, -1];
      final File testFile = fakeFileSystem.file('/image.png');
      final List<String> testArguments= [
        '-',
        testFile.path,
      ];

      IOOverrides.runZoned(
        () {
          expect(fakeStdinInputs.isEmpty, false);
          testGetArguments(
            args: testArguments,
            filesystem: MemoryFileSystem(),
          );
          expect(fakeStdinInputs.isEmpty, false);
        },
        stdin: () => FakeStdin(inputs: fakeStdinInputs),
      );
    });

    test('properly handles multiple arguments', () {
      final List<int> fakeStdinInputs = [65, 10, 66, 10, 67, -1];
      final List<String> expectedArguments = ['A', 'B', 'C'];
      final List<String> testArguments= [
        '-',
      ];

      IOOverrides.runZoned(
        () {
          expect(fakeStdinInputs.isEmpty, false);
          final List<String> determinedArguments = testGetArguments(
            args: testArguments,
            filesystem: MemoryFileSystem(),
          );
          expect(determinedArguments, expectedArguments);
          expect(fakeStdinInputs.isEmpty, true);
        },
        stdin: () => FakeStdin(inputs: fakeStdinInputs),
      );
    });

    test('places inputs before arguments', () {
      final List<int> fakeStdinInputs= [65, -1];
      final File testFile = fakeFileSystem.file('/image.png');
      final List<String> testArguments= [
        '-i',
        testFile.path,
      ];

      IOOverrides.runZoned(
        () {
          expect(fakeStdinInputs.isEmpty, false);
          final List<String> determinedArguments = testGetArguments(
            args: testArguments,
            filesystem: fakeFileSystem,
          );
          expect(fakeStdinInputs.isEmpty, true);
          expect(determinedArguments.contains('A'), true);
          expect(
            determinedArguments.indexOf('A') < determinedArguments.indexOf(testFile.absolute.path),
            true,
          );
        },
        stdin: () => FakeStdin(inputs: fakeStdinInputs),
      );
    });
  });

  group('getSupportedFiles', () {
    test('returns absolute paths', () {
      final File testFile1 = fakeFileSystem.file('/image1.png')..createSync();
      final File testFile2 = fakeFileSystem.file('/image2.png')..createSync();
      final List<String> testFiles = [
        testFile1.path,
        testFile2.path,
      ];
      final List<String> determinedFiles = getSupportedFiles(
        paths: testFiles,
        filesystem: fakeFileSystem,
      );
      for (final String file in determinedFiles) {
        expect(fakeFileSystem.file(file).isAbsolute, true);
      }
    });

    test('returns valid list of files when given a parent directory', () {
      final Directory testDirectory = fakeFileSystem.directory('/testDirectory')..createSync();
      final File invalidTestFile = fakeFileSystem.file('/testDirectory/invalidFile')..createSync();
      fakeFileSystem.file('/testDirectory/image1.png').createSync();
      fakeFileSystem.file('/testDirectory/image2.png').createSync();

      final List<String> testFiles = [
        testDirectory.path,
      ];
      final List<String> determinedFiles = getSupportedFiles(
        paths: testFiles,
        filesystem: fakeFileSystem,
      );
      expect(invalidTestFile.parent.absolute.path, testDirectory.absolute.path);
      expect(determinedFiles.contains(testDirectory.absolute.path), false);
      expect(determinedFiles.contains(invalidTestFile.absolute.path), false);
      for (final String file in determinedFiles) {
        expect(fakeFileSystem.isDirectorySync(file), false);
        expect(fakeFileSystem.isFileSync(file), true);
      }
    });

    test('recurses into directories', () {
      final Directory testDirectory = fakeFileSystem.directory('/testDirectory')..createSync();
      fakeFileSystem.file('/testDirectory/image1.png').createSync();
      fakeFileSystem.directory('/testDirectory/testSubDirectory').createSync();
      final File fileInSubDir = fakeFileSystem.file('/testDirectory/testSubDirectory/subImage.png')..createSync();

      final List<String> testFiles = [
        testDirectory.path,
      ];
      final List<String> determinedFiles = getSupportedFiles(
        paths: testFiles,
        filesystem: fakeFileSystem,
        recursive: true,
      );
      expect(fileInSubDir.parent.absolute.path == testDirectory.absolute.path, false);
      expect(determinedFiles.contains(fileInSubDir.absolute.path), true);
    });
  });

  test('pathHasImgExtension determines img files correctly using extension', () {
    expect(pathHasImgExtension('image.png'), true);
    expect(pathHasImgExtension('image.PNG'), true);
    expect(pathHasImgExtension('image.PNG.png'), true);
    expect(pathHasImgExtension('image.jpeg'), true);
    expect(pathHasImgExtension('image.jpg'), true);
    expect(pathHasImgExtension('image.gif'), true);
    expect(pathHasImgExtension('image.svg'), true);
    expect(pathHasImgExtension('image.jxl'), true);
    expect(pathHasImgExtension('image.webp'), true);
    expect(pathHasImgExtension('image.tiff'), true);
    expect(pathHasImgExtension('image.heif'), true);
    expect(pathHasImgExtension('image.avif'), true);
    expect(pathHasImgExtension('image.ico'), true);
    expect(pathHasImgExtension('image.bmp'), true);
    expect(pathHasImgExtension('image.pam'), true);
    expect(pathHasImgExtension('image.pbm'), true);
    expect(pathHasImgExtension('image.ppm'), true);
    expect(pathHasImgExtension('image.tga'), true);
    expect(pathHasImgExtension('image.qoi'), true);
    expect(pathHasImgExtension('image.ff'), true);
    expect(pathHasImgExtension('image'), false);
  });
}

class FakeStdin implements Stdin {
  FakeStdin({required this.inputs});
  final List<int> inputs;

  @override
  dynamic noSuchMethod(final Invocation invocation) => super.noSuchMethod(invocation);

  @override
  int readByteSync() => inputs.isEmpty ? -1 : inputs.removeAt(0);
}

class FakeStdout implements Stdout {
  FakeStdout({required this.outputs});
  final List<String> outputs;

  @override
  dynamic noSuchMethod(final Invocation invocation) => super.noSuchMethod(invocation);

  @override
  void write(final Object? object) {
    outputs.add(object.toString());
  }
}
