import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const LocalJsonApp());

class NoteItem {
  const NoteItem({
    required this.id,
    required this.title,
    required this.description,
  });
  final int id;
  final String title, description;
  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
  };
}

class JsonStorage {
  Future<File> get _file async => File(
    '${(await getApplicationDocumentsDirectory()).path}${Platform.pathSeparator}notes.json',
  );
  Future<List<NoteItem>> load() async {
    final file = await _file;
    if (await file.exists()) {
      final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
      return decoded
          .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final seed = jsonDecode(
      await rootBundle.loadString('assets/data/notes.json'),
    ) as List<dynamic>;
    return seed
        .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<NoteItem> items) async => (await _file).writeAsString(
    jsonEncode(items.map((e) => e.toJson()).toList()),
  );
}

class LocalJsonApp extends StatelessWidget {
  const LocalJsonApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Local JSON Notes',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6042a6)),
      useMaterial3: true,
    ),
    home: const NotesScreen(),
  );
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _storage = JsonStorage();
  final _search = TextEditingController();
  List<NoteItem> _items = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _storage.load();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  List<NoteItem> get _visible {
    final query = _search.text.trim().toLowerCase();
    return query.isEmpty
        ? _items
        : _items
              .where(
                (e) =>
                    e.title.toLowerCase().contains(query) ||
                    e.description.toLowerCase().contains(query),
              )
              .toList();
  }

  Future<void> _edit([NoteItem? existing]) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final description = TextEditingController(
      text: existing?.description ?? '',
    );
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New note' : 'Edit note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = title.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(context, (value, description.text.trim()));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    title.dispose();
    description.dispose();
    if (result == null) return;
    final items = [..._items];
    if (existing == null) {
      final next =
          items.fold<int>(0, (n, item) => item.id > n ? item.id : n) + 1;
      items.add(NoteItem(id: next, title: result.$1, description: result.$2));
    } else {
      final i = items.indexWhere((e) => e.id == existing.id);
      items[i] = NoteItem(
        id: existing.id,
        title: result.$1,
        description: result.$2,
      );
    }
    await _persist(items);
  }

  Future<void> _delete(NoteItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('Remove “${item.title}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _persist(_items.where((e) => e.id != item.id).toList());
    }
  }

  Future<void> _persist(List<NoteItem> items) async {
    setState(() => _items = items);
    try {
      await _storage.save(items);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved on this device')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My local notes')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Add note'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text('Could not load data: $_error'))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search notes',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: _visible.isEmpty
                    ? const Center(child: Text('No notes match your search.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: _visible.length,
                        itemBuilder: (context, index) {
                          final item = _visible[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Text(item.description),
                              onTap: () => _edit(item),
                              trailing: IconButton(
                                tooltip: 'Delete',
                                onPressed: () => _delete(item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}
