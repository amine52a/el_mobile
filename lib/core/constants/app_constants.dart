/// Constantes de l'application EduPalestine
class AppConstants {
  // App Info
  static const String appName = 'EduPalestine';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'edu_palestine.db';
  static const int databaseVersion = 6; // Updated for Module 5 (Internship Offers)
  
  // Tables
  static const String usersTable = 'users';
  static const String coursesTable = 'courses';
  static const String tableQuizzes = 'quizzes';
  static const String tableQuestions = 'questions';
  static const String tableQuizAttempts = 'quiz_attempts';
  static const String internshipsTable = 'internships';
  static const String internshipApplicationsTable = 'internship_applications';
  // Module 4 tables
  static const String tableForumPosts = 'forum_posts';
  static const String tableForumComments = 'forum_comments';
  static const String tableForumLikes = 'forum_likes';
  static const String tableConversations = 'conversations';
  static const String tableMessages = 'messages';
  static const String tableMentorProfiles = 'mentor_profiles';
  static const String tableMentorshipRequests = 'mentorship_requests';
  static const String tableMentorshipSessions = 'mentorship_sessions';
  
  // User Roles
  static const String roleStudent = 'Étudiant';
  static const String roleMentor = 'Mentor';
  static const String roleAdmin = 'Administrateur';
  static const String roleRecruiter = 'Recruteur';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  
  // Session
  static const String sessionKey = 'user_session';
  static const String tokenKey = 'auth_token';
  
  // Course Levels (Module 2)
  static const String levelBeginner = 'Débutant';
  static const String levelIntermediate = 'Intermédiaire';
  static const String levelAdvanced = 'Avancé';
  
  static const List<String> courseLevels = [
    levelBeginner,
    levelIntermediate,
    levelAdvanced,
  ];
  
  // Course Subjects (Module 2)
  static const String subjectMath = 'Mathématiques';
  static const String subjectScience = 'Sciences';
  static const String subjectLanguage = 'Langues';
  static const String subjectHistory = 'Histoire';
  static const String subjectGeography = 'Géographie';
  static const String subjectProgramming = 'Programmation';
  static const String subjectDesign = 'Design';
  static const String subjectBusiness = 'Business';
  
  static const List<String> courseSubjects = [
    subjectMath,
    subjectScience,
    subjectLanguage,
    subjectHistory,
    subjectGeography,
    subjectProgramming,
    subjectDesign,
    subjectBusiness,
  ];
  
  // Course Languages (Module 2)
  static const String languageArabic = 'Arabe';
  static const String languageEnglish = 'Anglais';
  static const String languageFrench = 'Français';
  
  static const List<String> courseLanguages = [
    languageArabic,
    languageEnglish,
    languageFrench,
  ];
  
  // Performance Requirements
  static const int maxLoginTime = 2; // seconds
  static const double minAvailability = 99.5; // percentage
  static const int maxCourseListLoadTime = 2; // seconds (Module 2)
  static const int maxResultsPerPage = 1400; // entries (Module 2)
  
  // Module 5: Internship Constants
  // Internship Types
  static const String internshipTypeMandatory = 'Obligatoire';
  static const String internshipTypeFinal = 'Final';
  static const String internshipTypeOptional = 'Optionnel';
  
  static const List<String> internshipTypes = [
    internshipTypeMandatory,
    internshipTypeFinal,
    internshipTypeOptional,
  ];
  
  // Internship Domains
  static const String domainInformatics = 'Informatique';
  static const String domainEngineering = 'Ingénierie';
  static const String domainBusiness = 'Commerce';
  static const String domainHealth = 'Santé';
  static const String domainEducation = 'Éducation';
  static const String domainArts = 'Arts';
  static const String domainLaw = 'Droit';
  static const String domainScience = 'Sciences';
  
  static const List<String> internshipDomains = [
    domainInformatics,
    domainEngineering,
    domainBusiness,
    domainHealth,
    domainEducation,
    domainArts,
    domainLaw,
    domainScience,
  ];
  
  // Application Status
  static const String applicationStatusPending = 'pending';
  static const String applicationStatusAccepted = 'accepted';
  static const String applicationStatusRejected = 'rejected';
  
  static const List<String> applicationStatuses = [
    applicationStatusPending,
    applicationStatusAccepted,
    applicationStatusRejected,
  ];
}
