import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../core/file_kind.dart';
import '../../core/utils/byte_format.dart';
import '../../core/utils/encoding_detect.dart';
import '../../data/models/file_entry.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/empty_state.dart';

class SearchResultMatch {
  final FileEntry entry;
  final int? lineNumber;
  final String? snippet;

  const SearchResultMatch({
    required this.entry,
    this.lineNumber,
    this.snippet,
  });
}

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _queryController = TextEditingController();
  FileKind? _selectedKindFilter;
  bool _searchInsideFiles = false;
  bool _isSearching = false;
  List<SearchResultMatch> _results = [];
  String? _searchFolder;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickSearchFolder() async {
    final gateway = ref.read(fileGatewayProvider);
    final dir = await gateway.pickDirectory();
    if (dir != null) {
      setState(() {
        _searchFolder = dir.uri;
      });
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final matches = <SearchResultMatch>[];

      // 1. First search in Recent files
      final repo = ref.read(fileRepositoryProvider);
      final recents = await repo.getRecents();

      for (final f in recents) {
        if (_selectedKindFilter != null && f.kind != _selectedKindFilter) {
          continue;
        }

        if (f.name.toLowerCase().contains(query)) {
          matches.add(SearchResultMatch(entry: f));
        }
      }

      // 2. If a folder is picked, search files inside that directory
      if (_searchFolder != null) {
        final dir = Directory(_searchFolder!);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final name = p.basename(entity.path);
              final kind = FileKindDetector.detect(name);

              if (_selectedKindFilter != null && kind != _selectedKindFilter) {
                continue;
              }

              // Name match
              final nameMatch = name.toLowerCase().contains(query);

              // Inside file text match
              if (_searchInsideFiles && FileKindDetector.isEditableText(kind)) {
                try {
                  final stat = await entity.stat();
                  if (stat.size < 2 * 1024 * 1024) { // Up to 2MB text search
                    final bytes = await entity.readAsBytes();
                    final text = EncodingDetector.decodeText(bytes);
                    final lines = text.split('\n');

                    for (int i = 0; i < lines.length; i++) {
                      if (lines[i].toLowerCase().contains(query)) {
                        final entry = FileEntry(
                          id: entity.path,
                          uri: entity.path,
                          name: name,
                          size: stat.size,
                          modified: stat.modified,
                          kind: kind,
                        );
                        matches.add(SearchResultMatch(
                          entry: entry,
                          lineNumber: i + 1,
                          snippet: lines[i].trim(),
                        ));
                        break; // 1 match per file
                      }
                    }
                  }
                } catch (_) {}
              } else if (nameMatch) {
                final stat = await entity.stat();
                matches.add(SearchResultMatch(
                  entry: FileEntry(
                    id: entity.path,
                    uri: entity.path,
                    name: name,
                    size: stat.size,
                    modified: stat.modified,
                    kind: kind,
                  ),
                ));
              }
            }
          }
        }
      }

      setState(() {
        _results = matches;
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'फ़ाइल नाम या सामग्री खोजें...',
            border: InputBorder.none,
            suffixIcon: _queryController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _queryController.clear();
                      _performSearch();
                    },
                  )
                : null,
          ),
          onChanged: (_) => _performSearch(),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Folder pick chip
                ActionChip(
                  avatar: const Icon(Icons.folder_open, size: 16),
                  label: Text(_searchFolder != null ? p.basename(_searchFolder!) : 'फ़ोल्डर चुनें'),
                  onPressed: _pickSearchFolder,
                ),
                const SizedBox(width: 8),

                // In-file search toggle
                FilterChip(
                  label: const Text('फ़ाइल के अंदर खोजें'),
                  selected: _searchInsideFiles,
                  onSelected: (val) {
                    setState(() => _searchInsideFiles = val);
                    _performSearch();
                  },
                ),
                const SizedBox(width: 8),

                // Type filter
                ...[FileKind.text, FileKind.image, FileKind.csv, FileKind.pdf, FileKind.json].map((k) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      label: Text(FileKindDetector.getDisplayName(k)),
                      selected: _selectedKindFilter == k,
                      onSelected: (selected) {
                        setState(() {
                          _selectedKindFilter = selected ? k : null;
                        });
                        _performSearch();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _queryController.text.isEmpty
                    ? const EmptyState(
                        icon: Icons.search,
                        title: 'खोज शुरू करने के लिए टाइप करें',
                        subtitle: 'फाइल नाम से खोजें, या फोल्डर चुनकर फाइलों के अंदर का टेक्स्ट खोजें।',
                      )
                    : _results.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: 'कोई परिणाम नहीं मिला',
                            subtitle: 'कृपया अलग शब्द या फ़िल्टर आज़माएँ।',
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  child: Icon(Icons.insert_drive_file, color: theme.colorScheme.primary),
                                ),
                                title: Text(item.entry.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${ByteFormat.format(item.entry.size)} · ${item.entry.kind.name.toUpperCase()}'),
                                    if (item.snippet != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'पंक्ति ${item.lineNumber}: "${item.snippet}"',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.primary,
                                          fontFamily: 'monospace',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 20),
                                onTap: () {
                                  context.push('/workspace', extra: item.entry);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

