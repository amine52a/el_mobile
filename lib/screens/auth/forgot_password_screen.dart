import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/message_widgets.dart';

/// Écran de mot de passe oublié (F1.1.2)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _tokenSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _resetToken;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendToken() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = await authProvider.requestPasswordReset(_emailController.text);

    if (token != null && mounted) {
      setState(() {
        _tokenSent = true;
        _resetToken = token;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code de réinitialisation : $token'),
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(
      _emailController.text,
      _tokenController.text,
      _newPasswordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe réinitialisé avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
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
                  Icons.lock_reset,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Réinitialiser le mot de passe',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _tokenSent
                      ? 'Entrez le code reçu et votre nouveau mot de passe'
                      : 'Entrez votre email pour recevoir un code de réinitialisation',
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

                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'votre.email@exemple.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  enabled: !_tokenSent,
                ),
                const SizedBox(height: 16),

                if (!_tokenSent) ...[
                  // Bouton pour envoyer le token
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return CustomButton(
                        text: 'Envoyer le code',
                        onPressed: _handleSendToken,
                        isLoading: authProvider.isLoading,
                        icon: Icons.send,
                      );
                    },
                  ),
                ] else ...[
                  // Afficher le token généré
                  if (_resetToken != null)
                    SuccessMessage(
                      message: 'Code de réinitialisation : $_resetToken',
                    ),
                  const SizedBox(height: 16),

                  // Code de réinitialisation
                  CustomTextField(
                    controller: _tokenController,
                    labelText: 'Code de réinitialisation',
                    prefixIcon: Icons.vpn_key,
                    validator: (value) => Validators.validateRequired(value, 'Le code'),
                  ),
                  const SizedBox(height: 16),

                  // Nouveau mot de passe
                  CustomTextField(
                    controller: _newPasswordController,
                    labelText: 'Nouveau mot de passe',
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
                      _newPasswordController.text,
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

                  // Bouton de réinitialisation
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return CustomButton(
                        text: 'Réinitialiser',
                        onPressed: _handleResetPassword,
                        isLoading: authProvider.isLoading,
                        icon: Icons.check,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bouton pour renvoyer le code
                  CustomButton(
                    text: 'Renvoyer le code',
                    onPressed: () {
                      setState(() {
                        _tokenSent = false;
                        _resetToken = null;
                        _tokenController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      });
                    },
                    isOutlined: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
