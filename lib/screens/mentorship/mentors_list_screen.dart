import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mentorship_provider.dart';
import '../../data/models/mentor_profile.dart';
import 'mentor_profile_screen.dart';

class MentorsListScreen extends StatefulWidget {
  const MentorsListScreen({super.key});

  @override
  State<MentorsListScreen> createState() => _MentorsListScreenState();
}

class _MentorsListScreenState extends State<MentorsListScreen> {
  String _searchQuery = '';
  String? _selectedExpertise;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    final provider = Provider.of<MentorshipProvider>(context, listen: false);
    await provider.loadMentors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver un mentor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un mentor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Liste des mentors
          Expanded(
            child: Consumer<MentorshipProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var mentors = provider.mentors;

                // Filtrer par recherche
                if (_searchQuery.isNotEmpty) {
                  mentors = mentors.where((mentor) {
                    return mentor.bio.toLowerCase().contains(_searchQuery) ||
                        mentor.expertise.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                // Filtrer par expertise
                if (_selectedExpertise != null) {
                  mentors = mentors.where((mentor) {
                    return mentor.expertise == _selectedExpertise;
                  }).toList();
                }

                if (mentors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun mentor trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadMentors,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mentors.length,
                    itemBuilder: (context, index) {
                      final mentor = mentors[index];
                      return _buildMentorCard(mentor);
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

  Widget _buildMentorCard(MentorProfile mentor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MentorProfileScreen(mentor: mentor),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.teal,
                child: Text(
                  mentor.bio.isNotEmpty ? mentor.bio[0].toUpperCase() : 'M',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom (bio utilisé comme nom pour l'instant)
                    Text(
                      mentor.bio.split('\n').first,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Expertise
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        mentor.expertise,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Bio (description courte)
                    Text(
                      mentor.bio,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Note et disponibilité
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          mentor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          mentor.isAvailable ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: mentor.isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mentor.isAvailable ? 'Disponible' : 'Indisponible',
                          style: TextStyle(
                            fontSize: 14,
                            color: mentor.isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Flèche
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par expertise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Tous', null),
            _buildFilterOption('Mathématiques', 'Mathématiques'),
            _buildFilterOption('Sciences', 'Sciences'),
            _buildFilterOption('Langues', 'Langues'),
            _buildFilterOption('Informatique', 'Informatique'),
            _buildFilterOption('Histoire', 'Histoire'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String? expertise) {
    return RadioListTile<String?>(
      title: Text(label),
      value: expertise,
      groupValue: _selectedExpertise,
      onChanged: (value) {
        setState(() {
          _selectedExpertise = value;
        });
        Navigator.pop(context);
      },
    );
  }
}
