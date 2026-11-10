import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/forum_comment.dart';

/// Forum post detail screen with comments - Module 4
class ForumPostDetailScreen extends StatefulWidget {
  final int postId;

  const ForumPostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      forumProvider.loadPost(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    final comment = ForumComment(
      postId: widget.postId,
      authorId: authProvider.currentUser!.id,
      authorName: authProvider.currentUser!.fullName,
      content: content,
      createdAt: DateTime.now(),
    );

    final commentId = await forumProvider.createComment(comment);

    setState(() {
      _isSubmittingComment = false;
    });

    if (commentId != null) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _toggleLike() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    await forumProvider.togglePostLike(
      authProvider.currentUser!.id,
      widget.postId,
    );
  }

  Future<void> _toggleCommentLike(int commentId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    await forumProvider.toggleCommentLike(
      authProvider.currentUser!.id,
      commentId,
    );
  }

  Future<void> _acceptComment(int commentId) async {
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    final result = await forumProvider.acceptComment(commentId, widget.postId);

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول الإجابة'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final forumProvider = Provider.of<ForumProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المناقشة'),
          actions: [
            if (forumProvider.currentPost != null &&
                forumProvider.currentPost!.authorId ==
                    authProvider.currentUser?.id)
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showPostOptions(context);
                },
              ),
          ],
        ),
        body: forumProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : forumProvider.currentPost == null
                ? const Center(child: Text('المناقشة غير موجودة'))
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Post Header
                              _buildPostHeader(
                                  context, forumProvider.currentPost!),
                              const SizedBox(height: 16),

                              // Post Content
                              _buildPostContent(
                                  context, forumProvider.currentPost!),
                              const SizedBox(height: 16),

                              // Post Actions
                              _buildPostActions(context,
                                  forumProvider.currentPost!, authProvider),
                              const Divider(height: 32),

                              // Comments Section
                              Text(
                                'Commentaires (${forumProvider.comments.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Comments List
                              ...forumProvider.comments.map((comment) {
                                return _buildCommentCard(
                                  context,
                                  comment,
                                  authProvider,
                                  forumProvider,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      // Comment Input
                      _buildCommentInput(context),
                    ],
                  ),
    );
  }

  Widget _buildPostHeader(BuildContext context, post) {
    return Row(
      children: [
        CircleAvatar(
          child: Text(post.authorName[0].toUpperCase()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                post.formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        if (post.isPinned)
          Icon(Icons.push_pin, color: Colors.blue.shade700),
        if (post.isSolved)
          Icon(Icons.check_circle, color: Colors.green.shade700),
      ],
    );
  }

  Widget _buildPostContent(BuildContext context, post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          post.content,
          style: const TextStyle(fontSize: 16),
        ),
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: post.tags.map((tag) {
              return Chip(
                label: Text(tag),
                labelStyle: const TextStyle(fontSize: 12),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPostActions(BuildContext context, post, AuthProvider authProvider) {
    return FutureBuilder<bool>(
      future: Provider.of<ForumProvider>(context, listen: false)
          .hasUserLikedPost(authProvider.currentUser!.id, post.id!),
      builder: (context, snapshot) {
        final hasLiked = snapshot.data ?? false;

        return Row(
          children: [
            IconButton.filled(
              onPressed: _toggleLike,
              icon: Icon(hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
              style: IconButton.styleFrom(
                backgroundColor:
                    hasLiked ? Colors.blue.shade100 : Colors.grey.shade200,
              ),
            ),
            const SizedBox(width: 4),
            Text('${post.likesCount}'),
            const SizedBox(width: 24),
            Icon(Icons.comment_outlined, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text('${post.commentsCount}'),
          ],
        );
      },
    );
  }

  Widget _buildCommentCard(
    BuildContext context,
    ForumComment comment,
    AuthProvider authProvider,
    ForumProvider forumProvider,
  ) {
    final isAuthor = comment.authorId == authProvider.currentUser?.id;
    final isPostAuthor =
        forumProvider.currentPost?.authorId == authProvider.currentUser?.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: comment.isAccepted ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(comment.authorName[0].toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        comment.formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.isAccepted)
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                if (isPostAuthor && !comment.isAccepted && !forumProvider.currentPost!.isSolved)
                  TextButton.icon(
                    onPressed: () => _acceptComment(comment.id!),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('قبول'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Comment Content
            Text(comment.content),
            const SizedBox(height: 8),

            // Comment Actions
            FutureBuilder<bool>(
              future: forumProvider.hasUserLikedComment(
                authProvider.currentUser!.id,
                comment.id!,
              ),
              builder: (context, snapshot) {
                final hasLiked = snapshot.data ?? false;

                return Row(
                  children: [
                    IconButton(
                      onPressed: () => _toggleCommentLike(comment.id!),
                      icon: Icon(
                        hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: hasLiked ? Colors.blue : Colors.grey.shade600,
                      ),
                    ),
                    Text('${comment.likesCount}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'اكتب تعليقاً...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _isSubmittingComment ? null : _submitComment,
            icon: _isSubmittingComment
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('تعديل'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
            ],
          ),
        ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('تأكيد الSupprimer'),
          content: const Text('هل أنت متأكد من Supprimer هذه المناقشة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final forumProvider =
                    Provider.of<ForumProvider>(context, listen: false);
                final result = await forumProvider.deletePost(widget.postId);
                if (result && mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
    );
  }
}

