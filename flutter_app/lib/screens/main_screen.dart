import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_state.dart';
import '../widgets/file_list.dart';
import '../widgets/editor_panel.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('TagFix'),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '@k44yn3 on Github',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Text(
              'Powered by MusicBrainz & LRCLIB',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            icon: const Icon(Icons.folder_open),
            label: const Text('Open Folder'),
            onPressed: () async {
              String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
              if (selectedDirectory != null) {
                context.read<AppState>().scanDirectory(selectedDirectory);
              }
            },
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            onPressed: () {
              final currentDir = context.read<AppState>().currentDirectory;
              if (currentDir != null) {
                context.read<AppState>().scanDirectory(currentDir);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // File List (Left)
          const Expanded(
            flex: 1,
            child: FileList(),
          ),
          const VerticalDivider(width: 1),
          // Editor Panel (Right)
          Expanded(
            flex: 2,
            child: Consumer<AppState>(
              builder: (context, state, child) {
                if (state.selectedFile == null) {
                  return const Center(
                    child: Text('Select a file to edit metadata'),
                  );
                }
                return EditorPanel(file: state.selectedFile!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
