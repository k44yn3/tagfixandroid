import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_state.dart';
import '../widgets/file_list.dart';
import '../widgets/editor_panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Request storage permissions
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    
    // For Android 13+ (API 33+), request media permissions
    if (await Permission.audio.isDenied) {
      await Permission.audio.request();
    }

    // Request Manage External Storage (Android 11+) for full access if needed
    if (await Permission.manageExternalStorage.isDenied) {
      // We don't force it immediately, but we might need it for writing
      // await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _openFolder() async {
    // Check permissions before opening folder
    bool hasPermission = await Permission.storage.isGranted || 
                         await Permission.audio.isGranted ||
                         await Permission.manageExternalStorage.isGranted;
    
    if (!hasPermission) {
      // Try requesting manageExternalStorage if others failed
      if (await Permission.manageExternalStorage.request().isGranted) {
        hasPermission = true;
      }
    }

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to access audio files'),
            action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
          ),
        );
      }
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null && mounted) {
      context.read<AppState>().scanDirectory(selectedDirectory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final selectedFile = context.watch<AppState>().selectedFile;

    return PopScope(
      canPop: selectedFile == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedFile != null) {
          context.read<AppState>().selectFile(null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TagFix'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                final currentDir = context.read<AppState>().currentDirectory;
                if (currentDir != null) {
                  context.read<AppState>().scanDirectory(currentDir);
                }
              },
            ),
          ],
        ),
        body: isLandscape
            ? Row(
                children: [
                  // File List (Left) - Landscape
                  Expanded(
                    flex: 1,
                    child: const FileList(),
                  ),
                  const VerticalDivider(width: 1),
                  // Editor Panel (Right) - Landscape
                  Expanded(
                    flex: 2,
                    child: selectedFile == null
                        ? const Center(child: Text('Select a file to edit metadata'))
                        : EditorPanel(file: selectedFile),
                  ),
                ],
              )
            : selectedFile == null
                ? const FileList() // Portrait - show file list
                : EditorPanel(file: selectedFile), // Portrait - show editor
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openFolder,
          icon: const Icon(Icons.folder_open),
          label: const Text('Open Folder'),
        ),
        bottomNavigationBar: selectedFile != null && !isLandscape
            ? BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedFile.filename,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AppState>().selectFile(null);
                        },
                        child: const Text('Back to List'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
