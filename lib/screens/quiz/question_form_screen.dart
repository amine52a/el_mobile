import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/question.dart';
import '../../providers/quiz_provider.dart';

/// Screen for adding or editing a question in a quiz (F3.1.4)
class QuestionFormScreen extends StatefulWidget {
  final int quizId;
  final Question? question; // null for create, filled for edit

  const QuestionFormScreen({
    super.key,
    required this.quizId,
    this.question,
  });

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController();
  
  QuestionType _selectedType = QuestionType.multipleChoice;
  List<int> _correctAnswerIndices = [];
  bool? _correctAnswerBool;
  String? _correctAnswerText;
  final List<TextEditingController> _optionControllers = [];
  int _optionCount = 4; // Default 4 options for MCQ
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // If editing, pre-fill the form
    if (widget.question != null) {
      _questionTextController.text = widget.question!.questionText;
      _explanationController.text = widget.question!.explanation ?? '';
      _pointsController.text = widget.question!.points.toString();
      _selectedType = widget.question!.type;
      _correctAnswerIndices = List.from(widget.question!.correctAnswerIndices);
      _correctAnswerBool = widget.question!.correctAnswerBool;
      _correctAnswerText = widget.question!.correctAnswerText;
      
      // Parse existing options
      if (widget.question!.options.isNotEmpty) {
        _optionCount = widget.question!.options.length;
        for (var option in widget.question!.options) {
          final controller = TextEditingController(text: option);
          _optionControllers.add(controller);
        }
      }
    } else {
      // Default values for new question
      _pointsController.text = '1';
      
      // Initialize option controllers for MCQ
      for (int i = 0; i < _optionCount; i++) {
        _optionControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _optionCount++;
    });
  }

  void _removeOption(int index) {
    if (_optionCount > 2) { // Minimum 2 options
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
        _optionCount--;
      });
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate correct answer
    if (_selectedType == QuestionType.multipleChoice && _correctAnswerIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins une bonne réponse')),
      );
      return;
    }

    if (_selectedType == QuestionType.trueFalse && _correctAnswerBool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner Vrai ou Faux')),
      );
      return;
    }

    if (_selectedType == QuestionType.shortAnswer && 
        (_correctAnswerText == null || _correctAnswerText!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir la réponse correcte')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Prepare options list
    List<String> options = [];
    if (_selectedType == QuestionType.multipleChoice) {
      options = _optionControllers.map((c) => c.text.trim()).toList();
    } else if (_selectedType == QuestionType.trueFalse) {
      options = ['Vrai', 'Faux'];
    }

    // Get current question count to set order
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final currentQuestions = quizProvider.currentQuizQuestions;
    final orderIndex = widget.question?.orderIndex ?? currentQuestions.length + 1;

    // Create question object
    final question = Question(
      id: widget.question?.id,
      quizId: widget.quizId,
      questionText: _questionTextController.text.trim(),
      type: _selectedType,
      options: options,
      correctAnswerIndices: _selectedType == QuestionType.multipleChoice ? _correctAnswerIndices : [],
      correctAnswerBool: _selectedType == QuestionType.trueFalse ? _correctAnswerBool : null,
      correctAnswerText: _selectedType == QuestionType.shortAnswer ? _correctAnswerText : null,
      points: int.parse(_pointsController.text),
      explanation: _explanationController.text.trim().isEmpty 
          ? null 
          : _explanationController.text.trim(),
      orderIndex: orderIndex,
    );

    // Save via provider
    bool success;
    if (widget.question == null) {
      final questionId = await quizProvider.addQuestion(question);
      success = questionId != null;
    } else {
      success = await quizProvider.updateQuestion(question);
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.question == null 
              ? 'Question ajoutée avec succès' 
              : 'Question modifiée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quizProvider.error ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question == null ? 'Nouvelle Question' : 'Modifier Question'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveQuestion,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Question Text
            TextFormField(
              controller: _questionTextController,
              decoration: const InputDecoration(
                labelText: 'Question *',
                hintText: 'Ex: Quelle est la capitale de la Palestine?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La question est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Question Type
            DropdownButtonFormField<QuestionType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de question *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: QuestionType.multipleChoice,
                  child: Text('QCM (Choix multiples)'),
                ),
                DropdownMenuItem(
                  value: QuestionType.trueFalse,
                  child: Text('Vrai/Faux'),
                ),
                DropdownMenuItem(
                  value: QuestionType.shortAnswer,
                  child: Text('Réponse courte'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _correctAnswerIndices = [];
                  _correctAnswerBool = null;
                  _correctAnswerText = null;
                  
                  // Reset options when changing type
                  if (value == QuestionType.multipleChoice && _optionControllers.isEmpty) {
                    for (int i = 0; i < 4; i++) {
                      _optionControllers.add(TextEditingController());
                    }
                    _optionCount = 4;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Options for Multiple Choice
            if (_selectedType == QuestionType.multipleChoice) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Options de réponse',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addOption,
                    tooltip: 'Ajouter une option',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_optionCount, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _correctAnswerIndices.contains(index),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _correctAnswerIndices.add(index);
                            } else {
                              _correctAnswerIndices.remove(index);
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                            suffixIcon: _optionCount > 2
                                ? IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _removeOption(index),
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Option obligatoire';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_correctAnswerIndices.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Bonne(s) réponse(s): ${_correctAnswerIndices.map((i) => _optionControllers[i].text).join(", ")}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Options for True/False
            if (_selectedType == QuestionType.trueFalse) ...[
              const Text(
                'Bonne réponse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RadioListTile<bool>(
                title: const Text('Vrai'),
                value: true,
                groupValue: _correctAnswerBool,
                onChanged: (value) {
                  setState(() {
                    _correctAnswerBool = value;
                  });
                },
              ),
              RadioListTile<bool>(
                title: const Text('Faux'),
                value: false,
                groupValue: _correctAnswerBool,
                onChanged: (value) {
                  setState(() {
                    _correctAnswerBool = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Correct Answer for Short Answer
            if (_selectedType == QuestionType.shortAnswer) ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Réponse correcte *',
                  hintText: 'La réponse attendue (sensible à la casse)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _correctAnswerText = value;
                  });
                },
                initialValue: _correctAnswerText,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La réponse correcte est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Points
            TextFormField(
              controller: _pointsController,
              decoration: const InputDecoration(
                labelText: 'Points *',
                hintText: 'Nombre de points pour cette question',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Les points sont obligatoires';
                }
                final points = double.tryParse(value);
                if (points == null || points <= 0) {
                  return 'Les points doivent être > 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Explanation
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Explication (optionnel)',
                hintText: 'Explication affichée après la réponse',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveQuestion,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.question == null ? 'Ajouter la question' : 'Modifier la question'),
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
