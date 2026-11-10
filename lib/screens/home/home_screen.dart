import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../courses/courses_list_screen.dart';
import '../forum/forum_list_screen.dart';
import '../messaging/conversations_list_screen.dart';
import '../mentorship/mentors_list_screen.dart';
import '../mentorship/my_sessions_screen.dart';
import '../internships/internships_list_screen.dart';
import '../internships/manage_internships_screen.dart';
import '../admin/users_management_screen.dart';

/// Écran d'accueil principal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardScreen(),
    const CoursesListScreen(), // Module 2: Cours
    const _CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Communauté',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Écran du tableau de bord
class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduPalestine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('Aucun utilisateur connecté'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête de bienvenue
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            user.firstName[0] + user.lastName[0],
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenue,',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                user.fullName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.role,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section Statistiques
                Text(
                  'Tableau de bord',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.book,
                        title: 'Cours',
                        value: '12',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.quiz,
                        title: 'Quiz',
                        value: '24',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.work,
                        title: 'Stages',
                        value: '5',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people,
                        title: 'Mentors',
                        value: '8',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section Actions rapides
                Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _QuickActionCard(
                  icon: Icons.person,
                  title: 'Voir mon profil',
                  subtitle: 'Modifier vos informations personnelles',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.lock,
                  title: 'Changer le mot de passe',
                  subtitle: 'Sécurisez votre compte',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.school,
                  title: 'Parcourir les cours',
                  subtitle: 'Découvrez de nouveaux contenus',
                  onTap: () {
                    // À implémenter
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.work,
                  title: 'Offres de Stage',
                  subtitle: 'Consultez et postulez aux stages disponibles',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InternshipsListScreen()),
                    );
                  },
                ),
                // Accès admin/recruteur uniquement
                if (user.role.toLowerCase() == 'admin' || 
                    user.role.toLowerCase() == 'administrateur' || 
                    user.role.toLowerCase() == 'recruteur')
                  _QuickActionCard(
                    icon: Icons.admin_panel_settings,
                    title: 'Gérer les Offres',
                    subtitle: 'Créer, modifier et supprimer des offres de stage',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ManageInternshipsScreen()),
                      );
                    },
                  ),
                // Gestion des utilisateurs (Admin uniquement)
                if (user.role.toLowerCase() == 'admin' || 
                    user.role.toLowerCase() == 'administrateur')
                  _QuickActionCard(
                    icon: Icons.people,
                    title: 'Gérer les Utilisateurs',
                    subtitle: 'Voir, modifier et gérer tous les utilisateurs',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UsersManagementScreen()),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget pour les cartes de statistiques
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour les cartes d'action rapide
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Écran de la communauté (placeholder)
class _CommunityScreen extends StatefulWidget {
  const _CommunityScreen();

  @override
  State<_CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<_CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communauté'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.forum), text: 'Forum'),
            Tab(icon: Icon(Icons.message), text: 'Messages'),
            Tab(icon: Icon(Icons.school), text: 'Mentorat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Forum Tab
          _ForumTabScreen(),
          
          // Messagerie Tab
          _MessagingTabScreen(),
          
          // Mentorat Tab
          _MentorshipTabScreen(),
        ],
      ),
    );
  }
}

// Onglet Forum
class _ForumTabScreen extends StatelessWidget {
  const _ForumTabScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.forum, color: Colors.blue),
            title: const Text('Forum général'),
            subtitle: const Text('Discutez de tous les sujets'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForumListScreen(
                    courseId: 0, // 0 = forum général
                    courseTitle: 'Forum général',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forums par cours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accédez aux forums depuis la page de chaque cours',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Onglet Messagerie
class _MessagingTabScreen extends StatelessWidget {
  const _MessagingTabScreen();

  @override
  Widget build(BuildContext context) {
    return const ConversationsListScreen();
  }
}

// Onglet Mentorat
class _MentorshipTabScreen extends StatelessWidget {
  const _MentorshipTabScreen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête
          const Text(
            'Mentorat',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Trouvez un mentor ou consultez vos sessions',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Bouton Trouver un mentor
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MentorsListScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search,
                        size: 32,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trouver un mentor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Parcourir les mentors disponibles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bouton Mes sessions
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MySessionsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 32,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mes sessions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gérer mes sessions de mentorat',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
