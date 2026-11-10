import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/internship_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/internship.dart';
import '../../data/repositories/internship_repository.dart';

/// F5.1.4 - Écran de détail d'une offre de stage avec candidature
class InternshipDetailScreen extends StatefulWidget {
  final String internshipId;

  const InternshipDetailScreen({
    Key? key,
    required this.internshipId,
  }) : super(key: key);

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  final InternshipRepository _repository = InternshipRepository();
  Internship? _internship;
  bool _isLoading = true;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _loadInternship();
  }

  Future<void> _loadInternship() async {
    setState(() => _isLoading = true);
    
    try {
      final internship = await _repository.getInternshipById(widget.internshipId);
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;
      
      bool applied = false;
      if (userId != null) {
        applied = await _repository.hasApplied(widget.internshipId, userId);
      }
      
      setState(() {
        _internship = internship;
        _hasApplied = applied;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_internship == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Offre introuvable')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanySection(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  _buildSkillsSection(),
                  const SizedBox(height: 24),
                  _buildDatesSection(),
                  const SizedBox(height: 100), // Espace pour le bouton flottant
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildApplyButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _internship!.title,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.work,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.business,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _internship!.company,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _internship!.location,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(Icons.category, 'Domaine', _internship!.domain),
        const SizedBox(height: 8),
        _buildInfoCard(Icons.schedule, 'Durée', _internship!.duration),
        const SizedBox(height: 8),
        _buildInfoCard(
          Icons.label,
          'Type',
          _internship!.internshipType,
          color: _getTypeColor(_internship!.internshipType),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color ?? Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _internship!.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    if (_internship!.requiredSkills.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compétences requises',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _internship!.requiredSkills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              avatar: Icon(
                Icons.check_circle,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final daysLeft = _internship!.daysUntilDeadline;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dates importantes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDateRow(
                  Icons.event_available,
                  'Début du stage',
                  dateFormat.format(_internship!.startDate),
                ),
                const Divider(height: 24),
                _buildDateRow(
                  Icons.event_busy,
                  'Fin du stage',
                  dateFormat.format(_internship!.endDate),
                ),
                const Divider(height: 24),
                _buildDateRow(
                  Icons.alarm,
                  'Date limite de candidature',
                  dateFormat.format(_internship!.applicationDeadline),
                  subtitle: daysLeft > 0
                      ? '$daysLeft ${daysLeft == 1 ? 'jour restant' : 'jours restants'}'
                      : 'Expirée',
                  subtitleColor: daysLeft > 0 && daysLeft <= 7 ? Colors.red : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(IconData icon, String label, String value, {String? subtitle, Color? subtitleColor}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor ?? Colors.grey[600],
                    fontWeight: subtitleColor != null ? FontWeight.bold : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// F5.1.5 - Bouton de candidature
  Widget? _buildApplyButton() {
    if (!_internship!.isAvailable) {
      return null; // Pas de bouton si l'offre n'est plus disponible
    }

    if (_hasApplied) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle),
          label: const Text('Candidature envoyée'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _showApplicationDialog(),
        icon: const Icon(Icons.send),
        label: const Text('Postuler'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// F5.1.5 - Dialogue de candidature
  void _showApplicationDialog() {
    final TextEditingController coverLetterController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Postuler à l\'offre'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vous postulez pour: ${_internship!.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coverLetterController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Lettre de motivation (optionnel)',
                  hintText: 'Expliquez pourquoi vous êtes intéressé par cette offre...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _submitApplication(coverLetterController.text),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  /// F5.1.5 - Soumettre la candidature
  Future<void> _submitApplication(String coverLetter) async {
    Navigator.pop(context); // Fermer le dialogue

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour postuler')),
      );
      return;
    }

    final provider = context.read<InternshipProvider>();
    final success = await provider.applyToInternship(
      internshipId: _internship!.id,
      studentId: userId,
      coverLetter: coverLetter.isNotEmpty ? coverLetter : null,
    );

    if (mounted) {
      if (success) {
        setState(() => _hasApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur lors de la candidature'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Obligatoire':
        return Colors.red;
      case 'Final':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
