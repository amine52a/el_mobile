import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/internship.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../../core/constants/app_constants.dart';

/// Écran de création d'offre de stage (Admin/Recruteur)
/// Interface complète avec tous les champs F5.2.1
class CreateInternshipScreen extends StatefulWidget {
  const CreateInternshipScreen({Key? key}) : super(key: key);

  @override
  State<CreateInternshipScreen> createState() => _CreateInternshipScreenState();
}

class _CreateInternshipScreenState extends State<CreateInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _skillsController = TextEditingController();
  
  String? _selectedDomain;
  String? _selectedDuration;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _applicationDeadline;
  
  final List<String> _skillsList = [];
  bool _isLoading = false;

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
    final DateTime now = DateTime.now();
    final DateTime initialDate;
    final DateTime firstDate;
    
    // Pour la date limite, on peut choisir à partir d'aujourd'hui
    // Pour les dates de début et fin, on peut choisir à partir de maintenant
    if (field == 'deadline') {
      initialDate = now;
      firstDate = now;
    } else {
      initialDate = now;
      firstDate = now;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 730)), // 2 ans
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

  Future<void> _createInternship() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation des dates
    if (_startDate == null || _endDate == null || _applicationDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner toutes les dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_applicationDeadline!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date limite doit être avant la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final recruiterId = authProvider.currentUser?.id ?? '';

      final internship = Internship.create(
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        description: _descriptionController.text.trim(),
        domain: _selectedDomain!,
        location: _locationController.text.trim(),
        duration: _selectedDuration!,
        internshipType: _selectedType!,
        requiredSkills: _skillsList,
        startDate: _startDate!,
        endDate: _endDate!,
        applicationDeadline: _applicationDeadline!,
        recruiterId: recruiterId,
      );

      final internshipProvider = Provider.of<InternshipProvider>(context, listen: false);
      await internshipProvider.createInternship(internship);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Offre de stage créée avec succès !'),
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
        title: const Text('Créer une Offre de Stage'),
        backgroundColor: Colors.teal,
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
                    const Card(
                      color: Colors.teal,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.add_business, color: Colors.white, size: 32),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Créez une nouvelle offre de stage pour votre entreprise',
                                style: TextStyle(color: Colors.white, fontSize: 16),
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
                          _selectedDomain = value;
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
                          _selectedDuration = value;
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
                          _selectedType = value;
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
                            backgroundColor: Colors.teal,
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
                            backgroundColor: Colors.teal.shade50,
                            labelStyle: const TextStyle(color: Colors.teal),
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
                      leading: const Icon(Icons.calendar_today, color: Colors.teal),
                      title: const Text('Date de début'),
                      subtitle: Text(_startDate != null 
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Non sélectionnée'),
                      trailing: const Icon(Icons.edit),
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () => _selectDate(context, 'start'),
                    ),
                    const SizedBox(height: 8),

                    // Date de fin
                    ListTile(
                      leading: const Icon(Icons.event, color: Colors.teal),
                      title: const Text('Date de fin'),
                      subtitle: Text(_endDate != null 
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'Non sélectionnée'),
                      trailing: const Icon(Icons.edit),
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () => _selectDate(context, 'end'),
                    ),
                    const SizedBox(height: 8),

                    // Date limite de candidature
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.orange),
                      title: const Text('Date limite de candidature'),
                      subtitle: Text(_applicationDeadline != null 
                          ? '${_applicationDeadline!.day}/${_applicationDeadline!.month}/${_applicationDeadline!.year}'
                          : 'Non sélectionnée'),
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
                            onPressed: _createInternship,
                            icon: const Icon(Icons.check),
                            label: const Text('Créer l\'offre'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
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
