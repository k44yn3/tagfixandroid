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

        if (state.files.isEmpty) {
          return const Center(child: Text('No files found'));
        }

        return ListView.builder(
          itemCount: state.files.length,
          itemBuilder: (context, index) {
            final file = state.files[index];
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
