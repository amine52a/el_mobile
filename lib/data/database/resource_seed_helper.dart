import '../database/database_helper.dart';

/// Helper class to seed test resources with video and PDF URLs
class ResourceSeedHelper {
  static Future<void> seedTestResources() async {
    final db = await DatabaseHelper.instance.database;

    // Sample video resources using YouTube videos (most reliable option)
    // NOTE: URLs are YouTube video IDs for compatibility with youtube_player_flutter
    final videoResources = [
      {
        'courseId': 1,
        'chapterId': 1,
        'title': 'Introduction à Flutter',
        'description': 'Tutoriel d\'introduction Flutter - Les bases du framework',
        'type': 'video',
        'url': 'https://www.youtube.com/watch?v=1xipg02Wu8s', // Flutter Tutorial for Beginners
        'durationSeconds': 850,
        'orderIndex': 1,
        'isMandatory': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'courseId': 1,
        'chapterId': 2,
        'title': 'Les Widgets Flutter',
        'description': 'Découvrez les widgets de base dans Flutter',
        'type': 'video',
        'url': 'https://www.youtube.com/watch?v=wE7khGHVkYY', // Flutter Widgets Tutorial
        'durationSeconds': 720,
        'orderIndex': 1,
        'isMandatory': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'courseId': 2,
        'chapterId': null,
        'title': 'Architecture Flutter',
        'description': 'Comprendre l\'architecture de Flutter',
        'type': 'video',
        'url': 'https://www.youtube.com/watch?v=UDF-xVfVY2o', // Flutter Architecture
        'durationSeconds': 600,
        'orderIndex': 1,
        'isMandatory': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    // Sample PDF resources (using public test PDFs)
    final pdfResources = [
      {
        'courseId': 1,
        'chapterId': 1,
        'title': 'Guide Flutter PDF',
        'description': 'Documentation PDF sur les bases de Flutter',
        'type': 'pdf',
        'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        'orderIndex': 2,
        'isMandatory': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'courseId': 2,
        'chapterId': null, // Course-level resource
        'title': 'Tutoriel Dart Complet',
        'description': 'Guide complet du langage Dart en PDF',
        'type': 'pdf',
        'url': 'https://pdfobject.com/pdf/sample.pdf',
        'orderIndex': 1,
        'isMandatory': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    // Insert video resources
    for (final resource in videoResources) {
      await db.insert('resources', resource);
      print('✅ Seeded video: ${resource['title']}');
    }

    // Insert PDF resources
    for (final resource in pdfResources) {
      await db.insert('resources', resource);
      print('✅ Seeded PDF: ${resource['title']}');
    }

    print('📚 Resource seeding completed!');
  }

  /// Delete all test resources
  static Future<void> clearTestResources() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('resources');
    print('🗑️ All resources cleared');
  }
}
