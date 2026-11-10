import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/course_provider.dart';
import '../../data/models/resource.dart';
import '../../data/models/quiz.dart';
import '../quiz/quiz_selection_screen.dart';

/// Form screen for creating/editing resources (F2.3.5)
class ResourceFormScreen extends StatefulWidget {
  final int courseId;
  final int? chapterId;
  final Resource? resource; // null = create, non-null = edit

  const ResourceFormScreen({
    super.key,
    required this.courseId,
    this.chapterId,
    this.resource,
  });

  @override
  State<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  late TextEditingController _durationController;
  late TextEditingController _orderController;
  
  ResourceType _selectedType = ResourceType.video;
  bool _isMandatory = false;
  bool _isSubmitting = false;
  Quiz? _selectedQuiz; // Quiz sélectionné pour les ressources de type quiz
  
  // File upload state
  File? _selectedFile;
  String? _uploadedFilePath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    _titleController = TextEditingController(text: widget.resource?.title ?? '');
    _descriptionController = TextEditingController(text: widget.resource?.description ?? '');
    _urlController = TextEditingController(text: widget.resource?.url ?? '');
    _durationController = TextEditingController(
      text: widget.resource?.durationSeconds?.toString() ?? '',
    );
    _orderController = TextEditingController(
      text: widget.resource?.orderIndex.toString() ?? '1',
    );
    
    if (widget.resource != null) {
      _selectedType = widget.resource!.type;
      _isMandatory = widget.resource!.isMandatory;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _durationController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  /// Pick and upload a file (PDF, video, etc.)
  Future<void> _pickAndUploadFile() async {
    try {
      // Determine allowed file types based on resource type
      FileType fileType;
      List<String> allowedExtensions;
      
      switch (_selectedType) {
        case ResourceType.pdf:
          fileType = FileType.custom;
          allowedExtensions = ['pdf'];
          break;
        case ResourceType.video:
          fileType = FileType.video;
          allowedExtensions = ['mp4', 'avi', 'mov', 'mkv'];
          break;
        default:
          fileType = FileType.any;
          allowedExtensions = [];
      }

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: fileType == FileType.custom ? allowedExtensions : null,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final pickedFile = result.files.first;
      
      // Validate file size (max 50MB for videos, 10MB for PDFs)
      final maxSize = _selectedType == ResourceType.video ? 50 * 1024 * 1024 : 10 * 1024 * 1024;
      if (pickedFile.size > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Le fichier est trop volumineux (max ${_selectedType == ResourceType.video ? '50MB' : '10MB'})',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      setState(() => _isUploading = true);

      // Get app directory for storing files
      final appDir = await getApplicationDocumentsDirectory();
      final resourcesDir = Directory('${appDir.path}/uploaded_resources');
      
      // Create directory if it doesn't exist
      if (!await resourcesDir.exists()) {
        await resourcesDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = pickedFile.extension ?? 'file';
      final fileName = '${_selectedType.toString().split('.').last}_$timestamp.$extension';
      final destinationPath = '${resourcesDir.path}/$fileName';

      // Copy file to app directory
      final sourceFile = File(pickedFile.path!);
      await sourceFile.copy(destinationPath);

      setState(() {
        _selectedFile = File(destinationPath);
        _uploadedFilePath = destinationPath;
        _urlController.text = 'local://$destinationPath';
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Fichier uploadé: ${pickedFile.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Remove uploaded file
  void _removeUploadedFile() {
    setState(() {
      _selectedFile = null;
      _uploadedFilePath = null;
      _urlController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fichier retiré'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate quiz selection for quiz-type resources
    if (_selectedType == ResourceType.quiz && _selectedQuiz == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez sélectionner un quiz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    final resource = Resource(
      id: widget.resource?.id,
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      durationSeconds: _durationController.text.trim().isEmpty
          ? null
          : int.tryParse(_durationController.text.trim()),
      orderIndex: int.tryParse(_orderController.text.trim()) ?? 1,
      isMandatory: _isMandatory,
      quizId: _selectedType == ResourceType.quiz ? _selectedQuiz?.id : null,
      createdAt: widget.resource?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = widget.resource == null
        ? await courseProvider.createResource(resource)
        : await courseProvider.updateResource(resource);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.resource == null
                  ? '✅ Ressource créée avec succès'
                  : '✅ Ressource mise à jour',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(courseProvider.errorMessage ?? 'Erreur lors de l\'enregistrement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource == null ? 'Nouvelle Ressource' : 'Modifier Ressource'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est obligatoire';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Type
            DropdownButtonFormField<ResourceType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ResourceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getTypeIcon(type), size: 20),
                      const SizedBox(width: 8),
                      Text(_getTypeName(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    // Reset quiz selection if changing away from quiz type
                    if (value != ResourceType.quiz) {
                      _selectedQuiz = null;
                    }
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),

            // Quiz selection button (only shown when type is quiz)
            if (_selectedType == ResourceType.quiz) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedQuiz == null ? Colors.red : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.quiz,
                    color: _selectedQuiz == null ? Colors.red : Colors.blue,
                  ),
                  title: Text(
                    _selectedQuiz == null
                        ? 'Sélectionner un quiz *'
                        : _selectedQuiz!.title,
                    style: TextStyle(
                      color: _selectedQuiz == null ? Colors.red : null,
                    ),
                  ),
                  subtitle: _selectedQuiz != null
                      ? Text(_selectedQuiz!.description ?? 'Aucune description')
                      : const Text('Cliquez pour choisir un quiz'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final quiz = await Navigator.push<Quiz>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizSelectionScreen(
                          courseId: widget.courseId,
                          chapterId: widget.chapterId,
                        ),
                      ),
                    );

                    if (quiz != null) {
                      setState(() {
                        _selectedQuiz = quiz;
                        // Auto-fill title if empty
                        if (_titleController.text.isEmpty) {
                          _titleController.text = quiz.title;
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // URL or File Upload
            if (_selectedType != ResourceType.quiz) ...[
              // File upload button
              if (_selectedType == ResourceType.pdf || _selectedType == ResourceType.video) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.upload_file, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Upload de fichier local',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedType == ResourceType.pdf
                            ? 'Téléversez un fichier PDF depuis votre appareil'
                            : 'Téléversez une vidéo depuis votre appareil',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Show uploaded file info or upload button
                      if (_uploadedFilePath != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Fichier uploadé',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _uploadedFilePath!.split('/').last,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: _removeUploadedFile,
                                color: Colors.red,
                                tooltip: 'Retirer le fichier',
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _pickAndUploadFile,
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.folder_open),
                          label: Text(_isUploading ? 'Upload en cours...' : 'Choisir un fichier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'OU entrez une URL en ligne ci-dessous',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: _selectedType == ResourceType.external
                      ? 'URL *'
                      : 'URL en ligne (optionnel)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link),
                  helperText: _getUrlHelperText(),
                ),
                validator: (value) {
                  // If file is uploaded, URL is optional
                  if (_uploadedFilePath != null) {
                    return null;
                  }
                  
                  if (_selectedType == ResourceType.external ||
                      _selectedType == ResourceType.video ||
                      _selectedType == ResourceType.pdf) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'URL ou un fichier uploadé est obligatoire';
                    }
                    if (!value.startsWith('http://') && 
                        !value.startsWith('https://') && 
                        !value.startsWith('local://')) {
                      return 'L\'URL doit commencer par http://, https:// ou être un fichier local';
                    }
                  }
                  return null;
                },
              ),
            ],
            
            if (_selectedType != ResourceType.quiz)
              const SizedBox(height: 16),
            
            // Duration (for video/audio)
            if (_selectedType == ResourceType.video || _selectedType == ResourceType.pdf)
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Durée (secondes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                  helperText: 'Ex: 300 pour 5 minutes',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (int.tryParse(value.trim()) == null) {
                      return 'Doit être un nombre entier';
                    }
                  }
                  return null;
                },
              ),
            
            if (_selectedType == ResourceType.video || _selectedType == ResourceType.pdf)
              const SizedBox(height: 16),
            
            // Order Index
            TextFormField(
              controller: _orderController,
              decoration: const InputDecoration(
                labelText: 'Ordre d\'affichage *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
                helperText: '1 = premier, 2 = deuxième, etc.',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'ordre est obligatoire';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Doit être un nombre entier';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Mandatory checkbox
            SwitchListTile(
              title: const Text('Ressource obligatoire'),
              subtitle: const Text('Les étudiants doivent consulter cette ressource'),
              value: _isMandatory,
              onChanged: (value) {
                setState(() => _isMandatory = value);
              },
              secondary: Icon(
                _isMandatory ? Icons.star : Icons.star_border,
                color: _isMandatory ? Colors.orange : null,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.resource == null ? 'Créer la ressource' : 'Mettre à jour',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            
            if (widget.resource != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(ResourceType type) {
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

  String _getTypeName(ResourceType type) {
    switch (type) {
      case ResourceType.video:
        return 'Vidéo';
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.text:
        return 'Texte';
      case ResourceType.quiz:
        return 'Quiz';
      case ResourceType.external:
        return 'Lien externe';
    }
  }

  String _getUrlHelperText() {
    switch (_selectedType) {
      case ResourceType.video:
        return 'URL YouTube (ex: https://youtube.com/watch?v=...) ou uploadez un fichier';
      case ResourceType.pdf:
        return 'URL du PDF en ligne ou uploadez un fichier depuis votre appareil';
      case ResourceType.external:
        return 'Lien vers une ressource externe';
      default:
        return 'URL optionnelle';
    }
  }
}
