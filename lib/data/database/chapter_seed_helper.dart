import '../repositories/course_repository.dart';
import '../models/chapter.dart';

/// Helper class to seed chapters for courses
class ChapterSeedHelper {
  static final CourseRepository _repository = CourseRepository();

  /// Seed chapters for the first courses if they don't exist
  static Future<void> seedChaptersIfNeeded() async {
    try {
      // Check if course 1 already has chapters
      final existingChapters = await _repository.getChaptersByCourse(1);
      
      if (existingChapters.isNotEmpty) {
        print('✅ Chapters already exist for course 1 (${existingChapters.length} chapters)');
        return;
      }

      print('📚 Seeding chapters for course 1...');

      // Course 1 chapters (assuming course ID 1 exists)
      final course1Chapters = [
        Chapter(
          courseId: 1,
          title: 'Introduction',
          description: 'Introduction générale au développement mobile avec Flutter',
          orderIndex: 1,
          durationMinutes: 45,
        ),
        Chapter(
          courseId: 1,
          title: 'Les bases de Dart',
          description: 'Apprendre les fondamentaux du langage Dart',
          orderIndex: 2,
          durationMinutes: 60,
        ),
        Chapter(
          courseId: 1,
          title: 'Widgets et UI',
          description: 'Créer des interfaces utilisateur avec les widgets Flutter',
          orderIndex: 3,
          durationMinutes: 90,
        ),
        Chapter(
          courseId: 1,
          title: 'Navigation et Routes',
          description: 'Gérer la navigation entre les écrans',
          orderIndex: 4,
          durationMinutes: 60,
        ),
      ];

      // Course 2 chapters
      final course2Chapters = [
        Chapter(
          courseId: 2,
          title: 'Introduction à Dart',
          description: 'Découverte du langage Dart',
          orderIndex: 1,
          durationMinutes: 30,
        ),
        Chapter(
          courseId: 2,
          title: 'Types et variables',
          description: 'Les types de données en Dart',
          orderIndex: 2,
          durationMinutes: 45,
        ),
      ];

      // Insert chapters for course 1
      for (final chapter in course1Chapters) {
        await _repository.createChapter(chapter);
        print('✅ Created chapter: ${chapter.title}');
      }

      // Insert chapters for course 2
      for (final chapter in course2Chapters) {
        await _repository.createChapter(chapter);
        print('✅ Created chapter: ${chapter.title}');
      }

      print('📚 Chapter seeding completed! Total: ${course1Chapters.length + course2Chapters.length} chapters');
    } catch (e) {
      print('❌ Error seeding chapters: $e');
    }
  }
}
