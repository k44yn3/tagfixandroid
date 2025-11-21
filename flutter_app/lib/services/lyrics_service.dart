import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsResult {
  final int id;
  final String name;
  final String artistName;
  final String albumName;
  final int duration;
  final String? plainLyrics;
  final String? syncedLyrics;
  final bool instrumental;

  LyricsResult({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.duration,
    this.plainLyrics,
    this.syncedLyrics,
    required this.instrumental,
  });

  factory LyricsResult.fromJson(Map<String, dynamic> json) {
    return LyricsResult(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Title',
      artistName: json['artistName'] as String? ?? 'Unknown Artist',
      albumName: json['albumName'] as String? ?? 'Unknown Album',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
      instrumental: json['instrumental'] as bool? ?? false,
    );
  }
}

class LyricsService {
  static const String _baseUrl = 'https://lrclib.net/api';
  static const String _userAgent = 'TagFix/1.0.0 ( https://github.com/yourusername/tagfix )';

  Future<List<LyricsResult>> searchLyrics({
    required String artist,
    required String title,
    String? album,
  }) async {
    final queryParameters = {
      'artist_name': artist,
      'track_name': title,
      if (album != null && album.isNotEmpty) 'album_name': album,
    };

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParameters);

    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LyricsResult.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search lyrics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching lyrics: $e');
      return [];
    }
  }

  Future<LyricsResult?> getLyrics(int id) async {
    final uri = Uri.parse('$_baseUrl/get/$id');

    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        return LyricsResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get lyrics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting lyrics: $e');
      return null;
    }
  }
}
