import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quiz.dart';
import '../../providers/quiz_provider.dart';

/// Screen to select a quiz to attach to a resource
class QuizSelectionScreen extends StatefulWidget {
  final int courseId;
  final int? chapterId;

  const QuizSelectionScreen({
    super.key,
    required this.courseId,
    this.chapterId,
  });

  @override
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  Future<void> _loadQuizzes() async {
    final provider = context.read<QuizProvider>();
    print('🔍 QuizSelectionScreen: Loading quizzes for courseId=${widget.courseId}, chapterId=${widget.chapterId}');
    await provider.loadQuizzesByCourse(widget.courseId);
    print('✅ QuizSelectionScreen: Loaded ${provider.quizzes.length} quizzes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadQuizzes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final quizzes = provider.quizzes;

          // Filter quizzes by chapter if specified
          // Include quizzes with chapterId = null (course-level quizzes) and chapter-specific quizzes
          final filteredQuizzes = widget.chapterId != null
              ? quizzes.where((q) => q.chapterId == null || q.chapterId == widget.chapterId).toList()
              : quizzes;

          if (filteredQuizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    widget.chapterId != null
                        ? 'Aucun quiz disponible pour ce chapitre'
                        : 'Aucun quiz disponible pour ce cours',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Créez d\'abord un quiz avant de l\'affecter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = filteredQuizzes[index];
              return _buildQuizCard(context, quiz);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pop(context, quiz),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (quiz.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            quiz.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (quiz.durationMinutes != null)
                    _buildChip(
                      context,
                      Icons.timer_outlined,
                      '${quiz.durationMinutes} min',
                      Colors.blue,
                    ),
                  if (quiz.maxAttempts > 0)
                    _buildChip(
                      context,
                      Icons.repeat,
                      '${quiz.maxAttempts} tentatives',
                      Colors.orange,
                    ),
                  _buildChip(
                    context,
                    Icons.check_circle_outline,
                    '${quiz.passingScore.toInt()}% requis',
                    Colors.green,
                  ),
                  if (quiz.chapterId != null)
                    _buildChip(
                      context,
                      Icons.bookmark_outline,
                      'Chapitre',
                      Colors.purple,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
