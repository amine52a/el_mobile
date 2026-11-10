import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/database/database_helper.dart';

/// Écran de détails d'un utilisateur avec toutes ses activités
class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserRepository _userRepository = UserRepository();
  User? _user;
  bool _isLoading = true;

  // Statistiques
  int _enrolledCourses = 0;
  int _internshipApplications = 0;
  int _quizAttempts = 0;
  int _forumPosts = 0;
  List<Map<String, dynamic>> _coursesList = [];
  List<Map<String, dynamic>> _internshipsList = [];

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);
    try {
      // Charger l'utilisateur
      final user = await _userRepository.getUserById(widget.userId);
      
      // Charger les statistiques
      final db = await DatabaseHelper.instance.database;

      // Cours inscrits
      final coursesResult = await db.rawQuery('''
        SELECT c.id, c.title, cp.enrolledAt, cp.progressPercentage
        FROM course_progress cp
        JOIN courses c ON cp.courseId = c.id
        WHERE cp.userId = ?
        ORDER BY cp.enrolledAt DESC
      ''', [widget.userId]);

      // Stages postulés
      final internshipsResult = await db.rawQuery('''
        SELECT i.id, i.title, i.company, ia.appliedAt, ia.status
        FROM internship_applications ia
        JOIN internships i ON ia.internshipId = i.id
        WHERE ia.studentId = ?
        ORDER BY ia.appliedAt DESC
      ''', [widget.userId]);

      // Quiz tentés
      final quizResult = await db.query(
        'quiz_attempts',
        where: 'userId = ?',
        whereArgs: [widget.userId],
      );

      // Posts forum
      final postsResult = await db.query(
        'forum_posts',
        where: 'authorId = ?',
        whereArgs: [widget.userId],
      );

      setState(() {
        _user = user;
        _coursesList = coursesResult;
        _internshipsList = internshipsResult;
        _enrolledCourses = coursesResult.length;
        _internshipApplications = internshipsResult.length;
        _quizAttempts = quizResult.length;
        _forumPosts = postsResult.length;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails Utilisateur')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails Utilisateur')),
        body: const Center(child: Text('Utilisateur non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails Utilisateur'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête utilisateur
              _buildUserHeader(),
              const SizedBox(height: 24),

              // Statistiques
              _buildStatisticsSection(),
              const SizedBox(height: 24),

              // Informations personnelles
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),

              // Cours inscrits
              if (_enrolledCourses > 0) ...[
                _buildCoursesSection(),
                const SizedBox(height: 24),
              ],

              // Stages postulés
              if (_internshipApplications > 0) ...[
                _buildInternshipsSection(),
                const SizedBox(height: 24),
              ],

              // Activité
              _buildActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRoleColor(_user!.role),
            _getRoleColor(_user!.role).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              '${_user!.firstName[0]}${_user!.lastName[0]}'.toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _getRoleColor(_user!.role),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_user!.firstName} ${_user!.lastName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user!.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _user!.role,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getRoleColor(_user!.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _user!.isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _user!.isActive ? Icons.check_circle : Icons.cancel,
                            size: 14,
                            color: _user!.isActive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _user!.isActive ? 'Actif' : 'Inactif',
                            style: TextStyle(
                              fontSize: 12,
                              color: _user!.isActive ? Colors.green : Colors.red,
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
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Cours',
                _enrolledCourses.toString(),
                Icons.school,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Stages',
                _internshipApplications.toString(),
                Icons.work,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Quiz',
                _quizAttempts.toString(),
                Icons.quiz,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Posts',
                _forumPosts.toString(),
                Icons.forum,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations Personnelles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.email,
                  'Email',
                  _user!.email,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.person,
                  'Prénom',
                  _user!.firstName,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.person_outline,
                  'Nom',
                  _user!.lastName,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.badge,
                  'Rôle',
                  _user!.role,
                ),
                if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.info,
                    'Bio',
                    _user!.bio!,
                  ),
                ],
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Inscrit le',
                  _formatDate(_user!.createdAt.toIso8601String()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cours Inscrits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$_enrolledCourses cours',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_coursesList.length, (index) {
          final course = _coursesList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.school, color: Colors.blue),
              ),
              title: Text(
                course['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Inscrit le ${_formatDate(course['enrolledAt'])}'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (course['progressPercentage'] ?? 0) / 100,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ],
              ),
              trailing: Text(
                '${course['progressPercentage']?.toInt() ?? 0}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInternshipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stages Postulés',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$_internshipApplications candidatures',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_internshipsList.length, (index) {
          final internship = _internshipsList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: const Icon(Icons.work, color: Colors.orange),
              ),
              title: Text(
                internship['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(internship['company']),
                  Text('Postulé le ${_formatDate(internship['appliedAt'])}'),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(internship['status']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  internship['status'] ?? 'En attente',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(internship['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.quiz, color: Colors.purple),
                title: const Text('Quiz tentés'),
                trailing: Text(
                  _quizAttempts.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.forum, color: Colors.green),
                title: const Text('Posts forum'),
                trailing: Text(
                  _forumPosts.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Accepté':
        return Colors.green;
      case 'Refusé':
        return Colors.red;
      case 'En cours':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
