import 'package:flutter/material.dart';

class WebNotSupportedScreen extends StatelessWidget {
  const WebNotSupportedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 120,
                color: Colors.green,
              ),
              const SizedBox(height: 32),
              Text(
                'EduPalestine',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Application Mobile d\'Apprentissage et de Mentorat',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Version Web Non Disponible',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cette application utilise SQLite qui n\'est pas compatible avec les navigateurs web.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Pour utiliser l\'application:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPlatformOption(
                      icon: Icons.computer,
                      title: 'Windows Desktop',
                      description: 'Exécutez: flutter run -d windows',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildPlatformOption(
                      icon: Icons.phone_android,
                      title: 'Android',
                      description: 'Exécutez: flutter run -d android',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildPlatformOption(
                      icon: Icons.phone_iphone,
                      title: 'iOS',
                      description: 'Exécutez: flutter run -d ios',
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '📚 Fonctionnalités disponibles:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureChip('Authentification', Icons.login),
                  _buildFeatureChip('Cours & Chapitres', Icons.book),
                  _buildFeatureChip('Quiz', Icons.quiz),
                  _buildFeatureChip('Forum', Icons.forum),
                  _buildFeatureChip('Messagerie', Icons.message),
                  _buildFeatureChip('Mentorat', Icons.people),
                  _buildFeatureChip('Stages', Icons.work),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildPlatformOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.green.shade50,
      side: BorderSide(color: Colors.green.shade200),
    );
  }
}
