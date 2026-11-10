import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/quiz.dart';
import 'quiz_form_screen.dart';
import 'quiz_questions_screen.dart';

/// Screen to list and manage quizzes for a course or chapter (Admin only)
class QuizListScreen extends StatefulWidget {
  final int courseId;
  final int? chapterId;

  const QuizListScreen({
    super.key,
    required this.courseId,
    this.chapterId,
  });

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  Future<void> _loadQuizzes() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    if (widget.chapterId != null) {
      await quizProvider.loadQuizzesByChapter(widget.chapterId!);
    } else {
      await quizProvider.loadQuizzesByCourse(widget.courseId);
    }
  }

  void _createQuiz() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => QuizFormScreen(
          courseId: widget.courseId,
          chapterId: widget.chapterId,
        ),
      ),
    );

    if (result != null) {
      // Quiz created, navigate to questions screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizQuestionsScreen(quizId: result),
          ),
        );
      }
    }
  }

  void _editQuiz(Quiz quiz) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizFormScreen(
          courseId: widget.courseId,
          chapterId: widget.chapterId,
          quiz: quiz,
        ),
      ),
    );

    if (result != null && mounted) {
      _loadQuizzes();
    }
  }

  void _deleteQuiz(Quiz quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le quiz "${quiz.title}" ?\n\nToutes les questions seront également supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final success = await quizProvider.deleteQuiz(quiz.id!);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz supprimé'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(quizProvider.error ?? 'Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _manageQuestions(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizQuestionsScreen(quizId: quiz.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterId != null 
            ? 'Quiz du chapitre' 
            : 'Quiz du cours'
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(quizProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadQuizzes,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final quizzes = quizProvider.quizzes;

          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun quiz pour le moment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur + pour créer un quiz',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadQuizzes,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.quiz),
                        ),
                        title: Text(
                          quiz.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: quiz.description != null
                            ? Text(
                                quiz.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'questions',
                              child: Row(
                                children: [
                                  Icon(Icons.question_answer),
                                  SizedBox(width: 8),
                                  Text('Gérer les questions'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'questions':
                                _manageQuestions(quiz);
                                break;
                              case 'edit':
                                _editQuiz(quiz);
                                break;
                              case 'delete':
                                _deleteQuiz(quiz);
                                break;
                            }
                          },
                        ),
                        onTap: () => _manageQuestions(quiz),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (quiz.durationMinutes != null)
                              _buildChip(Icons.timer, '${quiz.durationMinutes} min'),
                            _buildChip(Icons.repeat, 
                              quiz.maxAttempts == 0 ? 'Illimité' : '${quiz.maxAttempts} tentative(s)'),
                            _buildChip(Icons.grade, '${quiz.passingScore}% requis'),
                            if (quiz.availableFrom != null || quiz.availableUntil != null)
                              _buildChip(
                                Icons.event,
                                quiz.isAvailable ? 'Disponible' : 'Non disponible',
                                color: quiz.isAvailable ? Colors.green : Colors.orange,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createQuiz,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau quiz'),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, {Color? color}) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      visualDensity: VisualDensity.compact,
    );
  }
}
