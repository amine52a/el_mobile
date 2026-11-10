import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/course_provider.dart';
import '../../data/models/course.dart';
import '../../core/constants/app_constants.dart';

/// Screen for creating or editing a course with image upload
class CourseFormScreen extends StatefulWidget {
  final Course? course;

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructorController;

  String? _selectedLevel;
  String? _selectedSubject;
  String? _selectedLanguage;

  bool _isLoading = false;
  File? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();

    final course = widget.course;
    _titleController = TextEditingController(text: course?.title ?? '');
    _descriptionController = TextEditingController(text: course?.description ?? '');
    _instructorController = TextEditingController(text: course?.instructorName ?? '');

    _selectedLevel = course?.level;
    _selectedSubject = course?.subject;
    _selectedLanguage = course?.language;
    _existingImageUrl = course?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _existingImageUrl = null; // Clear existing URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLevel == null || _selectedSubject == null || _selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner le niveau, la matière et la langue'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // For now, we'll use a placeholder for image storage
    // In a real app, you would upload the image to a server and get back a URL
    String? imageUrl = _existingImageUrl;
    if (_selectedImage != null) {
      // TODO: Upload image to server and get URL
      // For now, we'll use the local path (this won't work in production)
      imageUrl = _selectedImage!.path;
    }

    bool success;
    if (widget.course == null) {
      success = await courseProvider.createCourse(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        level: _selectedLevel!,
        subject: _selectedSubject!,
        language: _selectedLanguage!,
        instructorName: _instructorController.text.trim(),
        imageUrl: imageUrl,
      );
    } else {
      final course = Course(
        id: widget.course!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        level: _selectedLevel!,
        subject: _selectedSubject!,
        language: _selectedLanguage!,
        instructorName: _instructorController.text.trim(),
        imageUrl: imageUrl,
        enrolledStudents: widget.course!.enrolledStudents,
        totalChapters: widget.course!.totalChapters,
        totalResources: widget.course!.totalResources,
        createdAt: widget.course!.createdAt,
        updatedAt: DateTime.now(),
      );
      success = await courseProvider.updateCourse(course);
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.course == null
              ? '✅ Cours créé avec succès !'
              : '✅ Cours modifié avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(courseProvider.errorMessage ?? 'Une erreur est survenue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50),
              const Color(0xFF45A049),
              const Color(0xFFE57373).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isEditing),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildImageSection(),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _titleController,
                          label: 'Titre du cours',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le titre est requis';
                            }
                            return null;
                          },
                          maxLength: 100,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La description est requise';
                            }
                            return null;
                          },
                          maxLength: 500,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _instructorController,
                          label: 'Nom de l\'instructeur',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom de l\'instructeur est requis';
                            }
                            return null;
                          },
                          maxLength: 100,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          value: _selectedLevel,
                          label: 'Niveau',
                          icon: Icons.signal_cellular_alt,
                          items: AppConstants.courseLevels,
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          value: _selectedSubject,
                          label: 'Matière',
                          icon: Icons.book,
                          items: AppConstants.courseSubjects,
                          onChanged: (value) {
                            setState(() {
                              _selectedSubject = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          value: _selectedLanguage,
                          label: 'Langue',
                          icon: Icons.language,
                          items: AppConstants.courseLanguages,
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildSaveButton(isEditing),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Modifier' : 'Créer',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isEditing ? 'Cours existant' : 'Nouveau cours',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Image du cours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null || _existingImageUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withOpacity(0.3),
                          const Color(0xFFE57373).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: _removeImage,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            )
          else
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ajouter une image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cliquez pour sélectionner',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedImage == null && _existingImageUrl == null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'L\'image est optionnelle',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: onChanged,
        validator: (val) {
          if (val == null) {
            return 'Veuillez sélectionner $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveCourse,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          isEditing ? 'Modifier le cours' : 'Créer le cours',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}