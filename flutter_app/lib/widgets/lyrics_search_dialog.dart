import 'package:flutter/material.dart';
import '../services/lyrics_service.dart';

class LyricsSearchDialog extends StatefulWidget {
  final String initialArtist;
  final String initialTitle;
  final String initialAlbum;

  const LyricsSearchDialog({
    super.key,
    required this.initialArtist,
    required this.initialTitle,
    required this.initialAlbum,
  });

  @override
  State<LyricsSearchDialog> createState() => _LyricsSearchDialogState();
}

class _LyricsSearchDialogState extends State<LyricsSearchDialog> {
  late TextEditingController _artistController;
  late TextEditingController _titleController;
  late TextEditingController _albumController;
  
  final _lyricsService = LyricsService();
  List<LyricsResult> _results = [];
  bool _isSearching = false;
  LyricsResult? _selectedResult;
  String? _previewLyrics;
  bool _isLoadingPreview = false;

  @override
  void initState() {
    super.initState();
    _artistController = TextEditingController(text: widget.initialArtist);
    _titleController = TextEditingController(text: widget.initialTitle);
    _albumController = TextEditingController(text: widget.initialAlbum);
    
    // Removed auto-search as per user request
  }

  @override
  void dispose() {
    _artistController.dispose();
    _titleController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_artistController.text.isEmpty && _titleController.text.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _results = [];
      _selectedResult = null;
      _previewLyrics = null;
    });

    try {
      final results = await _lyricsService.searchLyrics(
        artist: _artistController.text,
        title: _titleController.text,
        album: _albumController.text,
      );

      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching lyrics: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _selectResult(LyricsResult result) async {
    setState(() {
      _selectedResult = result;
      _isLoadingPreview = true;
    });

    // If we already have the lyrics in the search result, use them
    // Otherwise fetch full details (though search usually returns them)
    String? lyrics = result.syncedLyrics ?? result.plainLyrics;
    
    if (lyrics == null) {
      // Fetch details if needed
      final fullResult = await _lyricsService.getLyrics(result.id);
      lyrics = fullResult?.syncedLyrics ?? fullResult?.plainLyrics;
    }

    if (mounted) {
      setState(() {
        _previewLyrics = lyrics;
        _isLoadingPreview = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        // Removed fixed width/height, let it be responsive
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Search Lyrics (LRCLIB)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Fields
            if (isMobile) ...[
              TextField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _albumController,
                decoration: const InputDecoration(
                  labelText: 'Album',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSearching ? null : _search,
                  icon: _isSearching 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _artistController,
                      decoration: const InputDecoration(
                        labelText: 'Artist',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _albumController,
                      decoration: const InputDecoration(
                        labelText: 'Album',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSearching ? null : _search,
                    icon: _isSearching 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            
            // Content Area
            Expanded(
              child: isMobile
                  ? Column(
                      children: [
                        // Results List (Mobile)
                        Expanded(
                          flex: 1,
                          child: _buildResultsList(context),
                        ),
                        const SizedBox(height: 16),
                        // Preview Area (Mobile)
                        Expanded(
                          flex: 1,
                          child: _buildPreviewArea(context),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results List (Desktop/Tablet)
                        Expanded(
                          flex: 2,
                          child: _buildResultsList(context),
                        ),
                        const SizedBox(width: 16),
                        // Preview Area (Desktop/Tablet)
                        Expanded(
                          flex: 3,
                          child: _buildPreviewArea(context),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _previewLyrics != null
                      ? () => Navigator.pop(context, _previewLyrics)
                      : null,
                  child: const Text('Use Lyrics'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results (${_results.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: _results.isEmpty && !_isSearching
                ? const Center(child: Text('No results found'))
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final isSelected = _selectedResult?.id == result.id;
                      
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                        title: Text(result.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          '${result.artistName} • ${result.albumName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (result.syncedLyrics != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: const Text(
                                  'SYNCED',
                                  style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ),
                            Text(_formatDuration(result.duration)),
                          ],
                        ),
                        onTap: () => _selectResult(result),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: _isLoadingPreview
                ? const Center(child: CircularProgressIndicator())
                : _previewLyrics == null
                    ? Center(
                        child: Text(
                          'Select a result to preview lyrics',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          _previewLyrics!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}
