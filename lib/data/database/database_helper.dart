import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

/// Gestionnaire de la base de données SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Getter pour obtenir la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  /// Initialise la base de données
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Crée les tables de la base de données
  Future<void> _createDB(Database db, int version) async {
    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        role TEXT NOT NULL,
        bio TEXT,
        photo TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        resetToken TEXT,
        resetTokenExpiry TEXT
      )
    ''');

    // Index pour améliorer les performances de recherche
    await db.execute('''
      CREATE INDEX idx_users_email ON ${AppConstants.usersTable}(email)
    ''');

    await db.execute('''
      CREATE INDEX idx_users_role ON ${AppConstants.usersTable}(role)
    ''');

    // Table des cours (MODULE 2)
    await db.execute('''
      CREATE TABLE ${AppConstants.coursesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT,
        level TEXT NOT NULL,
        subject TEXT NOT NULL,
        language TEXT NOT NULL,
        instructorId INTEGER,
        instructorName TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        totalChapters INTEGER DEFAULT 0,
        totalResources INTEGER DEFAULT 0,
        averageRating REAL,
        enrolledStudents INTEGER DEFAULT 0,
        FOREIGN KEY (instructorId) REFERENCES ${AppConstants.usersTable}(id)
      )
    ''');

    // Index pour recherche et filtrage des cours
    await db.execute('''
      CREATE INDEX idx_courses_level ON ${AppConstants.coursesTable}(level)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_courses_subject ON ${AppConstants.coursesTable}(subject)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_courses_language ON ${AppConstants.coursesTable}(language)
    ''');

    // Table des chapitres (MODULE 2)
    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        orderIndex INTEGER NOT NULL,
        durationMinutes INTEGER,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_chapters_courseId ON chapters(courseId)
    ''');

    // Table des ressources (MODULE 2)
    await db.execute('''
      CREATE TABLE resources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapterId INTEGER,
        courseId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        url TEXT,
        content TEXT,
        durationSeconds INTEGER,
        sizeBytes INTEGER,
        orderIndex INTEGER NOT NULL,
        isMandatory INTEGER NOT NULL DEFAULT 0,
        metadata TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        quizId INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (chapterId) REFERENCES chapters(id) ON DELETE CASCADE,
        FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (quizId) REFERENCES ${AppConstants.tableQuizzes}(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_resources_chapterId ON resources(chapterId)
    ''');

    await db.execute('''
      CREATE INDEX idx_resources_courseId ON resources(courseId)
    ''');

    // Table de progression des cours (MODULE 2)
    await db.execute('''
      CREATE TABLE course_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        courseId INTEGER NOT NULL,
        currentChapterId INTEGER,
        currentResourceId INTEGER,
        completedChapters INTEGER DEFAULT 0,
        completedResources INTEGER DEFAULT 0,
        progressPercentage REAL DEFAULT 0,
        totalTimeSpentSeconds INTEGER DEFAULT 0,
        lastAccessedAt TEXT,
        completedAt TEXT,
        enrolledAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE,
        UNIQUE(userId, courseId)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_progress_userId ON course_progress(userId)
    ''');

    await db.execute('''
      CREATE INDEX idx_progress_courseId ON course_progress(courseId)
    ''');

    // Table des quiz (Module 3)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableQuizzes} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId INTEGER NOT NULL,
        chapterId INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        durationMinutes INTEGER,
        maxAttempts INTEGER NOT NULL DEFAULT 0,
        passingScore REAL NOT NULL DEFAULT 50.0,
        shuffleQuestions INTEGER NOT NULL DEFAULT 0,
        showResults INTEGER NOT NULL DEFAULT 1,
        availableFrom TEXT,
        availableUntil TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id),
        FOREIGN KEY (chapterId) REFERENCES chapters(id)
      )
    ''');

    // Table des questions (Module 3)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableQuestions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quizId INTEGER NOT NULL,
        type TEXT NOT NULL,
        questionText TEXT NOT NULL,
        explanation TEXT,
        points INTEGER NOT NULL DEFAULT 1,
        orderIndex INTEGER NOT NULL,
        options TEXT,
        correctAnswerIndices TEXT,
        correctAnswerBool INTEGER,
        correctAnswerText TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (quizId) REFERENCES ${AppConstants.tableQuizzes}(id) ON DELETE CASCADE
      )
    ''');

    // Table des tentatives de quiz (Module 3)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableQuizAttempts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quizId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        startedAt TEXT NOT NULL,
        submittedAt TEXT,
        score INTEGER,
        maxScore INTEGER,
        percentage REAL,
        isPassed INTEGER NOT NULL DEFAULT 0,
        answers TEXT,
        attemptNumber INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (quizId) REFERENCES ${AppConstants.tableQuizzes}(id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES ${AppConstants.usersTable}(id)
      )
    ''');

    // MODULE 5: Table des offres de stage
    await db.execute('''
      CREATE TABLE ${AppConstants.internshipsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        company TEXT NOT NULL,
        description TEXT NOT NULL,
        domain TEXT NOT NULL,
        location TEXT NOT NULL,
        duration TEXT NOT NULL,
        internshipType TEXT NOT NULL,
        requiredSkills TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        applicationDeadline TEXT NOT NULL,
        recruiterId TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (recruiterId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
      )
    ''');

    // MODULE 5: Table des candidatures aux stages
    await db.execute('''
      CREATE TABLE internship_applications (
        id TEXT PRIMARY KEY,
        internshipId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        coverLetter TEXT,
        appliedAt TEXT NOT NULL,
        FOREIGN KEY (internshipId) REFERENCES ${AppConstants.internshipsTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (studentId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
        UNIQUE(internshipId, studentId)
      )
    ''');

    // MODULE 4: Tables du Forum
    await db.execute('''
      CREATE TABLE ${AppConstants.tableForumPosts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        authorId TEXT NOT NULL,
        authorName TEXT NOT NULL,
        courseId INTEGER NOT NULL,
        chapterId INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        isPinned INTEGER NOT NULL DEFAULT 0,
        isSolved INTEGER NOT NULL DEFAULT 0,
        likesCount INTEGER DEFAULT 0,
        commentsCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (authorId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (chapterId) REFERENCES chapters(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableForumComments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        authorId TEXT NOT NULL,
        authorName TEXT NOT NULL,
        content TEXT NOT NULL,
        isAccepted INTEGER NOT NULL DEFAULT 0,
        likesCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (postId) REFERENCES ${AppConstants.tableForumPosts}(id) ON DELETE CASCADE,
        FOREIGN KEY (authorId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableForumLikes} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        postId INTEGER,
        commentId INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (postId) REFERENCES ${AppConstants.tableForumPosts}(id) ON DELETE CASCADE,
        FOREIGN KEY (commentId) REFERENCES ${AppConstants.tableForumComments}(id) ON DELETE CASCADE,
        UNIQUE(userId, postId),
        UNIQUE(userId, commentId)
      )
    ''');

    // MODULE 4: Tables de Messagerie
    await db.execute('''
      CREATE TABLE ${AppConstants.tableConversations} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        participant1Id TEXT NOT NULL,
        participant2Id TEXT NOT NULL,
        lastMessage TEXT,
        lastMessageTime TEXT,
        unreadCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (participant1Id) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (participant2Id) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableMessages} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversationId INTEGER NOT NULL,
        senderId TEXT NOT NULL,
        content TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (conversationId) REFERENCES ${AppConstants.tableConversations}(id) ON DELETE CASCADE,
        FOREIGN KEY (senderId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
      )
    ''');

    // MODULE 4: Tables de Mentorat
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMentorProfiles} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL UNIQUE,
        expertise TEXT NOT NULL,
        bio TEXT NOT NULL,
        availability TEXT NOT NULL,
        hourlyRate REAL,
        rating REAL,
        totalSessions INTEGER DEFAULT 0,
        isAvailable INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableMentorshipRequests} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        mentorId TEXT NOT NULL,
        topic TEXT NOT NULL,
        message TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (studentId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (mentorId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableMentorshipSessions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        requestId INTEGER NOT NULL,
        studentId TEXT NOT NULL,
        mentorId TEXT NOT NULL,
        scheduledAt TEXT NOT NULL,
        duration INTEGER NOT NULL,
        location TEXT,
        notes TEXT,
        status TEXT NOT NULL,
        rating REAL,
        feedback TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (requestId) REFERENCES ${AppConstants.tableMentorshipRequests}(id) ON DELETE CASCADE,
        FOREIGN KEY (studentId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
        FOREIGN KEY (mentorId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
      )
    ''');

    // Index pour améliorer les performances
    await db.execute('CREATE INDEX idx_forum_posts_courseId ON ${AppConstants.tableForumPosts}(courseId)');
    await db.execute('CREATE INDEX idx_forum_posts_authorId ON ${AppConstants.tableForumPosts}(authorId)');
    await db.execute('CREATE INDEX idx_forum_comments_postId ON ${AppConstants.tableForumComments}(postId)');
    await db.execute('CREATE INDEX idx_conversations_participant1 ON ${AppConstants.tableConversations}(participant1Id)');
    await db.execute('CREATE INDEX idx_conversations_participant2 ON ${AppConstants.tableConversations}(participant2Id)');
    await db.execute('CREATE INDEX idx_messages_conversationId ON ${AppConstants.tableMessages}(conversationId)');

    print('Base de données créée avec succès');
  }

  /// Gère les mises à jour de la base de données
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Gérer les migrations futures ici
    if (oldVersion < newVersion) {
      print('Mise à jour de la base de données de v$oldVersion à v$newVersion');
      
      // Migration v1 -> v2 : Ajout des tables pour Module 2 (Cours)
      if (oldVersion < 2) {
        print('Migration v1 -> v2: Ajout des tables pour le module Cours');
        
        // Drop old courses table and recreate with new schema
        await db.execute('DROP TABLE IF EXISTS ${AppConstants.coursesTable}');
        
        // Recreate courses table with new schema
        await db.execute('''
          CREATE TABLE ${AppConstants.coursesTable} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            imageUrl TEXT,
            level TEXT NOT NULL,
            subject TEXT NOT NULL,
            language TEXT NOT NULL,
            instructorId INTEGER,
            instructorName TEXT,
            isActive INTEGER NOT NULL DEFAULT 1,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            totalChapters INTEGER DEFAULT 0,
            totalResources INTEGER DEFAULT 0,
            averageRating REAL,
            enrolledStudents INTEGER DEFAULT 0,
            FOREIGN KEY (instructorId) REFERENCES ${AppConstants.usersTable}(id)
          )
        ''');

        // Create indexes
        await db.execute('CREATE INDEX idx_courses_level ON ${AppConstants.coursesTable}(level)');
        await db.execute('CREATE INDEX idx_courses_subject ON ${AppConstants.coursesTable}(subject)');
        await db.execute('CREATE INDEX idx_courses_language ON ${AppConstants.coursesTable}(language)');

        // Create chapters table
        await db.execute('''
          CREATE TABLE chapters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            courseId INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            orderIndex INTEGER NOT NULL,
            durationMinutes INTEGER,
            isActive INTEGER NOT NULL DEFAULT 1,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX idx_chapters_courseId ON chapters(courseId)');

        // Create resources table
        await db.execute('''
          CREATE TABLE resources (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chapterId INTEGER,
            courseId INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            type TEXT NOT NULL,
            url TEXT,
            content TEXT,
            durationSeconds INTEGER,
            sizeBytes INTEGER,
            orderIndex INTEGER NOT NULL,
            isMandatory INTEGER NOT NULL DEFAULT 0,
            metadata TEXT,
            isActive INTEGER NOT NULL DEFAULT 1,
            quizId INTEGER,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (chapterId) REFERENCES chapters(id) ON DELETE CASCADE,
            FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX idx_resources_chapterId ON resources(chapterId)');
        await db.execute('CREATE INDEX idx_resources_courseId ON resources(courseId)');

        // Create course_progress table
        await db.execute('''
          CREATE TABLE course_progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            courseId INTEGER NOT NULL,
            currentChapterId INTEGER,
            currentResourceId INTEGER,
            completedChapters INTEGER DEFAULT 0,
            completedResources INTEGER DEFAULT 0,
            progressPercentage REAL DEFAULT 0,
            totalTimeSpentSeconds INTEGER DEFAULT 0,
            lastAccessedAt TEXT,
            completedAt TEXT,
            enrolledAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
            FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE,
            UNIQUE(userId, courseId)
          )
        ''');

        await db.execute('CREATE INDEX idx_progress_userId ON course_progress(userId)');
        await db.execute('CREATE INDEX idx_progress_courseId ON course_progress(courseId)');

        print('✅ Migration v1 -> v2 terminée');
      }

      // Migration v2 -> v3: Module 3 Quiz system
      if (oldVersion < 3) {
        print('🔄 Migration v2 -> v3: Ajout du système de quiz...');

        // Drop old quiz table if exists
        await db.execute('DROP TABLE IF EXISTS quiz');

        // Create new quizzes table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableQuizzes} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            courseId INTEGER NOT NULL,
            chapterId INTEGER,
            title TEXT NOT NULL,
            description TEXT,
            durationMinutes INTEGER,
            maxAttempts INTEGER NOT NULL DEFAULT 0,
            passingScore REAL NOT NULL DEFAULT 50.0,
            shuffleQuestions INTEGER NOT NULL DEFAULT 0,
            showResults INTEGER NOT NULL DEFAULT 1,
            availableFrom TEXT,
            availableUntil TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT,
            FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id),
            FOREIGN KEY (chapterId) REFERENCES chapters(id)
          )
        ''');

        // Create questions table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableQuestions} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quizId INTEGER NOT NULL,
            type TEXT NOT NULL,
            questionText TEXT NOT NULL,
            explanation TEXT,
            points INTEGER NOT NULL DEFAULT 1,
            orderIndex INTEGER NOT NULL,
            options TEXT,
            correctAnswerIndices TEXT,
            correctAnswerBool INTEGER,
            correctAnswerText TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT,
            FOREIGN KEY (quizId) REFERENCES ${AppConstants.tableQuizzes}(id) ON DELETE CASCADE
          )
        ''');

        // Create quiz_attempts table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableQuizAttempts} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quizId INTEGER NOT NULL,
            userId TEXT NOT NULL,
            startedAt TEXT NOT NULL,
            submittedAt TEXT,
            score INTEGER,
            maxScore INTEGER,
            percentage REAL,
            isPassed INTEGER NOT NULL DEFAULT 0,
            answers TEXT,
            attemptNumber INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (quizId) REFERENCES ${AppConstants.tableQuizzes}(id) ON DELETE CASCADE,
            FOREIGN KEY (userId) REFERENCES ${AppConstants.usersTable}(id)
          )
        ''');

        // Create indexes for better performance
        await db.execute('CREATE INDEX idx_quizzes_courseId ON ${AppConstants.tableQuizzes}(courseId)');
        await db.execute('CREATE INDEX idx_quizzes_chapterId ON ${AppConstants.tableQuizzes}(chapterId)');
        await db.execute('CREATE INDEX idx_questions_quizId ON ${AppConstants.tableQuestions}(quizId)');
        await db.execute('CREATE INDEX idx_attempts_quizId ON ${AppConstants.tableQuizAttempts}(quizId)');
        await db.execute('CREATE INDEX idx_attempts_userId ON ${AppConstants.tableQuizAttempts}(userId)');

        print('✅ Migration v2 -> v3 terminée');
      }

      // Migration v3 -> v4: Ajout du lien quiz vers ressources
      if (oldVersion < 4) {
        print('🔄 Migration v3 -> v4: Ajout du champ quizId aux ressources...');

        // Add quizId column to resources table
        await db.execute('ALTER TABLE resources ADD COLUMN quizId INTEGER');

        print('✅ Migration v3 -> v4 terminée');
      }

      // Migration v4 -> v5: Module 4 - Community & Mentorship
      if (oldVersion < 5) {
        print('🔄 Migration v4 -> v5: Création des tables Module 4 (Communauté & Mentorat)...');

        // Table: forum_posts
        await db.execute('''
          CREATE TABLE ${AppConstants.tableForumPosts} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            authorId TEXT NOT NULL,
            authorName TEXT NOT NULL,
            courseId INTEGER NOT NULL,
            chapterId INTEGER,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            tags TEXT,
            likesCount INTEGER DEFAULT 0,
            commentsCount INTEGER DEFAULT 0,
            isPinned INTEGER DEFAULT 0,
            isSolved INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT,
            FOREIGN KEY (courseId) REFERENCES ${AppConstants.coursesTable}(id) ON DELETE CASCADE
          )
        ''');

        // Table: forum_comments
        await db.execute('''
          CREATE TABLE ${AppConstants.tableForumComments} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            postId INTEGER NOT NULL,
            authorId TEXT NOT NULL,
            authorName TEXT NOT NULL,
            content TEXT NOT NULL,
            likesCount INTEGER DEFAULT 0,
            isAccepted INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT,
            FOREIGN KEY (postId) REFERENCES ${AppConstants.tableForumPosts}(id) ON DELETE CASCADE
          )
        ''');

        // Table: forum_likes (for posts and comments)
        await db.execute('''
          CREATE TABLE ${AppConstants.tableForumLikes} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            targetType TEXT NOT NULL,
            targetId INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            UNIQUE(userId, targetType, targetId)
          )
        ''');

        // Table: conversations
        await db.execute('''
          CREATE TABLE ${AppConstants.tableConversations} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            participant1Id TEXT NOT NULL,
            participant2Id TEXT NOT NULL,
            lastMessage TEXT,
            lastMessageTime TEXT,
            unreadCount INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (participant1Id) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
            FOREIGN KEY (participant2Id) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
          )
        ''');

        // Table: messages
        await db.execute('''
          CREATE TABLE ${AppConstants.tableMessages} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversationId INTEGER NOT NULL,
            senderId TEXT NOT NULL,
            senderName TEXT NOT NULL,
            content TEXT NOT NULL,
            isRead INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (conversationId) REFERENCES ${AppConstants.tableConversations}(id) ON DELETE CASCADE
          )
        ''');

        // Table: mentor_profiles
        await db.execute('''
          CREATE TABLE ${AppConstants.tableMentorProfiles} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL UNIQUE,
            expertise TEXT NOT NULL,
            bio TEXT,
            languages TEXT,
            availableDays TEXT,
            availableTimeSlot TEXT,
            totalStudents INTEGER DEFAULT 0,
            rating REAL DEFAULT 0.0,
            totalSessions INTEGER DEFAULT 0,
            isAvailable INTEGER DEFAULT 1,
            createdAt TEXT NOT NULL,
            updatedAt TEXT,
            FOREIGN KEY (userId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
          )
        ''');

        // Table: mentorship_requests
        await db.execute('''
          CREATE TABLE ${AppConstants.tableMentorshipRequests} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId TEXT NOT NULL,
            mentorId TEXT NOT NULL,
            subject TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            createdAt TEXT NOT NULL,
            respondedAt TEXT,
            FOREIGN KEY (studentId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE,
            FOREIGN KEY (mentorId) REFERENCES ${AppConstants.usersTable}(id) ON DELETE CASCADE
          )
        ''');

        // Table: mentorship_sessions
        await db.execute('''
          CREATE TABLE ${AppConstants.tableMentorshipSessions} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            requestId INTEGER NOT NULL,
            studentId TEXT NOT NULL,
            mentorId TEXT NOT NULL,
            scheduledDate TEXT NOT NULL,
            durationMinutes INTEGER NOT NULL,
            status TEXT DEFAULT 'scheduled',
            notes TEXT,
            studentRating REAL,
            studentFeedback TEXT,
            createdAt TEXT NOT NULL,
            completedAt TEXT,
            FOREIGN KEY (requestId) REFERENCES ${AppConstants.tableMentorshipRequests}(id) ON DELETE CASCADE
          )
        ''');

        // Create indexes for better performance
        await db.execute('CREATE INDEX idx_forum_posts_courseId ON ${AppConstants.tableForumPosts}(courseId)');
        await db.execute('CREATE INDEX idx_forum_posts_authorId ON ${AppConstants.tableForumPosts}(authorId)');
        await db.execute('CREATE INDEX idx_forum_comments_postId ON ${AppConstants.tableForumComments}(postId)');
        await db.execute('CREATE INDEX idx_messages_conversationId ON ${AppConstants.tableMessages}(conversationId)');
        await db.execute('CREATE INDEX idx_mentorship_requests_studentId ON ${AppConstants.tableMentorshipRequests}(studentId)');
        await db.execute('CREATE INDEX idx_mentorship_requests_mentorId ON ${AppConstants.tableMentorshipRequests}(mentorId)');

        print('✅ Migration v4 -> v5 terminée');
      }
    }
  }

  /// Ferme la base de données
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }

  /// Supprime la base de données (utile pour les tests)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Réinitialise la base de données
  Future<void> resetDatabase() async {
    await deleteDatabase();
    _database = await _initDB(AppConstants.databaseName);
  }
}
