import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/chapter.dart';
import '../../data/models/resource.dart';
import 'course_form_screen.dart';
import 'chapter_form_screen.dart';
import 'resource_list_screen.dart';
import 'video_player_screen.dart';
// import 'youtube_video_player_screen.dart'; // Removed for Windows compatibility
import 'pdf_viewer_screen.dart';
import '../quiz/quiz_view_screen.dart';
import '../quiz/quiz_form_screen.dart';
import '../quiz/quiz_list_screen.dart';

/// Screen displaying course details with chapters and resources (F2.1.4)
class CourseDetailScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isEnrolled = false;
  bool _isCheckingEnrollment = true;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Load course with chapters and resources
    await courseProvider.loadCourse(widget.courseId);
    
    // Check if user is enrolled
    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id; // Use UUID directly
      _isEnrolled = await courseProvider.isEnrolledWithUUID(userId, widget.courseId);
    }
    
    setState(() {
      _isCheckingEnrollment = false;
    });
  }

  Future<void> _enrollInCourse() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      print('❌ Enrollment failed: User not logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour vous inscrire')),
      );
      return;
    }

    final userId = authProvider.currentUser!.id; // Use UUID directly
    print('👤 User: $userId (${authProvider.currentUser!.email})');
    print('📚 Enrolling user $userId in course ${widget.courseId}');
    
    final success = await courseProvider.enrollInCourseWithUUID(userId, widget.courseId);
    print('✅ Enrollment result: $success');
    
    if (success) {
      setState(() {
        _isEnrolled = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      print('❌ Enrollment error: ${courseProvider.errorMessage}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(courseProvider.errorMessage ?? 'Erreur lors de l\'inscription'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.email == 'admin@edupalestine.com'; // Simple admin check
    
    return Scaffold(
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final course = provider.selectedCourse;
          if (course == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  const Text('Cours introuvable'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Course Image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                actions: [
                  // Forum button - accessible to all users
                  IconButton(
                    icon: const Icon(Icons.forum),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/forum/course/${widget.courseId}?title=${Uri.encodeComponent(course.title)}',
                      );
                    },
                    tooltip: 'Forum du cours',
                  ),
                  if (isAdmin) ...[
                    // Quiz management button
                    IconButton(
                      icon: const Icon(Icons.quiz),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizListScreen(
                              courseId: widget.courseId,
                            ),
                          ),
                        );
                      },
                      tooltip: 'Gérer les quiz du cours',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        // Navigate to Edit Course Screen (F2.3.3)
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseFormScreen(course: course),
                          ),
                        );
                        
                        if (result == true && mounted) {
                          // Reload course if it was modified
                          provider.loadCourse(widget.courseId);
                        }
                      },
                      tooltip: 'Modifier le cours',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Delete course (F2.3.3)
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text('Voulez-vous vraiment supprimer le cours "${course.title}" ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true && context.mounted) {
                          final success = await provider.deleteCourse(course.id!);
                          
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Cours supprimé avec succès'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context); // Return to courses list
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.errorMessage ?? 'Erreur lors de la suppression'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'Supprimer le cours',
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    course.title,
                    style: const TextStyle(
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 100,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
              
              // Course Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Info Cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.signal_cellular_alt,
                              label: 'Niveau',
                              value: course.level,
                              color: _getLevelColor(course.level),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.book,
                              label: 'Matière',
                              value: course.subject,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.language,
                              label: 'Langue',
                              value: course.language,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.people,
                              label: 'Étudiants',
                              value: '${course.enrolledStudents}',
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Instructor
                      if (course.instructorName != null) ...[
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Instructeur',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  course.instructorName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Description
                      Text(
                        'À propos de ce cours',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Course Stats
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                icon: Icons.list_alt,
                                value: '${course.totalChapters}',
                                label: 'Chapitres',
                              ),
                              _StatItem(
                                icon: Icons.play_circle_outline,
                                value: '${course.totalResources}',
                                label: 'Ressources',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Enrollment Button
                      if (!_isCheckingEnrollment && !_isEnrolled)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: provider.isLoading ? null : _enrollInCourse,
                            icon: const Icon(Icons.add_circle),
                            label: const Text(
                              'S\'inscrire à ce cours',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      
                      if (_isEnrolled)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 12),
                              Text(
                                'Vous êtes inscrit à ce cours',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Chapters List
                      if (provider.currentChapters.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Contenu du cours',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${provider.currentChapters.length} chapitres',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...provider.currentChapters.map((chapter) => _ChapterTile(
                          chapter: chapter,
                          isEnrolled: _isEnrolled,
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Navigate to create chapter screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterFormScreen(
                      courseId: widget.courseId,
                    ),
                  ),
                );

                if (result == true && mounted) {
                  // Reload course to get new chapter
                  final provider = Provider.of<CourseProvider>(context, listen: false);
                  provider.loadCourse(widget.courseId);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouveau chapitre'),
              tooltip: 'Créer un nouveau chapitre',
            )
          : null,
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Débutant':
        return Colors.green;
      case 'Intermédiaire':
        return Colors.orange;
      case 'Avancé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Info Card Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Chapter Tile Widget
class _ChapterTile extends StatefulWidget {
  final Chapter chapter;
  final bool isEnrolled;

  const _ChapterTile({
    required this.chapter,
    required this.isEnrolled,
  });

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile> {
  bool _resourcesLoaded = false;

  Future<void> _loadResources() async {
    if (_resourcesLoaded) return;
    
    final provider = Provider.of<CourseProvider>(context, listen: false);
    await provider.loadResourcesByChapter(widget.chapter.id!);
    
    if (mounted) {
      setState(() {
        _resourcesLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.email == 'admin@edupalestine.com';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          if (expanded && widget.isEnrolled) {
            _loadResources();
          }
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Text(
            '${widget.chapter.orderIndex}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          widget.chapter.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: widget.chapter.description != null
            ? Text(
                widget.chapter.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.chapter.durationMinutes != null)
              Chip(
                label: Text('${widget.chapter.durationMinutes} min'),
                backgroundColor: Colors.blue.shade50,
                labelStyle: const TextStyle(fontSize: 11),
              ),
            if (isAdmin) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'edit') {
                    // Edit chapter
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterFormScreen(
                          courseId: widget.chapter.courseId,
                          chapter: widget.chapter,
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      final provider = Provider.of<CourseProvider>(context, listen: false);
                      provider.loadCourse(widget.chapter.courseId);
                    }
                  } else if (value == 'delete') {
                    // Delete chapter
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmer la suppression'),
                        content: Text('Voulez-vous vraiment supprimer le chapitre "${widget.chapter.title}" ?\n\nToutes les ressources associées seront également supprimées.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final provider = Provider.of<CourseProvider>(context, listen: false);
                      final success = await provider.deleteChapter(widget.chapter.id!);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Chapitre supprimé avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.errorMessage ?? 'Erreur lors de la suppression'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else if (value == 'resources') {
                    // Manage resources
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResourceListScreen(
                          courseId: widget.chapter.courseId,
                          chapter: widget.chapter,
                        ),
                      ),
                    );
                  } else if (value == 'quiz') {
                    // Create a quiz for this chapter
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizFormScreen(
                          courseId: widget.chapter.courseId,
                          chapterId: widget.chapter.id,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'resources',
                    child: Row(
                      children: [
                        Icon(Icons.folder_open, size: 20),
                        SizedBox(width: 12),
                        Text('Gérer les ressources'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'quiz',
                    child: Row(
                      children: [
                        Icon(Icons.quiz, size: 20, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Créer un quiz', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
        children: [
          if (!widget.isEnrolled)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Inscrivez-vous pour accéder au contenu',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _resourcesLoaded
                ? Consumer<CourseProvider>(
                    builder: (context, provider, _) {
                      final resources = provider.currentResources
                          .where((r) => r.chapterId == widget.chapter.id)
                          .toList();
                      
                      if (resources.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Aucune ressource disponible'),
                        );
                      }
                      
                      return Column(
                        children: resources.map((resource) => ListTile(
                          leading: Icon(_getResourceIcon(resource.type)),
                          title: Text(resource.title),
                          subtitle: resource.description != null
                              ? Text(resource.description!)
                              : null,
                          trailing: resource.durationSeconds != null
                              ? Text(resource.formattedDuration)
                              : null,
                          onTap: () {
                            _openResource(context, resource);
                          },
                        )).toList(),
                      );
                    },
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
            ),
        ],
      ),
    );
  }

  void _openResource(BuildContext context, Resource resource) {
    // Get user ID from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour accéder aux ressources'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to appropriate viewer based on resource type
    switch (resource.type) {
      case ResourceType.video:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              resource: resource,
              courseId: resource.courseId,
              userId: userId,
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
              courseId: resource.courseId,
              userId: userId,
            ),
          ),
        );
        break;
        
      case ResourceType.external:
        // TODO: Open external link in browser
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ouverture du lien: ${resource.url}')),
        );
        break;
        
      case ResourceType.quiz:
        // Open quiz viewer
        if (resource.quizId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizViewScreen(
                resource: resource,
                courseId: resource.courseId,
                userId: userId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Quiz non trouvé'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
        
      case ResourceType.text:
        // TODO: Implement text reader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📄 Lecteur de texte sera implémenté prochainement'),
          ),
        );
        break;
    }
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
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
}
