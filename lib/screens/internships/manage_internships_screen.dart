import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/internship.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import 'create_internship_screen.dart';
import 'edit_internship_screen.dart';
import 'internship_detail_screen.dart';

/// Écran de gestion des offres de stage (Admin/Recruteur)
/// Liste avec actions CRUD (F5.2.1, F5.2.2, F5.2.3)
class ManageInternshipsScreen extends StatefulWidget {
  const ManageInternshipsScreen({Key? key}) : super(key: key);

  @override
  State<ManageInternshipsScreen> createState() => _ManageInternshipsScreenState();
}

class _ManageInternshipsScreenState extends State<ManageInternshipsScreen> {
  bool _showOnlyMine = false;

  @override
  void initState() {
    super.initState();
    _loadInternships();
  }

  Future<void> _loadInternships() async {
    final internshipProvider = Provider.of<InternshipProvider>(context, listen: false);
    await internshipProvider.loadInternships();
  }

  List<Internship> _filterInternships(List<Internship> internships) {
    if (!_showOnlyMine) {
      return internships;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? '';
    
    return internships.where((internship) {
      return internship.recruiterId == currentUserId;
    }).toList();
  }

  Future<void> _deleteInternship(Internship internship) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'offre'),
        content: Text(
          'Voulez-vous vraiment supprimer définitivement l\'offre "${internship.title}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final internshipProvider = Provider.of<InternshipProvider>(context, listen: false);
        await internshipProvider.deleteInternship(internship.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Offre supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
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
      }
    }
  }

  Future<void> _toggleActiveStatus(Internship internship) async {
    try {
      final internshipProvider = Provider.of<InternshipProvider>(context, listen: false);
      final updatedInternship = internship.copyWith(isActive: !internship.isActive);
      await internshipProvider.updateInternship(updatedInternship);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              internship.isActive 
                  ? '✅ Offre désactivée' 
                  : '✅ Offre réactivée',
            ),
            backgroundColor: Colors.green,
          ),
        );
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
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Stage Obligatoire':
        return Colors.red;
      case 'Stage de Fin d\'Études':
        return Colors.blue;
      case 'Stage Optionnel':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les Offres'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInternships,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInternshipScreen(),
            ),
          );
          if (result == true) {
            _loadInternships();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Créer une offre'),
        backgroundColor: Colors.teal,
      ),
      body: Consumer<InternshipProvider>(
        builder: (context, internshipProvider, child) {
          if (internshipProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (internshipProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${internshipProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInternships,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final allInternships = internshipProvider.internships;
          final filteredInternships = _filterInternships(allInternships);

          return Column(
            children: [
              // En-tête avec statistiques
              Container(
                color: Colors.teal,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          allInternships.length.toString(),
                          Icons.work,
                          Colors.white,
                        ),
                        _buildStatCard(
                          'Actives',
                          allInternships.where((i) => i.isActive).length.toString(),
                          Icons.check_circle,
                          Colors.green.shade300,
                        ),
                        _buildStatCard(
                          'Inactives',
                          allInternships.where((i) => !i.isActive).length.toString(),
                          Icons.cancel,
                          Colors.red.shade300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filtre "Mes offres seulement"
                    if (!isAdmin)
                      SwitchListTile(
                        title: const Text(
                          'Afficher seulement mes offres',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: _showOnlyMine,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyMine = value;
                          });
                        },
                        activeColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),

              // Liste des offres
              Expanded(
                child: filteredInternships.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showOnlyMine 
                                  ? 'Vous n\'avez créé aucune offre'
                                  : 'Aucune offre de stage',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInternships,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredInternships.length,
                          itemBuilder: (context, index) {
                            final internship = filteredInternships[index];
                            return _buildInternshipCard(internship);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildInternshipCard(Internship internship) {
    final daysRemaining = internship.daysUntilDeadline;
    final isUrgent = daysRemaining <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec badge de statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: internship.isActive ? Colors.teal.shade50 : Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        internship.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            internship.company,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    internship.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: internship.isActive ? Colors.green.shade100 : Colors.red.shade100,
                  labelStyle: TextStyle(
                    color: internship.isActive ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),

          // Informations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(internship.domain),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(internship.internshipType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        internship.internshipType,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTypeColor(internship.internshipType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(internship.location),
                    const Spacer(),
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(internship.duration),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isUrgent ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Date limite: ${internship.applicationDeadline.day}/${internship.applicationDeadline.month}/${internship.applicationDeadline.year}',
                      style: TextStyle(
                        color: isUrgent ? Colors.red : Colors.grey.shade800,
                        fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'URGENT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Voir
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InternshipDetailScreen(
                            internshipId: internship.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Voir'),
                  ),
                ),
                // Modifier
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditInternshipScreen(
                            internship: internship,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadInternships();
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                ),
                // Activer/Désactiver
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _toggleActiveStatus(internship),
                    icon: Icon(internship.isActive ? Icons.block : Icons.check_circle),
                    label: Text(internship.isActive ? 'Désactiver' : 'Activer'),
                    style: TextButton.styleFrom(
                      foregroundColor: internship.isActive ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                // Supprimer
                IconButton(
                  onPressed: () => _deleteInternship(internship),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
