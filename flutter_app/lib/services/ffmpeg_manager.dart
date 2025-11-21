import 'dart:io';

class FfmpegManager {
  static FfmpegManager? _instance;
  bool _isAvailable = false;
  
  FfmpegManager._();
  
  static FfmpegManager get instance {
    _instance ??= FfmpegManager._();
    return _instance!;
  }
  
  /// Execute FFmpeg command
  /// Returns true if successful, false otherwise
  Future<bool> executeCommand(String command) async {
    print('FFmpeg not available');
    return false;
  }
  
  /// Execute FFmpeg command with progress callback
  Future<bool> executeCommandWithProgress(
    String command,
    Function(double)? onProgress,
  ) async {
    print('FFmpeg not available');
    return false;
  }
  
  /// Check if ffmpeg is available
  Future<bool> isAvailable() async {
    return _isAvailable;
  }
  
  /// Get FFmpeg version
  Future<String?> getVersion() async {
    return 'Not available';
  }
}
