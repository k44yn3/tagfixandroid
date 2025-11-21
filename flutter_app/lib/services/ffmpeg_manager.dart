import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class FfmpegManager {
  static FfmpegManager? _instance;
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();
  bool _isAvailable = true;
  
  FfmpegManager._();
  
  static FfmpegManager get instance {
    _instance ??= FfmpegManager._();
    return _instance!;
  }
  
  /// Execute FFmpeg command
  /// Returns true if successful, false otherwise
  Future<bool> executeCommand(String command) async {
    try {
      final int rc = await _flutterFFmpeg.execute(command);
      
      if (rc == 0) {
        return true;
      } else {
        print('FFmpeg command failed with return code: $rc');
        return false;
      }
    } catch (e) {
      print('FFmpeg execution error: $e');
      return false;
    }
  }
  
  /// Execute FFmpeg command with progress callback
  Future<bool> executeCommandWithProgress(
    String command,
    Function(double)? onProgress,
  ) async {
    try {
      // Enable statistics callback for progress tracking
      if (onProgress != null) {
        _flutterFFmpegConfig.enableStatisticsCallback((statistics) {
          // Calculate progress based on time
          final time = statistics.time;
          if (time > 0) {
            // This is a simplified progress calculation
            // You might need to adjust based on total duration
            onProgress(time.toDouble());
          }
        });
      }
      
      final int rc = await _flutterFFmpeg.execute(command);
      
      // Disable callback after execution
      if (onProgress != null) {
        _flutterFFmpegConfig.enableStatisticsCallback(null);
      }
      
      if (rc == 0) {
        return true;
      } else {
        print('FFmpeg command failed with return code: $rc');
        return false;
      }
    } catch (e) {
      print('FFmpeg execution error: $e');
      return false;
    }
  }
  
  /// Check if ffmpeg is available
  Future<bool> isAvailable() async {
    return _isAvailable;
  }
  
  /// Get FFmpeg version
  Future<String?> getVersion() async {
    try {
      final String? version = await _flutterFFmpegConfig.getFFmpegVersion();
      return version;
    } catch (e) {
      print('Error getting FFmpeg version: $e');
      return null;
    }
  }
}
