import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quiz.dart';
import '../../data/models/question.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';

/// Screen for taking a quiz
class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  final int courseId;

  const QuizTakingScreen({
    super.key,
    required this.quiz,
    required this.courseId,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, dynamic> _answers = {}; // questionIndex -> answer
  List<Question> _questions = [];
  bool _isLoading = true;
  bool _quizSubmitted = false;
  Timer? _timer;
  int _remainingSeconds = 0;
  
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final provider = Provider.of<QuizProvider>(context, listen: false);
    await provider.loadQuestionsByQuiz(widget.quiz.id!);
    
    setState(() {
      _questions = List.from(provider.questions);
      
      // Shuffle questions if required
      if (widget.quiz.shuffleQuestions) {
        _questions.shuffle();
      }
      
      // Initialize timer if duration is set
      if (widget.quiz.durationMinutes != null) {
        _remainingSeconds = widget.quiz.durationMinutes! * 60;
        _startTimer();
      }
      
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Time's up - auto submit
        _submitQuiz();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _answerQuestion(dynamic answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });
  }

  Future<void> _submitQuiz() async {
    // Stop timer
    _timer?.cancel();

    // Confirm submission
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Soumettre le quiz'),
        content: Text(
          _answers.length == _questions.length
              ? 'Voulez-vous soumettre vos réponses ?'
              : 'Vous avez répondu à ${_answers.length}/${_questions.length} questions.\n\nVoulez-vous soumettre quand même ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      // Restart timer if cancelled
      if (widget.quiz.durationMinutes != null && _remainingSeconds > 0) {
        _startTimer();
      }
      return;
    }

    // Calculate score
    int totalPoints = 0;
    int earnedPoints = 0;

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      totalPoints += question.points;

      final answer = _answers[i];
      if (answer != null && _isAnswerCorrect(question, answer)) {
        earnedPoints += question.points;
      }
    }

    final scorePercentage = totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0.0;

    // Save attempt to database
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      final provider = Provider.of<QuizProvider>(context, listen: false);
      await provider.createQuizAttempt(
        quizId: widget.quiz.id!,
        userId: userId,
        score: scorePercentage,
        answers: _answers.map((key, value) => MapEntry(
          _questions[key].id.toString(),
          value.toString(),
        )),
      );
    }

    setState(() {
      _quizSubmitted = true;
    });

    // Show results if enabled
    if (widget.quiz.showResults) {
      _showResults(scorePercentage, earnedPoints, totalPoints);
    } else {
      // Just show a confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Quiz soumis avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  bool _isAnswerCorrect(Question question, dynamic answer) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        if (answer is List<int>) {
          // Multiple correct answers
          final correctSet = question.correctAnswerIndices.toSet();
          final answerSet = answer.toSet();
          return correctSet.length == answerSet.length &&
              correctSet.containsAll(answerSet);
        } else if (answer is int) {
          // Single correct answer
          return question.correctAnswerIndices.contains(answer);
        }
        return false;

      case QuestionType.trueFalse:
        return answer == question.correctAnswerBool;

      case QuestionType.shortAnswer:
        if (answer is String && question.correctAnswerText != null) {
          return answer.trim().toLowerCase() ==
              question.correctAnswerText!.trim().toLowerCase();
        }
        return false;
    }
  }

  void _showResults(double scorePercentage, int earnedPoints, int totalPoints) {
    final passed = scorePercentage >= widget.quiz.passingScore;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              passed ? Icons.check_circle : Icons.cancel,
              color: passed ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(passed ? 'Réussi !' : 'Échoué'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score: ${scorePercentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Points obtenus: $earnedPoints / $totalPoints'),
            const SizedBox(height: 8),
            Text('Note de passage: ${widget.quiz.passingScore}%'),
            const Divider(height: 24),
            if (passed)
              const Text(
                '🎉 Félicitations ! Vous avez réussi le quiz.',
                style: TextStyle(color: Colors.green),
              )
            else
              Text(
                'Continuez à étudier et réessayez.\n${widget.quiz.maxAttempts > 0 ? "Tentatives restantes: ${widget.quiz.maxAttempts - 1}" : ""}',
                style: const TextStyle(color: Colors.orange),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz screen
            },
            child: const Text('Fermer'),
          ),
          if (!passed && widget.quiz.maxAttempts != 1)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close quiz screen
                // User can retake by opening quiz again
              },
              child: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
        ),
        body: const Center(
          child: Text('Aucune question disponible pour ce quiz'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final currentAnswer = _answers[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        if (_quizSubmitted) return true;

        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter le quiz'),
            content: const Text('Êtes-vous sûr de vouloir quitter ?\nVos réponses seront perdues.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Quitter'),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          actions: [
            if (widget.quiz.durationMinutes != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: _remainingSeconds < 60 ? Colors.red : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _remainingSeconds < 60 ? Colors.red : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[200],
            ),
            
            // Question counter
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${currentQuestion.points} point${currentQuestion.points > 1 ? "s" : ""}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Question and answers
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      currentQuestion.questionText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Answer options based on question type
                    _buildAnswerWidget(currentQuestion, currentAnswer),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  TextButton.icon(
                    onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                  ),

                  // Answer indicator
                  Row(
                    children: List.generate(_questions.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _answers.containsKey(index)
                              ? Colors.green
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),

                  // Next or Submit button
                  if (_currentQuestionIndex < _questions.length - 1)
                    ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Suivant'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _submitQuiz,
                      icon: const Icon(Icons.check),
                      label: const Text('Soumettre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerWidget(Question question, dynamic currentAnswer) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceWidget(question, currentAnswer);
      
      case QuestionType.trueFalse:
        return _buildTrueFalseWidget(question, currentAnswer);
      
      case QuestionType.shortAnswer:
        return _buildShortAnswerWidget(question, currentAnswer);
    }
  }

  Widget _buildMultipleChoiceWidget(Question question, dynamic currentAnswer) {
    final allowMultiple = question.correctAnswerIndices.length > 1;
    final selectedIndices = currentAnswer is List<int>
        ? currentAnswer
        : currentAnswer != null
            ? [currentAnswer as int]
            : <int>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allowMultiple)
          const Text(
            'Plusieurs réponses possibles',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        const SizedBox(height: 8),
        ...List.generate(question.options.length, (index) {
          final isSelected = selectedIndices.contains(index);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? Colors.blue[50] : null,
            child: InkWell(
              onTap: () {
                if (allowMultiple) {
                  final newSelection = List<int>.from(selectedIndices);
                  if (isSelected) {
                    newSelection.remove(index);
                  } else {
                    newSelection.add(index);
                  }
                  _answerQuestion(newSelection);
                } else {
                  _answerQuestion(index);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (allowMultiple)
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          final newSelection = List<int>.from(selectedIndices);
                          if (value == true) {
                            newSelection.add(index);
                          } else {
                            newSelection.remove(index);
                          }
                          _answerQuestion(newSelection);
                        },
                      )
                    else
                      Radio<int>(
                        value: index,
                        groupValue: selectedIndices.isNotEmpty ? selectedIndices.first : null,
                        onChanged: (value) {
                          if (value != null) {
                            _answerQuestion(value);
                          }
                        },
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrueFalseWidget(Question question, dynamic currentAnswer) {
    return Column(
      children: [
        _buildTrueFalseOption(
          label: 'Vrai',
          value: true,
          isSelected: currentAnswer == true,
          onTap: () => _answerQuestion(true),
        ),
        const SizedBox(height: 12),
        _buildTrueFalseOption(
          label: 'Faux',
          value: false,
          isSelected: currentAnswer == false,
          onTap: () => _answerQuestion(false),
        ),
      ],
    );
  }

  Widget _buildTrueFalseOption({
    required String label,
    required bool value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Radio<bool>(
                value: value,
                groupValue: isSelected ? value : null,
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortAnswerWidget(Question question, dynamic currentAnswer) {
    final controller = TextEditingController(text: currentAnswer?.toString() ?? '');

    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Entrez votre réponse...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) {
        _answerQuestion(value);
      },
    );
  }
}
