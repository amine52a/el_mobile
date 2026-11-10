import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quiz.dart';
import '../../providers/quiz_provider.dart';

/// Screen for creating or editing a quiz (F3.1.1 - Admin only)
class QuizFormScreen extends StatefulWidget {
  final int courseId;
  final int? chapterId;
  final Quiz? quiz; // null for create, filled for edit

  const QuizFormScreen({
    super.key,
    required this.courseId,
    this.chapterId,
    this.quiz,
  });

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxAttemptsController = TextEditingController();
  final _passingScoreController = TextEditingController();
  
  bool _shuffleQuestions = false;
  bool _showResults = true;
  DateTime? _availableFrom;
  DateTime? _availableUntil;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // If editing, pre-fill the form
    if (widget.quiz != null) {
      _titleController.text = widget.quiz!.title;
      _descriptionController.text = widget.quiz!.description ?? '';
      _durationController.text = widget.quiz!.durationMinutes?.toString() ?? '';
      _maxAttemptsController.text = widget.quiz!.maxAttempts.toString();
      _passingScoreController.text = widget.quiz!.passingScore.toString();
      _shuffleQuestions = widget.quiz!.shuffleQuestions;
      _showResults = widget.quiz!.showResults;
      _availableFrom = widget.quiz!.availableFrom;
      _availableUntil = widget.quiz!.availableUntil;
    } else {
      // Default values for new quiz
      _maxAttemptsController.text = '0'; // Unlimited
      _passingScoreController.text = '50'; // 50%
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxAttemptsController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create quiz object
    final quiz = Quiz(
      id: widget.quiz?.id,
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      durationMinutes: _durationController.text.isEmpty 
          ? null 
          : int.parse(_durationController.text),
      maxAttempts: int.parse(_maxAttemptsController.text),
      passingScore: double.parse(_passingScoreController.text),
      shuffleQuestions: _shuffleQuestions,
      showResults: _showResults,
      availableFrom: _availableFrom,
      availableUntil: _availableUntil,
    );

    // Save via provider
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    int? quizId;
    
    if (widget.quiz == null) {
      quizId = await quizProvider.createQuiz(quiz);
    } else {
      final success = await quizProvider.updateQuiz(quiz);
      if (success) quizId = quiz.id;
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (quizId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.quiz == null 
              ? 'Quiz créé avec succès' 
              : 'Quiz modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, quizId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quizProvider.error ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDateTime(bool isFrom) async {
    final DateTime initialDate = isFrom 
        ? (_availableFrom ?? DateTime.now())
        : (_availableUntil ?? DateTime.now().add(const Duration(days: 30)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _availableFrom = picked;
        } else {
          _availableUntil = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quiz != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le Quiz' : 'Nouveau Quiz'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.chapterId != null 
                            ? 'Quiz spécifique au chapitre' 
                            : 'Quiz général du cours',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre du quiz *',
                hintText: 'Ex: Quiz de révision Chapitre 1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est obligatoire';
                }
                if (value.trim().length < 3) {
                  return 'Le titre doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Décrivez le contenu de ce quiz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Duration & Max Attempts Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Durée (minutes)',
                      hintText: 'Vide = Illimité',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Durée invalide';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxAttemptsController,
                    decoration: const InputDecoration(
                      labelText: 'Tentatives max *',
                      hintText: '0 = Illimité',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final attempts = int.tryParse(value);
                      if (attempts == null || attempts < 0) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Passing Score
            TextFormField(
              controller: _passingScoreController,
              decoration: const InputDecoration(
                labelText: 'Score de passage (%) *',
                hintText: 'Ex: 50 pour 50%',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le score de passage est obligatoire';
                }
                final score = double.tryParse(value);
                if (score == null || score < 0 || score > 100) {
                  return 'Le score doit être entre 0 et 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Options Section
            const Text(
              'Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Shuffle Questions
            SwitchListTile(
              title: const Text('Mélanger les questions'),
              subtitle: const Text('Afficher les questions dans un ordre aléatoire'),
              value: _shuffleQuestions,
              onChanged: (value) {
                setState(() {
                  _shuffleQuestions = value;
                });
              },
              secondary: const Icon(Icons.shuffle),
            ),

            // Show Results
            SwitchListTile(
              title: const Text('Afficher les résultats'),
              subtitle: const Text('Montrer le score après la soumission'),
              value: _showResults,
              onChanged: (value) {
                setState(() {
                  _showResults = value;
                });
              },
              secondary: const Icon(Icons.visibility),
            ),
            const SizedBox(height: 24),

            // Availability Section
            const Text(
              'Disponibilité',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Available From
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Disponible à partir de'),
              subtitle: Text(
                _availableFrom != null
                    ? '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                    : 'Pas de date de début',
              ),
              trailing: _availableFrom != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _availableFrom = null;
                        });
                      },
                    )
                  : null,
              onTap: () => _pickDateTime(true),
            ),

            // Available Until
            ListTile(
              leading: const Icon(Icons.event_busy),
              title: const Text('Disponible jusqu\'à'),
              subtitle: Text(
                _availableUntil != null
                    ? '${_availableUntil!.day}/${_availableUntil!.month}/${_availableUntil!.year}'
                    : 'Pas de date de fin',
              ),
              trailing: _availableUntil != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _availableUntil = null;
                        });
                      },
                    )
                  : null,
              onTap: () => _pickDateTime(false),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveQuiz,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(isEditing ? 'Modifier le quiz' : 'Créer le quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
