import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/mentorship_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/mentorship_session.dart';

class MySessionsScreen extends StatefulWidget {
  const MySessionsScreen({super.key});

  @override
  State<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends State<MySessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mentorshipProvider = Provider.of<MentorshipProvider>(context, listen: false);
    
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      await mentorshipProvider.loadUserSessions(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes sessions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En attente', icon: Icon(Icons.hourglass_empty, size: 20)),
            Tab(text: 'À venir', icon: Icon(Icons.schedule, size: 20)),
            Tab(text: 'Terminées', icon: Icon(Icons.check_circle, size: 20)),
          ],
        ),
      ),
      body: Consumer<MentorshipProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSessionsList(provider.sessions.where((s) => s.status == 'pending').toList(), 'pending'),
              _buildSessionsList(provider.sessions.where((s) => s.status == 'scheduled').toList(), 'scheduled'),
              _buildSessionsList(provider.sessions.where((s) => s.status == 'completed').toList(), 'completed'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionsList(List<MentorshipSession> sessions, String status) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(status),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(MentorshipSession session) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    session.topic,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(session.status),
              ],
            ),
            const SizedBox(height: 12),

            // Date et heure
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(session.scheduledTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Durée
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${session.durationMinutes} minutes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            // Notes si présentes
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions selon le statut
            if (session.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelSession(session),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'En attente';
        icon = Icons.hourglass_empty;
        break;
      case 'scheduled':
        color = Colors.blue;
        label = 'Confirmée';
        icon = Icons.check_circle;
        break;
      case 'completed':
        color = Colors.green;
        label = 'Terminée';
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulée';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'scheduled':
        return Icons.event_available;
      case 'completed':
        return Icons.history_edu;
      default:
        return Icons.inbox;
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Aucune session en attente';
      case 'scheduled':
        return 'Aucune session à venir';
      case 'completed':
        return 'Aucune session terminée';
      default:
        return 'Aucune session';
    }
  }

  Future<void> _cancelSession(MentorshipSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la session'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette session ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<MentorshipProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        final success = await provider.cancelSession(session.id!, currentUser.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '✅ Session annulée' : '❌ Erreur'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    }
  }
}
