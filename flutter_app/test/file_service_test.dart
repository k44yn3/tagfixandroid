import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import '../lib/services/file_service.dart';

void main() {
  group('FileService', () {
    late Directory tempDir;
    late FileService fileService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tagfix_test');
      fileService = FileService();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('scanDirectory finds audio files', () async {
      // Create dummy files
      await File(p.join(tempDir.path, 'song1.mp3')).create();
      await File(p.join(tempDir.path, 'song2.flac')).create();
      await File(p.join(tempDir.path, 'image.jpg')).create(); // Should be ignored
      
      final files = await fileService.scanDirectory(tempDir.path);
      
      expect(files.length, 2);
      expect(files.any((f) => f.filename == 'song1.mp3'), true);
      expect(files.any((f) => f.filename == 'song2.flac'), true);
    });

    test('scanDirectory is recursive', () async {
      final subDir = await Directory(p.join(tempDir.path, 'subdir')).create();
      await File(p.join(subDir.path, 'song3.wav')).create();
      
      final files = await fileService.scanDirectory(tempDir.path);
      
      expect(files.length, 1);
      expect(files.first.filename, 'song3.wav');
    });
  });
}
