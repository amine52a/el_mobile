import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/forum_post.dart';

/// Screen to create a new forum post - Module 4
class ForumCreatePostScreen extends StatefulWidget {
  final int courseId;
  final int? chapterId;

  const ForumCreatePostScreen({
    super.key,
    required this.courseId,
    this.chapterId,
  });

  @override
  State<ForumCreatePostScreen> createState() => _ForumCreatePostScreenState();
}

class _ForumCreatePostScreenState extends State<ForumCreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);

    final post = ForumPost(
      authorId: authProvider.currentUser!.id,
      authorName: authProvider.currentUser!.fullName,
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tags: _tags,
      createdAt: DateTime.now(),
    );

    final postId = await forumProvider.createPost(post);

    setState(() {
      _isSubmitting = false;
    });

    if (postId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discussion créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(forumProvider.error ?? 'Une erreur s\'est produite'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle discussion'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Écrivez le titre de la discussion...',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir un titre';
                    }
                    if (value.trim().length < 5) {
                      return 'Le titre doit contenir au moins 5 caractères';
                    }
                    return null;
                  },
                  maxLength: 200,
                ),
                const SizedBox(height: 16),

                // Content
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    hintText: 'Écrivez les détails de la discussion...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir le contenu';
                    }
                    if (value.trim().length < 10) {
                      return 'Le contenu doit contenir au moins 10 caractères';
                    }
                    return null;
                  },
                  maxLines: 10,
                  maxLength: 5000,
                ),
                const SizedBox(height: 16),

                // Tags Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Ajouter un tag...',
                          prefixIcon: Icon(Icons.local_offer),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addTag,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tags Display
                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Publier la discussion',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Help Text
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Conseils pour une bonne discussion :',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Rédigez un titre clair qui reflète le sujet\n'
                          '• Fournissez suffisamment de détails dans le contenu\n'
                          '• Utilisez des tags pour faciliter la recherche\n'
                          '• Soyez respectueux et courtois',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
