import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/resource.dart';
import '../../data/models/chapter.dart';
import 'resource_form_screen.dart';
import 'video_player_screen.dart';
// import 'youtube_video_player_screen.dart'; // Removed for Windows compatibility
import 'pdf_viewer_screen.dart';

/// Screen to manage resources of a chapter (F2.3.5)
class ResourceListScreen extends StatefulWidget {
  final int courseId;
  final Chapter? chapter; // null = course-level resources

  const ResourceListScreen({
    super.key,
    required this.courseId,
    this.chapter,
  });

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    if (widget.chapter != null) {
      await courseProvider.loadResourcesByChapter(widget.chapter!.id!);
    } else {
      await courseProvider.loadResourcesByCourse(widget.courseId);
    }
  }

  Future<void> _deleteResource(Resource resource) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la ressource'),
        content: Text('Voulez-vous vraiment supprimer "${resource.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      final success = await courseProvider.deleteResource(resource.id!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ressource supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          _loadResources();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(courseProvider.errorMessage ?? 'Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _openResource(Resource resource) {
    // Get current user ID from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    switch (resource.type) {
      case ResourceType.video:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              resource: resource,
              courseId: widget.courseId,
              userId: userId!,
            ),
          ),
        );
        break;

      case ResourceType.pdf:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              resource: resource,
              courseId: widget.courseId,
              userId: userId,
            ),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewer pour ${resource.type.name} non implémenté'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.email == 'admin@edupalestine.com';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter != null
              ? 'Ressources - ${widget.chapter!.title}'
              : 'Ressources du cours',
        ),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadResources,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final resources = provider.currentResources
              .where((r) {
                if (widget.chapter != null) {
                  return r.chapterId == widget.chapter!.id;
                } else {
                  return r.chapterId == null && r.courseId == widget.courseId;
                }
              })
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

          if (resources.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune ressource',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Cliquez sur + pour ajouter',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            );
          }

            return RefreshIndicator(
            onRefresh: _loadResources,
            child: ReorderableListView.builder(
              itemCount: resources.length,
              onReorder: (oldIndex, newIndex) {
                if (!isAdmin) return;
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                // TODO: Implement reordering
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Réorganisation pas encore implémentée'),
                  ),
                );
              },
              itemBuilder: (context, index) {
                final resource = resources[index];
                return _ResourceTile(
                  key: ValueKey(resource.id),
                  resource: resource,
                  isAdmin: isAdmin,
                  onTap: () => _openResource(resource),
                  onEdit: isAdmin
                      ? () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResourceFormScreen(
                                courseId: widget.courseId,
                                chapterId: widget.chapter?.id,
                                resource: resource,
                              ),
                            ),
                          );
                          _loadResources();
                        }
                      : null,
                  onDelete: isAdmin ? () => _deleteResource(resource) : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResourceFormScreen(
                      courseId: widget.courseId,
                      chapterId: widget.chapter?.id,
                    ),
                  ),
                );
                _loadResources();
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final Resource resource;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ResourceTile({
    super.key,
    required this.resource,
    required this.isAdmin,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  IconData _getIcon() {
    switch (resource.type) {
      case ResourceType.video:
        return Icons.play_circle_outline;
      case ResourceType.pdf:
        return Icons.picture_as_pdf;
      case ResourceType.text:
        return Icons.description;
      case ResourceType.quiz:
        return Icons.quiz;
      case ResourceType.external:
        return Icons.link;
    }
  }

  Color _getColor() {
    switch (resource.type) {
      case ResourceType.video:
        return Colors.red;
      case ResourceType.pdf:
        return Colors.blue;
      case ResourceType.text:
        return Colors.green;
      case ResourceType.quiz:
        return Colors.purple;
      case ResourceType.external:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColor().withOpacity(0.1),
          child: Icon(_getIcon(), color: _getColor()),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                resource.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (resource.isMandatory)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Obligatoire',
                  style: TextStyle(fontSize: 10, color: Colors.orange),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.description != null) ...[
              const SizedBox(height: 4),
              Text(
                resource.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  resource.type.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (resource.durationSeconds != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    resource.formattedDuration,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: isAdmin
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
