import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class FileList extends StatelessWidget {
  const FileList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final files = state.filteredFiles;

        if (files.isEmpty) {
          return Center(
            child: Text(state.searchQuery.isEmpty ? 'No files found' : 'No matching files'),
          );
        }

        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final isSelected = state.selectedFile == file;

            return ListTile(
              selected: isSelected,
              selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
              selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
              leading: const Icon(Icons.audio_file),
              title: Text(
                file.tags?.title ?? file.filename,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                file.tags?.trackArtist ?? 'Unknown Artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                context.read<AppState>().selectFile(file);
              },
            );
          },
        );
      },
    );
  }
}
