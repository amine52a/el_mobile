import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/chapter.dart';
import '../../providers/course_provider.dart';

/// Screen for creating or editing a chapter (F2.3.4)
class ChapterFormScreen extends StatefulWidget {
  final int courseId;
  final Chapter? chapter; // null for create, filled for edit

  const ChapterFormScreen({
    super.key,
    required this.courseId,
    this.chapter,
  });

  @override
  State<ChapterFormScreen> createState() => _ChapterFormScreenState();
}

class _ChapterFormScreenState extends State<ChapterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _orderController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // If editing, pre-fill the form
    if (widget.chapter != null) {
      _titleController.text = widget.chapter!.title;
      _descriptionController.text = widget.chapter!.description ?? '';
      _durationController.text = widget.chapter!.durationMinutes?.toString() ?? '';
      _orderController.text = widget.chapter!.orderIndex.toString();
    } else {
      // For new chapter, set next order index
      _setNextOrderIndex();
    }
  }

  Future<void> _setNextOrderIndex() async {
    final provider = Provider.of<CourseProvider>(context, listen: false);
    await provider.loadChaptersByCourse(widget.courseId);
    final chapters = provider.currentChapters;
    
    // Set order to next available
    final nextOrder = chapters.isEmpty ? 1 : (chapters.map((c) => c.orderIndex).reduce((a, b) => a > b ? a : b) + 1);
    _orderController.text = nextOrder.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveChapter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<CourseProvider>(context, listen: false);

    // Create chapter object
    final chapter = Chapter(
      id: widget.chapter?.id, // null for create, existing ID for edit
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      orderIndex: int.parse(_orderController.text),
      durationMinutes: _durationController.text.isEmpty 
          ? null 
          : int.parse(_durationController.text),
    );

    bool success;
    if (widget.chapter == null) {
      // Create new chapter
      success = await provider.createChapter(chapter);
    } else {
      // Update existing chapter
      success = await provider.updateChapter(chapter);
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.chapter == null 
                ? '✅ Chapitre créé avec succès' 
                : '✅ Chapitre modifié avec succès'
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.chapter != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le chapitre' : 'Nouveau chapitre'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Les chapitres organisent votre cours en sections. Vous pourrez ensuite ajouter des ressources (vidéos, PDFs, etc.) dans chaque chapitre.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre du chapitre *',
                hintText: 'Ex: Introduction à Flutter',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Décrivez brièvement le contenu de ce chapitre',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Duration field
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: 'Durée estimée (optionnel)',
                hintText: 'En minutes',
                prefixIcon: const Icon(Icons.access_time),
                suffixText: 'min',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Durée totale estimée pour compléter ce chapitre',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'La durée doit être un nombre positif';
                  }
                  if (duration > 999) {
                    return 'La durée ne peut pas dépasser 999 minutes';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Order field
            TextFormField(
              controller: _orderController,
              decoration: InputDecoration(
                labelText: 'Ordre d\'affichage *',
                hintText: 'Position dans la liste',
                prefixIcon: const Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Numéro de position (1 = premier chapitre)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'ordre est obligatoire';
                }
                final order = int.tryParse(value);
                if (order == null || order <= 0) {
                  return 'L\'ordre doit être un nombre positif';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveChapter,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(
                  isEditing ? 'Enregistrer les modifications' : 'Créer le chapitre',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
