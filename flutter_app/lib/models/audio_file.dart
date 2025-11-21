import 'package:audiotags/audiotags.dart';

class AudioFile {
  final String path;
  final String filename;
  Tag? tags;
  bool isSelected;
  bool hasError;
  String? errorMessage;
  
  // Pending changes (for preview before saving)
  List<int>? pendingCover;
  String? pendingLyrics;

  AudioFile({
    required this.path,
    required this.filename,
    this.tags,
    this.isSelected = false,
    this.hasError = false,
    this.errorMessage,
    this.pendingCover,
    this.pendingLyrics,
  });
  
  bool get hasPendingChanges => pendingCover != null || pendingLyrics != null;


  AudioFile copyWith({
    String? path,
    String? filename,
    Tag? tags,
    bool? isSelected,
    bool? hasError,
    String? errorMessage,
    List<int>? pendingCover,
    String? pendingLyrics,
    bool clearPendingCover = false,
    bool clearPendingLyrics = false,
  }) {
    return AudioFile(
      path: path ?? this.path,
      filename: filename ?? this.filename,
      tags: tags ?? this.tags,
      isSelected: isSelected ?? this.isSelected,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingCover: clearPendingCover ? null : (pendingCover ?? this.pendingCover),
      pendingLyrics: clearPendingLyrics ? null : (pendingLyrics ?? this.pendingLyrics),
    );
  }
}
