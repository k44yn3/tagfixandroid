import 'dart:io';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';

class FfmpegManager {
  static FfmpegManager? _instance;
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
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return true;
      } else {
        final output = await session.getOutput();
        print('FFmpeg command failed: $output');
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
        FFmpegKitConfig.enableStatisticsCallback((statistics) {
          final time = statistics.getTime();
          if (time > 0) {
            onProgress(time.toDouble());
          }
        });
      }
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      // Disable callback after execution
      if (onProgress != null) {
        FFmpegKitConfig.enableStatisticsCallback(null);
      }
      
      if (ReturnCode.isSuccess(returnCode)) {
        return true;
      } else {
        final output = await session.getOutput();
        print('FFmpeg command failed: $output');
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
      final session = await FFmpegKit.execute('-version');
      final output = await session.getOutput();
      return output?.split('\n').first;
    } catch (e) {
      print('Error getting FFmpeg version: $e');
      return null;
    }
  }
}
