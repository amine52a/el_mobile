import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/resource.dart';
import '../../data/models/quiz.dart';
import '../../providers/quiz_provider.dart';
import 'quiz_taking_screen.dart';

/// Screen to view and take a quiz (Module 3 - F3.1.x)
class QuizViewScreen extends StatefulWidget {
  final Resource resource;
  final int courseId;
  final String userId;

  const QuizViewScreen({
    super.key,
    required this.resource,
    required this.courseId,
    required this.userId,
  });

  @override
  State<QuizViewScreen> createState() => _QuizViewScreenState();
}

class _QuizViewScreenState extends State<QuizViewScreen> {
  Quiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    if (widget.resource.quizId == null) {
      setState(() {
        _errorMessage = 'Aucun quiz associé à cette ressource';
        _isLoading = false;
      });
      return;
    }

    final provider = Provider.of<QuizProvider>(context, listen: false);
    await provider.loadQuiz(widget.resource.quizId!);

    setState(() {
      _quiz = provider.currentQuiz;
      _errorMessage = provider.error;
      _isLoading = false;
    });
  }

  void _startQuiz() {
    if (_quiz == null) return;

    // Check if quiz is available
    final now = DateTime.now();
    if (_quiz!.availableFrom != null && now.isBefore(_quiz!.availableFrom!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ce quiz sera disponible le ${_formatDate(_quiz!.availableFrom!)}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_quiz!.availableUntil != null && now.isAfter(_quiz!.availableUntil!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce quiz n\'est plus disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to quiz taking screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTakingScreen(
          quiz: _quiz!,
          courseId: widget.courseId,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.resource.title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _quiz == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.resource.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                _errorMessage ?? 'Quiz introuvable',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz!.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz icon and title
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.quiz,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _quiz!.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Quiz description
            if (_quiz!.description != null) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _quiz!.description!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],

            // Quiz details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails du quiz',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    
                    if (_quiz!.durationMinutes != null)
                      _buildDetailRow(
                        icon: Icons.timer,
                        label: 'Durée',
                        value: '${_quiz!.durationMinutes} minutes',
                      ),
                    
                    _buildDetailRow(
                      icon: Icons.school,
                      label: 'Note de passage',
                      value: '${_quiz!.passingScore.toStringAsFixed(0)}%',
                    ),
                    
                    if (_quiz!.maxAttempts > 0)
                      _buildDetailRow(
                        icon: Icons.repeat,
                        label: 'Tentatives autorisées',
                        value: '${_quiz!.maxAttempts}',
                      )
                    else
                      _buildDetailRow(
                        icon: Icons.all_inclusive,
                        label: 'Tentatives',
                        value: 'Illimitées',
                      ),
                    
                    _buildDetailRow(
                      icon: _quiz!.showResults ? Icons.visibility : Icons.visibility_off,
                      label: 'Résultats',
                      value: _quiz!.showResults
                          ? 'Affichés immédiatement'
                          : 'Non affichés',
                    ),
                    
                    if (_quiz!.shuffleQuestions)
                      _buildDetailRow(
                        icon: Icons.shuffle,
                        label: 'Questions',
                        value: 'Ordre aléatoire',
                      ),
                    
                    if (_quiz!.availableFrom != null)
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Disponible du',
                        value: _formatDate(_quiz!.availableFrom!),
                      ),
                    
                    if (_quiz!.availableUntil != null)
                      _buildDetailRow(
                        icon: Icons.event_busy,
                        label: 'Jusqu\'au',
                        value: _formatDate(_quiz!.availableUntil!),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Start button
            Center(
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Commencer le quiz'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
