import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/message_widgets.dart';
import '../../widgets/captcha_widget.dart';
import '../home/home_screen.dart';

/// Écran d'inscription (F1.1.1)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  
  String _selectedRole = AppConstants.roleStudent;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCaptchaValid = false;

  final List<String> _roles = [
    AppConstants.roleStudent,
    AppConstants.roleMentor,
    AppConstants.roleRecruiter,
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier le CAPTCHA
    if (!_isCaptchaValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez compléter la vérification de sécurité'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      role: _selectedRole,
      bio: _bioController.text.isEmpty ? null : _bioController.text,
    );

    if (success && mounted) {
      // Navigation vers l'écran d'accueil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                Icon(
                  Icons.person_add,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez la communauté EduPalestine',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Message d'erreur
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ErrorMessage(
                          message: authProvider.errorMessage!,
                          onDismiss: () => authProvider.clearError(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Prénom
                CustomTextField(
                  controller: _firstNameController,
                  labelText: 'Prénom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => Validators.validateName(value, 'Le prénom'),
                ),
                const SizedBox(height: 16),

                // Nom
                CustomTextField(
                  controller: _lastNameController,
                  labelText: 'Nom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => Validators.validateName(value, 'Le nom'),
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'votre.email@exemple.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Rôle
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  validator: Validators.validateRole,
                ),
                const SizedBox(height: 16),

                // Bio (optionnel)
                CustomTextField(
                  controller: _bioController,
                  labelText: 'Bio (optionnel)',
                  hintText: 'Parlez-nous de vous...',
                  prefixIcon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Mot de passe',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmation mot de passe
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // CAPTCHA de sécurité
                CaptchaWidget(
                  onValidationChanged: (isValid) {
                    setState(() {
                      _isCaptchaValid = isValid;
                    });
                  },
                  onRefresh: () {
                    setState(() {
                      _isCaptchaValid = false;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Bouton d'inscription
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'S\'inscrire',
                      onPressed: _isCaptchaValid ? _handleRegister : null,
                      isLoading: authProvider.isLoading,
                      icon: Icons.person_add,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte ?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
