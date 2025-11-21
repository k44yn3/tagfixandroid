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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      if (mounted) {
        // Show explanation dialog before requesting
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'To edit tags on files across your device, TagFix needs "All Files Access".\n\n'
              'Please grant this permission in the next screen.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Permission.manageExternalStorage.request();
                },
                child: const Text('Grant Access'),
              ),
            ],
          ),
        );
      }
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

  void _showCredits() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('Credits'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Developed by @k44yn3 on GitHub'),
            SizedBox(height: 16),
            Text('Powered by:'),
            Text('• MusicBrainz (Metadata)'),
            Text('• LRCLIB (Lyrics)'),
            Text('• Flutter & Dart'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<AppState>().setSearchQuery('');
      }
    });
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
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search artist, album, title...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    context.read<AppState>().setSearchQuery(value);
                  },
                )
              : InkWell(
                  onTap: _showCredits,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('TagFix'),
                  ),
                ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              tooltip: _isSearching ? 'Close Search' : 'Search',
              onPressed: _toggleSearch,
            ),
            if (!_isSearching)
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
