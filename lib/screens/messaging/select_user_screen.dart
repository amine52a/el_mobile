import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/messaging_repository.dart';
import 'chat_screen.dart';

/// Écran de sélection d'utilisateur pour démarrer une nouvelle conversation
class SelectUserScreen extends StatefulWidget {
  const SelectUserScreen({super.key});

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  final UserRepository _userRepository = UserRepository();
  final MessagingRepository _messagingRepository = MessagingRepository();
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser == null) return;

      final allUsers = await _userRepository.getAllUsers();
      
      // Exclure l'utilisateur actuel de la liste
      setState(() {
        _users = allUsers.where((user) => user.id != currentUser.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des utilisateurs: $e')),
        );
      }
    }
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    
    return _users.where((user) {
      final fullName = user.fullName.toLowerCase();
      final email = user.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _startConversation(User selectedUser) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    try {
      // Vérifier si une conversation existe déjà ou en créer une nouvelle
      final conversationId = await _messagingRepository.getOrCreateConversation(
        currentUser.id,
        selectedUser.id,
      );

      // Récupérer la conversation créée/existante
      final conversation = await _messagingRepository.getConversationById(conversationId);
      
      if (conversation != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversation: conversation,
              otherUserName: selectedUser.fullName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création de la conversation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle conversation'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Aucun utilisateur disponible'
                            : 'Aucun résultat trouvé',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _filteredUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _startConversation(user),
                    );
                  },
                ),
    );
  }
}
