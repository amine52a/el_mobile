import '../database/database_helper.dart';
import '../../core/constants/app_constants.dart';

/// Helper class to seed Module 4 data (Forum, Messaging, Mentorship)
class Module4SeedHelper {
  static final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Seed Module 4 data if needed
  static Future<void> seedIfNeeded() async {
    try {
      // Check if we already have forum posts
      final db = await _dbHelper.database;
      final existingPosts = await db.query(AppConstants.tableForumPosts, limit: 1);
      
      if (existingPosts.isEmpty) {
        print('📝 Création des données de test pour le Module 4...');
        await _seedForumPosts();
        await _seedMentorProfiles();
        print('✅ Données Module 4 créées avec succès');
      }
    } catch (e) {
      print('❌ Erreur lors de la création des données Module 4: $e');
    }
  }

  /// Seed forum posts and comments
  static Future<void> _seedForumPosts() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    // Get user IDs (assuming test users exist)
    final users = await db.query(AppConstants.usersTable, limit: 3);
    if (users.isEmpty) return;

    final user1Id = users[0]['id'] as String;
    final user1Name = (users[0]['name'] as String?) ?? 'User 1';
    
    final user2Id = users.length > 1 ? users[1]['id'] as String : user1Id;
    final user2Name = users.length > 1 ? (users[1]['name'] as String?) ?? 'User 2' : user1Name;
    
    final user3Id = users.length > 2 ? users[2]['id'] as String : user1Id;
    final user3Name = users.length > 2 ? (users[2]['name'] as String?) ?? 'User 3' : user1Name;

    // Get course IDs
    final courses = await db.query(AppConstants.coursesTable, limit: 2);
    if (courses.isEmpty) return;

    final courseId1 = courses[0]['id'] as int;
    final courseId2 = courses.length > 1 ? courses[1]['id'] as int : courseId1;

    // Seed Forum Posts
    final posts = [
      {
        'authorId': user1Id,
        'authorName': user1Name,
        'courseId': courseId1,
        'chapterId': null,
        'title': 'Comment aborder le premier chapitre ?',
        'content':
            'Bonjour à tous ! Je débute dans ce cours et j\'aimerais avoir vos conseils pour bien comprendre le premier chapitre. Quelles sont les parties les plus importantes à retenir ?',
        'tags': 'débutant,conseil,chapitre1',
        'likesCount': 5,
        'commentsCount': 3,
        'isPinned': 0,
        'isSolved': 1,
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'updatedAt': null,
      },
      {
        'authorId': user2Id,
        'authorName': user2Name,
        'courseId': courseId1,
        'chapterId': null,
        'title': 'Ressources supplémentaires recommandées',
        'content':
            'Salut ! Connaissez-vous de bonnes ressources (livres, vidéos, sites web) pour approfondir les concepts de ce cours ? Je cherche à aller plus loin.',
        'tags': 'ressources,approfondissement',
        'likesCount': 8,
        'commentsCount': 5,
        'isPinned': 1,
        'isSolved': 0,
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updatedAt': null,
      },
      {
        'authorId': user3Id,
        'authorName': user3Name,
        'courseId': courseId1,
        'chapterId': null,
        'title': 'Erreur dans l\'exercice 3',
        'content':
            'J\'ai trouvé ce qui semble être une erreur dans l\'énoncé de l\'exercice 3. Quelqu\'un d\'autre a remarqué ça ? Ou bien je me trompe ?',
        'tags': 'exercice,erreur,question',
        'likesCount': 2,
        'commentsCount': 1,
        'isPinned': 0,
        'isSolved': 0,
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': null,
      },
      {
        'authorId': user1Id,
        'authorName': user1Name,
        'courseId': courseId2,
        'chapterId': null,
        'title': 'Groupe d\'étude - Qui est intéressé ?',
        'content':
            'Hello ! Je cherche à former un groupe d\'étude pour ce cours. On pourrait se retrouver une fois par semaine pour réviser ensemble. Intéressés ?',
        'tags': 'groupe,étude,collaboration',
        'likesCount': 12,
        'commentsCount': 7,
        'isPinned': 0,
        'isSolved': 0,
        'createdAt': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'updatedAt': null,
      },
    ];

    for (var post in posts) {
      await db.insert(AppConstants.tableForumPosts, post);
    }

    // Seed Forum Comments
    final comments = [
      {
        'postId': 1,
        'authorId': user2Id,
        'authorName': user2Name,
        'content':
            'Concentre-toi surtout sur les définitions de base et les exemples. Le reste viendra naturellement avec la pratique !',
        'likesCount': 3,
        'isAccepted': 1,
        'createdAt':
            now.subtract(const Duration(days: 4, hours: 12)).toIso8601String(),
        'updatedAt': null,
      },
      {
        'postId': 1,
        'authorId': user3Id,
        'authorName': user3Name,
        'content':
            'Je te conseille aussi de faire les exercices au fur et à mesure. Ne laisse pas s\'accumuler !',
        'likesCount': 2,
        'isAccepted': 0,
        'createdAt':
            now.subtract(const Duration(days: 4, hours: 6)).toIso8601String(),
        'updatedAt': null,
      },
      {
        'postId': 2,
        'authorId': user1Id,
        'authorName': user1Name,
        'content':
            'Il y a un excellent livre que je recommande: "Introduction aux concepts avancés". Très bien expliqué.',
        'likesCount': 5,
        'isAccepted': 0,
        'createdAt':
            now.subtract(const Duration(days: 2, hours: 18)).toIso8601String(),
        'updatedAt': null,
      },
      {
        'postId': 2,
        'authorId': user3Id,
        'authorName': user3Name,
        'content':
            'La chaîne YouTube "EduTech Pro" a de super vidéos sur ce sujet. Ça vaut le coup de regarder !',
        'likesCount': 4,
        'isAccepted': 0,
        'createdAt':
            now.subtract(const Duration(days: 2, hours: 12)).toIso8601String(),
        'updatedAt': null,
      },
    ];

    for (var comment in comments) {
      await db.insert(AppConstants.tableForumComments, comment);
    }

    print('  ✅ Posts et commentaires de forum créés');
  }

  /// Seed mentor profiles
  static Future<void> _seedMentorProfiles() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    // Get user IDs
    final users = await db.query(AppConstants.usersTable);
    if (users.length < 2) return;

    final user1Id = users[0]['id'] as String;
    final user2Id = users[1]['id'] as String;

    // Seed Mentor Profiles
    final mentorProfiles = [
      {
        'userId': user1Id,
        'expertise': 'Mathématiques & Physique',
        'bio':
            'Professeur de mathématiques depuis 10 ans. Passionné par l\'enseignement et l\'accompagnement des élèves. Disponible pour des sessions de mentorat en mathématiques, physique et sciences.',
        'languages': 'Français,Arabe,Anglais',
        'availableDays': 'Lundi,Mercredi,Vendredi',
        'availableTimeSlot': '14:00-18:00',
        'totalStudents': 15,
        'rating': 4.8,
        'totalSessions': 42,
        'isAvailable': 1,
        'createdAt': now.subtract(const Duration(days: 90)).toIso8601String(),
        'updatedAt': null,
      },
      {
        'userId': user2Id,
        'expertise': 'Informatique & Programmation',
        'bio':
            'Développeur full-stack avec 8 ans d\'expérience. J\'aide les débutants à apprendre la programmation (Python, JavaScript, Flutter). Mentorat personnalisé selon vos objectifs.',
        'languages': 'Français,Anglais',
        'availableDays': 'Mardi,Jeudi,Samedi',
        'availableTimeSlot': '16:00-20:00',
        'totalStudents': 22,
        'rating': 4.9,
        'totalSessions': 67,
        'isAvailable': 1,
        'createdAt': now.subtract(const Duration(days: 120)).toIso8601String(),
        'updatedAt': null,
      },
    ];

    for (var profile in mentorProfiles) {
      await db.insert(AppConstants.tableMentorProfiles, profile);
    }

    print('  ✅ Profils de mentors créés');
  }
}
