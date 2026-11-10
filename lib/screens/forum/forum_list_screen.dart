import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/forum_post.dart';
import 'forum_post_detail_screen.dart';
import 'forum_create_post_screen.dart';

/// Forum list screen - Module 4
class ForumListScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const ForumListScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedTags = [];
  bool _showOnlySolved = false;
  bool _showOnlyUnsolved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      forumProvider.loadPostsByCourse(widget.courseId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    forumProvider.searchPosts(widget.courseId, query);
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (filter == 'solved') {
        _showOnlySolved = !_showOnlySolved;
        if (_showOnlySolved) _showOnlyUnsolved = false;
      } else if (filter == 'unsolved') {
        _showOnlyUnsolved = !_showOnlyUnsolved;
        if (_showOnlyUnsolved) _showOnlySolved = false;
      }
    });
  }

  List<ForumPost> _getFilteredPosts(List<ForumPost> posts) {
    var filtered = posts;

    if (_showOnlySolved) {
      filtered = filtered.where((p) => p.isSolved).toList();
    } else if (_showOnlyUnsolved) {
      filtered = filtered.where((p) => !p.isSolved).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final forumProvider = Provider.of<ForumProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Forum ${widget.courseTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              forumProvider.loadPostsByCourse(widget.courseId, refresh: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher dans les discussions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          forumProvider.loadPostsByCourse(
                            widget.courseId,
                            refresh: true,
                          );
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                  if (value.isEmpty) {
                    forumProvider.loadPostsByCourse(
                      widget.courseId,
                      refresh: true,
                    );
                  }
                },
                onSubmitted: _performSearch,
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Résolues'),
                    selected: _showOnlySolved,
                    onSelected: (_) => _toggleFilter('solved'),
                    selectedColor: Colors.green.shade100,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Non résolues'),
                    selected: _showOnlyUnsolved,
                    onSelected: (_) => _toggleFilter('unsolved'),
                    selectedColor: Colors.orange.shade100,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Posts List
            Expanded(
              child: forumProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : forumProvider.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(forumProvider.error!),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  forumProvider.loadPostsByCourse(
                                    widget.courseId,
                                    refresh: true,
                                  );
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : _buildPostsList(
                          context,
                          _getFilteredPosts(forumProvider.posts),
                          authProvider,
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForumCreatePostScreen(
                  courseId: widget.courseId,
                ),
              ),
            );

            if (result == true) {
              forumProvider.loadPostsByCourse(widget.courseId, refresh: true);
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle discussion'),
        ),
    );
  }

  Widget _buildPostsList(
    BuildContext context,
    List<ForumPost> posts,
    AuthProvider authProvider,
  ) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucune discussion pour le moment',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Soyez le premier à lancer une discussion !',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<ForumProvider>(context, listen: false)
            .loadPostsByCourse(widget.courseId, refresh: true);
      },
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(context, post, authProvider);
        },
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    ForumPost post,
    AuthProvider authProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: post.isPinned ? 4 : 1,
      color: post.isPinned ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumPostDetailScreen(postId: post.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (post.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.push_pin,
                          size: 20, color: Colors.blue.shade700),
                    ),
                  if (post.isSolved)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.check_circle,
                          size: 20, color: Colors.green.shade700),
                    ),
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content Preview
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              // Tags
              if (post.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: post.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(Icons.thumb_up_outlined,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${post.likesCount}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(width: 16),
                  Icon(Icons.comment_outlined,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${post.commentsCount}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const Spacer(),
                  Text(
                    post.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
