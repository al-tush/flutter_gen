import 'dart:io' show Platform;

import 'package:ds_flutter_gen_core/version.gen.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

final separator = Platform.pathSeparator;

void main() {
  test('Execute dsfluttergen', () async {
    final process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart'],
    );
    expect(
      await process.stdout.next,
      equals('[FlutterGen] v$packageVersion Loading ...'),
    );
    await process.shouldExit(0);
  });

  test('Execute dsfluttergen --config pubspec.yaml', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--config', 'pubspec.yaml'],
    );
    expect(
      await process.stdout.next,
      equals('[DSFlutterGen] v$packageVersion Loading ...'),
    );
    await process.shouldExit(0);
  });

  test('Execute dsfluttergen --help', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--help'],
    );
    expect(
      await process.stdout.next,
      equals('[dsFlutterGen] Usage of the `fluttergen` command:'),
    );
    expect(
      await process.stdout.next,
      equals('-c, --config          Set the path of pubspec.yaml.'),
    );
    final line = await process.stdout.next;
    expect(line.trim(), equals('(defaults to "pubspec.yaml")'));
    await process.shouldExit(0);
  });

  test('Execute dsfluttergen --version', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--version'],
    );
    expect(await process.stdout.next, equals('[DSFlutterGen] v$packageVersion'));
    await process.shouldExit(0);
  });

  test('Execute wrong arguments with dsfluttergen --wrong', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--wrong'],
    );
    expect(
      await process.stderr.next,
      equals('Unhandled exception:'),
    );
    expect(
      await process.stderr.next,
      equals('FormatException: Could not find an option named "--wrong".'),
    );
    await process.shouldExit(255);
  });

  test('Execute deprecated config with dsfluttergen', () async {
    final process = await TestProcess.start(
      'dart',
      [
        'bin/flutter_gen_command.dart',
        '--config',
        'test/deprecated_configs.yaml',
      ],
    );
    expect(
      await process.stderr.next,
      equals('Unhandled exception:'),
    );
    expect(
      await process.stderr.next,
      startsWith('InvalidSettingsException: '),
    );
    final rest = (await process.stderr.rest.toList()).join('\n');
    expect(rest, contains('style'));
    expect(rest, contains('package_parameter_enabled'));
    await process.shouldExit(255);
  });
}
