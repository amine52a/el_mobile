import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/internship.dart';
import '../../providers/internship_provider.dart';
import '../../core/constants/app_constants.dart';

/// Écran d'édition d'une offre de stage existante
/// Formulaire pré-rempli pour modification (F5.2.3 UPDATE)
class EditInternshipScreen extends StatefulWidget {
  final Internship internship;

  const EditInternshipScreen({
    Key? key,
    required this.internship,
  }) : super(key: key);

  @override
  State<EditInternshipScreen> createState() => _EditInternshipScreenState();
}

class _EditInternshipScreenState extends State<EditInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  final _skillsController = TextEditingController();
  
  late String _selectedDomain;
  late String _selectedDuration;
  late String _selectedType;
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _applicationDeadline;
  
  late List<String> _skillsList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplir les champs avec les données existantes
    _titleController = TextEditingController(text: widget.internship.title);
    _companyController = TextEditingController(text: widget.internship.company);
    _descriptionController = TextEditingController(text: widget.internship.description);
    _locationController = TextEditingController(text: widget.internship.location);
    
    _selectedDomain = widget.internship.domain;
    _selectedDuration = widget.internship.duration;
    _selectedType = widget.internship.internshipType;
    _startDate = widget.internship.startDate;
    _endDate = widget.internship.endDate;
    _applicationDeadline = widget.internship.applicationDeadline;
    
    _skillsList = List.from(widget.internship.requiredSkills);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillsController.text.trim();
    if (skill.isNotEmpty && !_skillsList.contains(skill)) {
      setState(() {
        _skillsList.add(skill);
        _skillsController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skillsList.remove(skill);
    });
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: field == 'start' 
          ? _startDate 
          : field == 'end' 
              ? _endDate 
              : _applicationDeadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    
    if (picked != null) {
      setState(() {
        switch (field) {
          case 'start':
            _startDate = picked;
            break;
          case 'end':
            _endDate = picked;
            break;
          case 'deadline':
            _applicationDeadline = picked;
            break;
        }
      });
    }
  }

  Future<void> _updateInternship() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation des dates
    if (_applicationDeadline.isAfter(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date limite doit être avant la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_skillsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une compétence requise'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedInternship = widget.internship.copyWith(
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        description: _descriptionController.text.trim(),
        domain: _selectedDomain,
        location: _locationController.text.trim(),
        duration: _selectedDuration,
        internshipType: _selectedType,
        requiredSkills: _skillsList,
        startDate: _startDate,
        endDate: _endDate,
        applicationDeadline: _applicationDeadline,
      );

      final internshipProvider = Provider.of<InternshipProvider>(context, listen: false);
      await internshipProvider.updateInternship(updatedInternship);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Offre mise à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'Offre'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Card(
                      color: Colors.orange.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.orange.shade800, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Modifiez les informations de l\'offre de stage',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Titre de l'offre
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre du poste *',
                        hintText: 'Ex: Développeur Web Full Stack',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le titre est requis';
                        }
                        if (value.trim().length < 5) {
                          return 'Le titre doit contenir au moins 5 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Entreprise
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'entreprise *',
                        hintText: 'Ex: Tech Solutions Palestine',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom de l\'entreprise est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Domaine
                    DropdownButtonFormField<String>(
                      value: _selectedDomain,
                      decoration: const InputDecoration(
                        labelText: 'Domaine *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.internshipDomains.map((domain) {
                        return DropdownMenuItem(
                          value: domain,
                          child: Text(domain),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDomain = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le domaine est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Localisation
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Localisation *',
                        hintText: 'Ex: Ramallah, Palestine',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La localisation est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Durée
                    DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      decoration: const InputDecoration(
                        labelText: 'Durée *',
                        prefixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '1 mois', child: Text('1 mois')),
                        DropdownMenuItem(value: '2 mois', child: Text('2 mois')),
                        DropdownMenuItem(value: '3 mois', child: Text('3 mois')),
                        DropdownMenuItem(value: '4 mois', child: Text('4 mois')),
                        DropdownMenuItem(value: '5 mois', child: Text('5 mois')),
                        DropdownMenuItem(value: '6 mois', child: Text('6 mois')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDuration = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La durée est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Type de stage
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type de stage *',
                        prefixIcon: Icon(Icons.assignment),
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.internshipTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le type de stage est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description du poste *',
                        hintText: 'Décrivez les missions, responsabilités...',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La description est requise';
                        }
                        if (value.trim().length < 50) {
                          return 'La description doit contenir au moins 50 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Compétences requises
                    const Text(
                      'Compétences requises *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _skillsController,
                            decoration: const InputDecoration(
                              hintText: 'Ex: Flutter, Dart, Firebase',
                              prefixIcon: Icon(Icons.star),
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addSkill(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _addSkill,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_skillsList.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skillsList.map((skill) {
                          return Chip(
                            label: Text(skill),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeSkill(skill),
                            backgroundColor: Colors.orange.shade50,
                            labelStyle: const TextStyle(color: Colors.orange),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),

                    // Dates
                    const Text(
                      'Dates importantes *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    // Date de début
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.orange),
                      title: const Text('Date de début'),
                      subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                      trailing: const Icon(Icons.edit),
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () => _selectDate(context, 'start'),
                    ),
                    const SizedBox(height: 8),

                    // Date de fin
                    ListTile(
                      leading: const Icon(Icons.event, color: Colors.orange),
                      title: const Text('Date de fin'),
                      subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                      trailing: const Icon(Icons.edit),
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () => _selectDate(context, 'end'),
                    ),
                    const SizedBox(height: 8),

                    // Date limite de candidature
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.deepOrange),
                      title: const Text('Date limite de candidature'),
                      subtitle: Text('${_applicationDeadline.day}/${_applicationDeadline.month}/${_applicationDeadline.year}'),
                      trailing: const Icon(Icons.edit),
                      tileColor: Colors.orange.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () => _selectDate(context, 'deadline'),
                    ),
                    const SizedBox(height: 32),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _updateInternship,
                            icon: const Icon(Icons.check),
                            label: const Text('Enregistrer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
