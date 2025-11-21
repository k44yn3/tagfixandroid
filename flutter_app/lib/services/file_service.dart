import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/audio_file.dart';

class FileService {
  static const Set<String> supportedExtensions = {
    '.mp3',
    '.flac',
    '.m4a',
    '.ogg',
    '.opus',
    '.wma',
    '.wav'
  };

  Future<List<AudioFile>> scanDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return [];
    }

    final List<AudioFile> audioFiles = [];

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(ext)) {
            audioFiles.add(AudioFile(
              path: entity.path,
              filename: p.basename(entity.path),
            ));
          }
        }
      }
    } catch (e) {
      print('Error scanning directory: $e');
    }

    // Sort by filename
    audioFiles.sort((a, b) => a.filename.toLowerCase().compareTo(b.filename.toLowerCase()));

    return audioFiles;
  }

  Future<String?> renameFile(AudioFile file, String newFilename) async {
    try {
      final File f = File(file.path);
      if (!await f.exists()) return null;

      final String dir = p.dirname(file.path);
      String newPath = p.join(dir, newFilename);
      
      // Ensure extension is preserved if not provided
      if (p.extension(newFilename).isEmpty) {
        newPath += p.extension(file.path);
      }

      if (await File(newPath).exists()) {
        throw Exception('File already exists');
      }

      await f.rename(newPath);
      return newPath;
    } catch (e) {
      print('Error renaming file: $e');
      return null;
    }
  }
}
