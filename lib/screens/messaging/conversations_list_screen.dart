import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/auth_provider.dart';
import 'chat_screen.dart';
import 'select_user_screen.dart';
import 'package:intl/intl.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<MessagingProvider>(context, listen: false)
            .loadConversations(authProvider.currentUser!.id);
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(timestamp);
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final messagingProvider = Provider.of<MessagingProvider>(context);

    if (authProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messagerie'),
        ),
        body: const Center(
          child: Text('Vous devez être connecté pour accéder à la messagerie'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: messagingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : messagingProvider.conversationsWithNames.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune conversation',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Commencez une nouvelle conversation',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await messagingProvider.loadConversations(
                      authProvider.currentUser!.id,
                    );
                  },
                  child: ListView.separated(
                    itemCount: messagingProvider.conversationsWithNames.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversationWithNames = messagingProvider.conversationsWithNames[index];
                      final currentUserId = authProvider.currentUser!.id;
                      
                      // Déterminer l'autre participant
                      final otherUserName = conversationWithNames.getOtherParticipantName(currentUserId);
                      
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            otherUserName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                otherUserName,
                                style: TextStyle(
                                  fontWeight: conversationWithNames.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conversationWithNames.lastMessageTime != null)
                              Text(
                                _formatTimestamp(conversationWithNames.lastMessageTime!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: conversationWithNames.unreadCount > 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[600],
                                  fontWeight: conversationWithNames.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversationWithNames.lastMessage ?? 'Aucun message',
                                style: TextStyle(
                                  color: conversationWithNames.unreadCount > 0
                                      ? Colors.black87
                                      : Colors.grey[600],
                                  fontWeight: conversationWithNames.unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conversationWithNames.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  conversationWithNames.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversation: conversationWithNames.conversation,
                                otherUserName: otherUserName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SelectUserScreen(),
            ),
          );
        },
        child: const Icon(Icons.edit),
        tooltip: 'Nouvelle conversation',
      ),
    );
  }
}
