import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/mentor_profile.dart';
import '../../providers/mentorship_provider.dart';
import '../../providers/auth_provider.dart';

class MentorProfileScreen extends StatelessWidget {
  final MentorProfile mentor;

  const MentorProfileScreen({
    super.key,
    required this.mentor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar avec image de fond
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                mentor.bio.split('\n').first,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.teal[700]!,
                      Colors.teal[400]!,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expertise et disponibilité
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.school,
                          label: 'Expertise',
                          value: mentor.expertise,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: mentor.isAvailable ? Icons.check_circle : Icons.cancel,
                          label: 'Statut',
                          value: mentor.isAvailable ? 'Disponible' : 'Indisponible',
                          color: mentor.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Note
                  _buildRatingSection(),
                  const SizedBox(height: 24),

                  // Bio
                  _buildSectionTitle('À propos'),
                  const SizedBox(height: 8),
                  Text(
                    mentor.bio,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistiques
                  _buildSectionTitle('Statistiques'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people,
                          label: 'Étudiants',
                          value: mentor.totalStudents.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.school,
                          label: 'Sessions',
                          value: mentor.totalSessions.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Disponibilités
                  if (mentor.availableDays.isNotEmpty) ...[
                    _buildSectionTitle('Disponibilités'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: mentor.availableDays.map((day) {
                        return Chip(
                          label: Text(day),
                          backgroundColor: Colors.teal[50],
                          labelStyle: TextStyle(color: Colors.teal[700]),
                        );
                      }).toList(),
                    ),
                    if (mentor.availableTimeSlot != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Créneaux: ${mentor.availableTimeSlot}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],

                  // Langues
                  if (mentor.languages.isNotEmpty) ...[
                    _buildSectionTitle('Langues'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: mentor.languages.map((lang) {
                        return Chip(
                          label: Text(lang),
                          avatar: const Icon(Icons.language, size: 16),
                          backgroundColor: Colors.blue[50],
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bouton de demande de session
                  if (mentor.isAvailable) _buildRequestButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[50]!, Colors.orange[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.amber[700], size: 32),
          const SizedBox(width: 8),
          Text(
            mentor.rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '/ 5.0',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _requestSession(context),
        icon: const Icon(Icons.calendar_today),
        label: const Text(
          'Demander une session',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _requestSession(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mentorshipProvider = Provider.of<MentorshipProvider>(context, listen: false);
    
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    // Afficher dialogue pour saisir le sujet et message
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _RequestDialog(mentorExpertise: mentor.expertise),
    );

    if (result == null) return;

    // Créer la demande
    final requestId = await mentorshipProvider.createRequest(
      studentId: currentUser.id,
      mentorId: mentor.userId,
      topic: result['topic']!,
      message: result['message']!,
    );

    if (context.mounted) {
      if (requestId != null && requestId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande de session envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mentorshipProvider.error ?? '❌ Erreur lors de la demande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _RequestDialog extends StatefulWidget {
  final String mentorExpertise;

  const _RequestDialog({required this.mentorExpertise});

  @override
  State<_RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  final _topicController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _topicController.text = 'Session de ${widget.mentorExpertise}';
  }

  @override
  void dispose() {
    _topicController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Demande de mentorat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _topicController,
            decoration: const InputDecoration(
              labelText: 'Sujet',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message au mentor',
              hintText: 'Décrivez ce que vous aimeriez apprendre...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_topicController.text.isNotEmpty &&
                _messageController.text.isNotEmpty) {
              Navigator.pop(context, {
                'topic': _topicController.text,
                'message': _messageController.text,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez remplir tous les champs')),
              );
            }
          },
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}
