import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/message_widgets.dart';

/// Écran de profil utilisateur (F1.1.3)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditing = false;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      bio: _bioController.text.isEmpty ? null : _bioController.text,
    );

    final success = await authProvider.updateProfile(updatedUser);

    if (success && mounted) {
      setState(() {
        _isEditing = false;
        _successMessage = 'Profil mis à jour avec succès';
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    }
  }

  void _handleCancel() {
    setState(() {
      _isEditing = false;
      _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('Aucun utilisateur connecté'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo de profil
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            user.firstName[0] + user.lastName[0],
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Messages
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SuccessMessage(message: _successMessage!),
                    ),

                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ErrorMessage(
                        message: authProvider.errorMessage!,
                        onDismiss: () => authProvider.clearError(),
                      ),
                    ),

                  // Informations du profil
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations personnelles',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),

                          // Prénom
                          CustomTextField(
                            controller: _firstNameController,
                            labelText: 'Prénom',
                            prefixIcon: Icons.person_outline,
                            validator: (value) => Validators.validateName(value, 'Le prénom'),
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          // Nom
                          CustomTextField(
                            controller: _lastNameController,
                            labelText: 'Nom',
                            prefixIcon: Icons.person_outline,
                            validator: (value) => Validators.validateName(value, 'Le nom'),
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          // Email (non modifiable)
                          CustomTextField(
                            controller: TextEditingController(text: user.email),
                            labelText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),

                          // Rôle (non modifiable)
                          CustomTextField(
                            controller: TextEditingController(text: user.role),
                            labelText: 'Rôle',
                            prefixIcon: Icons.work_outline,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),

                          // Bio
                          CustomTextField(
                            controller: _bioController,
                            labelText: 'Bio',
                            hintText: 'Parlez-nous de vous...',
                            prefixIcon: Icons.notes,
                            maxLines: 3,
                            enabled: _isEditing,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations de compte
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations du compte',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Membre depuis'),
                            subtitle: Text(
                              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                            ),
                          ),
                          if (user.updatedAt != null)
                            ListTile(
                              leading: const Icon(Icons.update),
                              title: const Text('Dernière mise à jour'),
                              subtitle: Text(
                                '${user.updatedAt!.day}/${user.updatedAt!.month}/${user.updatedAt!.year}',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  if (_isEditing) ...[
                    CustomButton(
                      text: 'Enregistrer',
                      onPressed: _handleSave,
                      isLoading: authProvider.isLoading,
                      icon: Icons.save,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Annuler',
                      onPressed: _handleCancel,
                      isOutlined: true,
                    ),
                  ] else ...[
                    CustomButton(
                      text: 'Changer le mot de passe',
                      onPressed: () {
                        Navigator.of(context).pushNamed('/change-password');
                      },
                      icon: Icons.lock_outline,
                      isOutlined: true,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
