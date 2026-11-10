import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/question.dart';
import 'question_form_screen.dart';

/// Screen to manage questions for a quiz (F3.1.4-3.1.6)
class QuizQuestionsScreen extends StatefulWidget {
  final int quizId;

  const QuizQuestionsScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load quiz and its questions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).loadQuiz(widget.quizId);
    });
  }

  void _addQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionFormScreen(quizId: widget.quizId),
      ),
    );

    if (result == true) {
      // Reload questions
      if (mounted) {
        Provider.of<QuizProvider>(context, listen: false).loadQuiz(widget.quizId);
      }
    }
  }

  void _editQuestion(Question question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionFormScreen(
          quizId: widget.quizId,
          question: question,
        ),
      ),
    );

    if (result == true) {
      // Reload questions
      if (mounted) {
        Provider.of<QuizProvider>(context, listen: false).loadQuiz(widget.quizId);
      }
    }
  }

  void _deleteQuestion(Question question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cette question ?\n\n"${question.questionText}"'),
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
      final success = await quizProvider.deleteQuestion(question.id!);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question supprimée'),
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

  String _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return '☑️';
      case QuestionType.trueFalse:
        return '✓/✗';
      case QuestionType.shortAnswer:
        return '✍️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Questions'),
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
                    onPressed: () {
                      quizProvider.loadQuiz(widget.quizId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final quiz = quizProvider.currentQuiz;
          final questions = quizProvider.currentQuizQuestions;

          if (quiz == null) {
            return const Center(child: Text('Quiz introuvable'));
          }

          return Column(
            children: [
              // Quiz Info Card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (quiz.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          quiz.description!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.quiz, size: 16),
                          const SizedBox(width: 4),
                          Text('${questions.length} question(s)'),
                          const SizedBox(width: 16),
                          const Icon(Icons.grade, size: 16),
                          const SizedBox(width: 4),
                          Text('${quiz.passingScore}% requis'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Questions List
              Expanded(
                child: questions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune question',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appuyez sur + pour ajouter la première question',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: questions.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          final reordered = List<Question>.from(questions);
                          final item = reordered.removeAt(oldIndex);
                          reordered.insert(newIndex, item);
                          
                          // Update order_num for each question
                          final updatedQuestions = reordered.asMap().entries.map((entry) {
                            final index = entry.key;
                            final question = entry.value;
                            return Question(
                              id: question.id,
                              quizId: question.quizId,
                              type: question.type,
                              questionText: question.questionText,
                              explanation: question.explanation,
                              points: question.points,
                              orderIndex: index + 1,
                              options: question.options,
                              correctAnswerIndices: question.correctAnswerIndices,
                              correctAnswerBool: question.correctAnswerBool,
                              correctAnswerText: question.correctAnswerText,
                            );
                          }).toList();
                          
                          quizProvider.reorderQuestions(updatedQuestions);
                        },
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return Card(
                            key: ValueKey(question.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Row(
                                children: [
                                  Text(_getQuestionTypeIcon(question.type)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      question.questionText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${question.type.displayName} • ${question.points} point(s)',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editQuestion(question),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: Colors.red,
                                    onPressed: () => _deleteQuestion(question),
                                  ),
                                  const Icon(Icons.drag_handle),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une question'),
      ),
    );
  }
}
