import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../services/tag_service.dart';
import '../providers/app_state.dart';
import 'lyrics_edit_dialog.dart';

class LyricsWidget extends StatefulWidget {
  final AudioFile file;

  const LyricsWidget({super.key, required this.file});

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();
}

class _LyricsWidgetState extends State<LyricsWidget> {
  String? _lyrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void didUpdateWidget(covariant LyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if file path changed OR if tags changed (after reloadFile)
    // Also reload if pending lyrics changed
    if (oldWidget.file.path != widget.file.path || 
        oldWidget.file.tags != widget.file.tags ||
        oldWidget.file.pendingLyrics != widget.file.pendingLyrics) {
      _loadLyrics();
    }
  }

  Future<void> _loadLyrics() async {
    // If we have pending lyrics, use them directly
    if (widget.file.pendingLyrics != null) {
      if (mounted) {
        setState(() {
          _lyrics = widget.file.pendingLyrics;
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    final tagService = TagService();
    final lyrics = await tagService.getLyrics(widget.file);
    if (mounted) {
      setState(() {
        _lyrics = lyrics;
        _isLoading = false;
      });
    }
  }

  Future<void> _editLyrics() async {
    // Pass pending lyrics if available, otherwise current lyrics
    final initialLyrics = widget.file.pendingLyrics ?? _lyrics ?? '';
    
    await showLyricsEditDialog(
      context,
      widget.file,
      initialLyrics,
    );
    
    // No need to reload file here, AppState handles pending changes
    // didUpdateWidget will catch the change in pendingLyrics
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lyrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FilledButton.tonalIcon(
              onPressed: _editLyrics,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Lyrics'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.file.pendingLyrics != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: widget.file.pendingLyrics != null ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _lyrics == null || _lyrics!.isEmpty
                  ? Center(
                      child: Text(
                        'No lyrics',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(
                        _lyrics!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
