import '../../data/models/course.dart';
import '../../data/models/chapter.dart';
import '../../data/models/resource.dart';
import '../../data/repositories/course_repository.dart';
import '../constants/app_constants.dart';

/// Helper class to seed the database with sample course data
class CourseSeedHelper {
  static final CourseRepository _repository = CourseRepository();

  /// Seed sample courses into the database
  static Future<void> seedCourses() async {
    try {
      // Sample Course 1: Mathématiques pour Débutants
      final mathCourse = Course(
        title: 'Mathématiques pour Débutants',
        description:
            'Apprenez les bases des mathématiques : addition, soustraction, multiplication et division. Cours idéal pour les débutants.',
        level: AppConstants.levelBeginner,
        subject: AppConstants.subjectMath,
        language: AppConstants.languageFrench,
        instructorName: 'Dr. Ahmed Hassan',
        imageUrl: 'https://via.placeholder.com/300x200/2E7D32/FFFFFF?text=Math',
      );

      final mathCourseId = await _repository.createCourse(mathCourse);

      // Chapters for Math Course
      await _repository.createChapter(Chapter(
        courseId: mathCourseId,
        title: 'Introduction aux Nombres',
        description: 'Comprendre les nombres et leur utilisation',
        orderIndex: 1,
        durationMinutes: 30,
      ));

      await _repository.createChapter(Chapter(
        courseId: mathCourseId,
        title: 'Addition et Soustraction',
        description: 'Maîtriser les opérations de base',
        orderIndex: 2,
        durationMinutes: 45,
      ));

      // Sample Course 2: Programmation Python
      final pythonCourse = Course(
        title: 'Programmation Python',
        description:
            'Découvrez Python, un langage de programmation puissant et facile à apprendre. Parfait pour les débutants en informatique.',
        level: AppConstants.levelIntermediate,
        subject: AppConstants.subjectProgramming,
        language: AppConstants.languageFrench,
        instructorName: 'Sarah Mansour',
        imageUrl:
            'https://via.placeholder.com/300x200/E53935/FFFFFF?text=Python',
      );

      final pythonCourseId = await _repository.createCourse(pythonCourse);

      final pythonChapter1Id = await _repository.createChapter(Chapter(
        courseId: pythonCourseId,
        title: 'Introduction à Python',
        description: 'Installation et premiers pas avec Python',
        orderIndex: 1,
        durationMinutes: 60,
      ));

      // Add resources to Python chapter
      await _repository.createResource(Resource(
        chapterId: pythonChapter1Id,
        courseId: pythonCourseId,
        title: 'Vidéo : Installation de Python',
        description: 'Comment installer Python sur votre ordinateur',
        type: ResourceType.video,
        url: 'https://www.youtube.com/watch?v=sample',
        durationSeconds: 600,
        orderIndex: 1,
      ));

      await _repository.createResource(Resource(
        chapterId: pythonChapter1Id,
        courseId: pythonCourseId,
        title: 'Document : Guide de démarrage',
        description: 'PDF avec les instructions détaillées',
        type: ResourceType.pdf,
        url: 'https://example.com/python-guide.pdf',
        orderIndex: 2,
      ));

      // Sample Course 3: Histoire de Palestine
      final historyCourse = Course(
        title: 'Histoire de Palestine',
        description:
            'Découvrez l\'histoire riche et fascinante de la Palestine, de l\'antiquité à nos jours.',
        level: AppConstants.levelAdvanced,
        subject: AppConstants.subjectHistory,
        language: AppConstants.languageArabic,
        instructorName: 'Prof. Mahmoud Al-Khalil',
        imageUrl:
            'https://via.placeholder.com/300x200/2E7D32/FFFFFF?text=Histoire',
      );

      await _repository.createCourse(historyCourse);

      // Sample Course 4: Design Graphique
      final designCourse = Course(
        title: 'Design Graphique avec Adobe',
        description:
            'Maîtrisez les outils Adobe pour créer des designs professionnels : Photoshop, Illustrator et InDesign.',
        level: AppConstants.levelIntermediate,
        subject: AppConstants.subjectDesign,
        language: AppConstants.languageEnglish,
        instructorName: 'Layla Ibrahim',
        imageUrl:
            'https://via.placeholder.com/300x200/E53935/FFFFFF?text=Design',
      );

      await _repository.createCourse(designCourse);

      // Sample Course 5: Sciences Physiques
      final physicsCourse = Course(
        title: 'Sciences Physiques - Lycée',
        description:
            'Cours complet de physique pour le niveau lycée : mécanique, électricité, optique et thermodynamique.',
        level: AppConstants.levelIntermediate,
        subject: AppConstants.subjectScience,
        language: AppConstants.languageFrench,
        instructorName: 'Dr. Youssef Hamdan',
        imageUrl:
            'https://via.placeholder.com/300x200/2E7D32/FFFFFF?text=Physique',
      );

      await _repository.createCourse(physicsCourse);

      // Sample Course 6: Anglais pour Débutants
      final englishCourse = Course(
        title: 'Anglais pour Débutants',
        description:
            'Apprenez l\'anglais de zéro : vocabulaire, grammaire et conversation pour les débutants complets.',
        level: AppConstants.levelBeginner,
        subject: AppConstants.subjectLanguage,
        language: AppConstants.languageArabic,
        instructorName: 'Fatima Al-Masri',
        imageUrl:
            'https://via.placeholder.com/300x200/E53935/FFFFFF?text=English',
      );

      await _repository.createCourse(englishCourse);

      // Sample Course 7: Business & Entrepreneuriat
      final businessCourse = Course(
        title: 'Entrepreneuriat et Startups',
        description:
            'Comment créer et gérer une startup réussie. Business plan, marketing, financement et croissance.',
        level: AppConstants.levelAdvanced,
        subject: AppConstants.subjectBusiness,
        language: AppConstants.languageFrench,
        instructorName: 'Karim Nasser',
        imageUrl:
            'https://via.placeholder.com/300x200/2E7D32/FFFFFF?text=Business',
      );

      await _repository.createCourse(businessCourse);

      // Sample Course 8: Géographie du Monde Arabe
      final geoCourse = Course(
        title: 'Géographie du Monde Arabe',
        description:
            'Explorez la géographie, les cultures et l\'économie des pays arabes et du Moyen-Orient.',
        level: AppConstants.levelBeginner,
        subject: AppConstants.subjectGeography,
        language: AppConstants.languageArabic,
        instructorName: 'Dr. Nour Abed',
        imageUrl: 'https://via.placeholder.com/300x200/E53935/FFFFFF?text=Geo',
      );

      await _repository.createCourse(geoCourse);

      print('✅ Database seeded with 8 sample courses!');
    } catch (e) {
      print('❌ Error seeding courses: $e');
    }
  }

  /// Check if courses already exist
  static Future<bool> hasExistingCourses() async {
    try {
      final courses = await _repository.getAllCourses();
      return courses.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Seed courses if database is empty
  static Future<void> seedIfEmpty() async {
    final hasCourses = await hasExistingCourses();
    if (!hasCourses) {
      print('📚 Seeding database with sample courses...');
      await seedCourses();
    } else {
      print('✅ Courses already exist in database');
    }
  }
}
