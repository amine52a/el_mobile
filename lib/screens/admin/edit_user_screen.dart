import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

/// Écran de modification d'un utilisateur (Admin)
class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bioController;

  late String _selectedRole;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _roles = [
    AppConstants.roleStudent,
    AppConstants.roleMentor,
    AppConstants.roleAdmin,
    AppConstants.roleRecruiter,
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _selectedRole,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
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
        title: const Text('Modifier l\'utilisateur'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar et nom
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: _getRoleColor(_selectedRole).withOpacity(0.2),
                      child: Text(
                        '${widget.user.firstName[0]}${widget.user.lastName[0]}'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(_selectedRole),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${widget.user.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Email
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),

              // Prénom
              CustomTextField(
                controller: _firstNameController,
                labelText: 'Prénom',
                prefixIcon: Icons.person,
                validator: (value) => Validators.validateRequired(value, 'Prénom'),
              ),
              const SizedBox(height: 16),

              // Nom
              CustomTextField(
                controller: _lastNameController,
                labelText: 'Nom',
                prefixIcon: Icons.person_outline,
                validator: (value) => Validators.validateRequired(value, 'Nom'),
              ),
              const SizedBox(height: 16),

              // Rôle
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getRoleColor(role),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(role),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Bio
              CustomTextField(
                controller: _bioController,
                labelText: 'Bio (optionnel)',
                prefixIcon: Icons.info,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Statut actif/inactif
              Card(
                child: SwitchListTile(
                  title: const Text('Compte actif'),
                  subtitle: Text(
                    _isActive
                        ? 'L\'utilisateur peut se connecter'
                        : 'L\'utilisateur ne peut pas se connecter',
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  secondary: Icon(
                    _isActive ? Icons.check_circle : Icons.cancel,
                    color: _isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Informations système
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations système',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSystemInfo(
                        'Créé le',
                        _formatDate(widget.user.createdAt),
                      ),
                      const SizedBox(height: 8),
                      _buildSystemInfo(
                        'Dernière modification',
                        widget.user.updatedAt != null
                            ? _formatDate(widget.user.updatedAt!)
                            : 'Jamais',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Enregistrer',
                      onPressed: _isLoading ? null : _saveChanges,
                      isLoading: _isLoading,
                      icon: Icons.save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Administrateur':
        return Colors.red;
      case 'Mentor':
        return Colors.blue;
      case 'Recruteur':
        return Colors.orange;
      case 'Étudiant':
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
