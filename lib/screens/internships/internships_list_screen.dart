import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/internship_provider.dart';
import '../../data/models/internship.dart';
import '../../core/constants/app_constants.dart';
import 'internship_detail_screen.dart';

/// F5.1.1 - Liste des offres de stage avec filtrage et recherche
class InternshipsListScreen extends StatefulWidget {
  const InternshipsListScreen({Key? key}) : super(key: key);

  @override
  State<InternshipsListScreen> createState() => _InternshipsListScreenState();
}

class _InternshipsListScreenState extends State<InternshipsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InternshipProvider>().loadInternships();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres de Stage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // F5.1.3 - Barre de recherche
          _buildSearchBar(),
          // F5.1.2 - Chips de filtres actifs
          _buildActiveFilters(),
          // F5.1.1 - Liste des offres
          Expanded(
            child: Consumer<InternshipProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadInternships(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.internships.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune offre de stage disponible',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadInternships(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.internships.length,
                    itemBuilder: (context, index) {
                      final internship = provider.internships[index];
                      return _buildInternshipCard(context, internship);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// F5.1.3 - Barre de recherche
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par titre, entreprise...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<InternshipProvider>().clearFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.length >= 3 || value.isEmpty) {
            context.read<InternshipProvider>().searchInternships(value);
          }
        },
      ),
    );
  }

  /// F5.1.2 - Chips de filtres actifs
  Widget _buildActiveFilters() {
    return Consumer<InternshipProvider>(
      builder: (context, provider, child) {
        final filters = <Widget>[];
        
        if (provider.selectedDomain != null) {
          filters.add(_buildFilterChip(
            label: provider.selectedDomain!,
            onDeleted: () {
              provider.filterInternships(
                location: provider.selectedLocation,
                duration: provider.selectedDuration,
                type: provider.selectedType,
              );
            },
          ));
        }
        
        if (provider.selectedLocation != null) {
          filters.add(_buildFilterChip(
            label: provider.selectedLocation!,
            onDeleted: () {
              provider.filterInternships(
                domain: provider.selectedDomain,
                duration: provider.selectedDuration,
                type: provider.selectedType,
              );
            },
          ));
        }
        
        if (provider.selectedDuration != null) {
          filters.add(_buildFilterChip(
            label: provider.selectedDuration!,
            onDeleted: () {
              provider.filterInternships(
                domain: provider.selectedDomain,
                location: provider.selectedLocation,
                type: provider.selectedType,
              );
            },
          ));
        }
        
        if (provider.selectedType != null) {
          filters.add(_buildFilterChip(
            label: provider.selectedType!,
            onDeleted: () {
              provider.filterInternships(
                domain: provider.selectedDomain,
                location: provider.selectedLocation,
                duration: provider.selectedDuration,
              );
            },
          ));
        }
        
        if (filters.isEmpty) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...filters,
              TextButton.icon(
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Tout effacer'),
                onPressed: () => provider.clearFilters(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }

  /// F5.1.1 - Carte d'offre de stage
  Widget _buildInternshipCard(BuildContext context, Internship internship) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final daysLeft = internship.daysUntilDeadline;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InternshipDetailScreen(internshipId: internship.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec entreprise et type
              Row(
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
                        Text(
                          internship.company,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTypeChip(internship.internshipType),
                ],
              ),
              const SizedBox(height: 12),
              
              // Domaine
              _buildInfoRow(Icons.category, internship.domain),
              const SizedBox(height: 8),
              
              // Localisation
              _buildInfoRow(Icons.location_on, internship.location),
              const SizedBox(height: 8),
              
              // Durée
              _buildInfoRow(Icons.schedule, internship.duration),
              const SizedBox(height: 12),
              
              // Date limite et statut
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: daysLeft <= 7 ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Date limite: ${dateFormat.format(internship.applicationDeadline)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: daysLeft <= 7 ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (daysLeft > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: daysLeft <= 7 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$daysLeft ${daysLeft == 1 ? 'jour' : 'jours'} restant${daysLeft == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: daysLeft <= 7 ? Colors.red : Colors.green,
                        ),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type) {
      case 'Obligatoire':
        color = Colors.red;
        break;
      case 'Final':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// F5.1.2 - Dialogue de filtrage
  void _showFilterDialog(BuildContext context) {
    final provider = context.read<InternshipProvider>();
    
    String? selectedDomain = provider.selectedDomain;
    String? selectedLocation = provider.selectedLocation;
    String? selectedDuration = provider.selectedDuration;
    String? selectedType = provider.selectedType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtrer les offres'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Domaine
                const Text('Domaine', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedDomain,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sélectionner un domaine',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous')),
                    ...AppConstants.internshipDomains.map((domain) {
                      return DropdownMenuItem(value: domain, child: Text(domain));
                    }),
                  ],
                  onChanged: (value) => setState(() => selectedDomain = value),
                ),
                const SizedBox(height: 16),
                
                // Localisation
                const Text('Localisation', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: selectedLocation,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ville, région...',
                  ),
                  onChanged: (value) => selectedLocation = value.isEmpty ? null : value,
                ),
                const SizedBox(height: 16),
                
                // Durée
                const Text('Durée', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedDuration,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sélectionner une durée',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Toutes')),
                    DropdownMenuItem(value: '1 mois', child: Text('1 mois')),
                    DropdownMenuItem(value: '2 mois', child: Text('2 mois')),
                    DropdownMenuItem(value: '3 mois', child: Text('3 mois')),
                    DropdownMenuItem(value: '6 mois', child: Text('6 mois')),
                  ],
                  onChanged: (value) => setState(() => selectedDuration = value),
                ),
                const SizedBox(height: 16),
                
                // Type
                const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sélectionner un type',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous')),
                    ...AppConstants.internshipTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }),
                  ],
                  onChanged: (value) => setState(() => selectedType = value),
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
              onPressed: () {
                provider.filterInternships(
                  domain: selectedDomain,
                  location: selectedLocation,
                  duration: selectedDuration,
                  type: selectedType,
                );
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }
}
