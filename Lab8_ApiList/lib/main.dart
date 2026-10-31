import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ApiListApp());

class Post {
  const Post({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as int,
    title: json['title'] as String? ?? 'Untitled',
    body: json['body'] as String? ?? '',
  );
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  Future<List<Post>> fetchPosts() async {
    final response = await _client
        .get(Uri.https('jsonplaceholder.typicode.com', '/posts'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Server returned ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as List<dynamic>;
    return json
        .take(30)
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class ApiListApp extends StatelessWidget {
  const ApiListApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'API Reader',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3157d5)),
      useMaterial3: true,
    ),
    home: const PostListScreen(),
  );
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});
  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _api = ApiService();
  late Future<List<Post>> _posts = _api.fetchPosts();
  void _retry() => setState(() => _posts = _api.fetchPosts());
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Latest posts'),
      actions: [
        IconButton(
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
          tooltip: 'Retry',
        ),
      ],
    ),
    body: FutureBuilder<List<Post>>(
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Message(
            icon: Icons.cloud_off,
            text: 'Could not load posts. Check your connection and try again.',
            onRetry: _retry,
          );
        }
        final posts = snapshot.data ?? const <Post>[];
        if (posts.isEmpty) {
          return const _Message(
            icon: Icons.inbox_outlined,
            text: 'No posts were returned.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _retry(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${post.id}')),
                  title: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    ),
  );
}
