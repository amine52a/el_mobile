import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../../providers/auth_provider.dart';
import 'user_detail_screen.dart';
import 'edit_user_screen.dart';

/// Écran de gestion des utilisateurs (Admin)
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final UserRepository _userRepository = UserRepository();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedRoleFilter = 'Tous';
  String _searchQuery = '';

  final List<String> _roleFilters = [
    'Tous',
    'Étudiant',
    'Mentor',
    'Administrateur',
    'Recruteur',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userRepository.getAllUsers();
      setState(() {
        _users = users;
        _applyFilters();
        _isLoading = false;
      });
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

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      // Filtre par rôle
      if (_selectedRoleFilter != 'Tous' && user.role != _selectedRoleFilter) {
        return false;
      }

      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return user.email.toLowerCase().contains(query) ||
            user.firstName.toLowerCase().contains(query) ||
            user.lastName.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      await _userRepository.updateUser(
        user.copyWith(isActive: !user.isActive),
      );
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive
                  ? 'Utilisateur désactivé'
                  : 'Utilisateur activé',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
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

  Future<void> _deleteUser(User user) async {
    // Empêcher la suppression de son propre compte
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser?.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez pas supprimer votre propre compte'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.firstName} ${user.lastName}" ?\n\nCette action est irréversible.',
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

    if (confirmed == true) {
      try {
        await _userRepository.hardDeleteUser(user.id);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilisateur supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques
          _buildStatisticsCard(),

          // Filtres et recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom ou email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filtre par rôle
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roleFilters.map((role) {
                      final isSelected = _selectedRoleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(role),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRoleFilter = role;
                              _applyFilters();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Liste des utilisateurs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun utilisateur trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u.isActive).length;
    final studentCount = _users.where((u) => u.role == 'Étudiant').length;
    final mentorCount = _users.where((u) => u.role == 'Mentor').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              totalUsers.toString(),
              Icons.people,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: _buildStatItem(
              'Actifs',
              activeUsers.toString(),
              Icons.check_circle,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: _buildStatItem(
              'Étudiants',
              studentCount.toString(),
              Icons.school,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: _buildStatItem(
              'Mentors',
              mentorCount.toString(),
              Icons.support_agent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final isCurrentUser = currentUser?.id == user.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(userId: user.id),
            ),
          );
          _loadUsers();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                child: Text(
                  '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getRoleColor(user.role),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Vous',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Badge rôle
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getRoleColor(user.role),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Badge statut
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user.isActive
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user.isActive ? Icons.check_circle : Icons.cancel,
                                size: 12,
                                color: user.isActive ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.isActive ? 'Actif' : 'Inactif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: user.isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
                    case 'view':
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailScreen(userId: user.id),
                        ),
                      );
                      _loadUsers();
                      break;
                    case 'edit':
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditUserScreen(user: user),
                        ),
                      );
                      _loadUsers();
                      break;
                    case 'toggle':
                      _toggleUserStatus(user);
                      break;
                    case 'delete':
                      _deleteUser(user);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 8),
                        Text('Voir les détails'),
                      ],
                    ),
                  ),
                  if (!isCurrentUser)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                  if (!isCurrentUser)
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.block : Icons.check_circle,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'Désactiver' : 'Activer'),
                        ],
                      ),
                    ),
                  if (!isCurrentUser)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
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
}
