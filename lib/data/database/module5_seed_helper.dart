import '../database/database_helper.dart';
import '../models/internship.dart';
import '../../core/constants/app_constants.dart';

/// Seed helper pour créer des offres de stage d'exemple (Module 5)
class Module5SeedHelper {
  static Future<void> seedIfNeeded() async {
    final db = await DatabaseHelper.instance.database;
    
    // Vérifier si des offres existent déjà
    final result = await db.query(AppConstants.internshipsTable, limit: 1);
    if (result.isNotEmpty) {
      return; // Déjà seed
    }

    print('🌱 Seeding Module 5 data (Internships)...');
    
    // Créer des offres de stage d'exemple
    await _seedInternships(db);
    
    print('✅ Module 5 seed data created successfully!');
  }

  static Future<void> _seedInternships(db) async {
    // Récupérer l'ID admin comme recruteur
    final adminResult = await db.query(
      AppConstants.usersTable,
      where: 'email = ?',
      whereArgs: ['admin@edupalestine.com'],
      limit: 1,
    );
    
    if (adminResult.isEmpty) {
      print('⚠️ Admin user not found, skipping internship seed');
      return;
    }
    
    final adminId = adminResult.first['id'] as String;
    
    final internships = [
      // 1. Développeur Web Full Stack
      Internship.create(
        title: 'Développeur Web Full Stack',
        company: 'Tech Solutions Palestine',
        description: '''Nous recherchons un stagiaire développeur web full stack motivé pour rejoindre notre équipe de développement.

Missions:
• Développement d'applications web avec React et Node.js
• Intégration d'APIs RESTful
• Participation aux revues de code
• Tests et débogage

Profil recherché:
• Étudiant en informatique (3ème année ou plus)
• Connaissance de JavaScript, HTML, CSS
• Maîtrise de Git
• Capacité à travailler en équipe''',
        domain: AppConstants.domainInformatics,
        location: 'Ramallah, Palestine',
        duration: '3 mois',
        internshipType: AppConstants.internshipTypeMandatory,
        requiredSkills: ['JavaScript', 'React', 'Node.js', 'Git', 'SQL'],
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 120)),
        applicationDeadline: DateTime.now().add(const Duration(days: 15)),
        recruiterId: adminId,
      ),

      // 2. Ingénieur Réseau
      Internship.create(
        title: 'Ingénieur Réseau Junior',
        company: 'Palestine Telecom',
        description: '''Stage en ingénierie réseau au sein du département infrastructure.

Responsabilités:
• Configuration et maintenance des équipements réseau
• Surveillance des performances réseau
• Documentation technique
• Support technique niveau 2

Compétences requises:
• Formation en réseaux et télécommunications
• Connaissance des protocoles TCP/IP
• Certification CCNA serait un plus''',
        domain: AppConstants.domainEngineering,
        location: 'Gaza, Palestine',
        duration: '6 mois',
        internshipType: AppConstants.internshipTypeFinal,
        requiredSkills: ['Réseaux', 'TCP/IP', 'Cisco', 'Linux'],
        startDate: DateTime.now().add(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 225)),
        applicationDeadline: DateTime.now().add(const Duration(days: 20)),
        recruiterId: adminId,
      ),

      // 3. Assistant Marketing Digital
      Internship.create(
        title: 'Assistant Marketing Digital',
        company: 'Digital Marketing Agency',
        description: '''Rejoignez notre agence dynamique pour apprendre le marketing digital.

Missions:
• Gestion des réseaux sociaux
• Création de contenu pour les campagnes
• Analyse des performances marketing
• Support dans la stratégie SEO/SEM

Profil:
• Étudiant en marketing, communication ou commerce
• Créativité et sens du détail
• Maîtrise des réseaux sociaux
• Compétences en design (Canva, Photoshop) appréciées''',
        domain: AppConstants.domainBusiness,
        location: 'Bethléem, Palestine',
        duration: '2 mois',
        internshipType: AppConstants.internshipTypeOptional,
        requiredSkills: ['Réseaux sociaux', 'Marketing', 'Communication', 'Créativité'],
        startDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 80)),
        applicationDeadline: DateTime.now().add(const Duration(days: 10)),
        recruiterId: adminId,
      ),

      // 4. Assistant Médical
      Internship.create(
        title: 'Assistant Médical en Pédiatrie',
        company: 'Hôpital Al-Quds',
        description: '''Stage dans le service pédiatrie d\'un hôpital moderne.

Activités:
• Assistance aux soins infirmiers
• Accueil et orientation des patients
• Tenue des dossiers médicaux
• Participation aux consultations

Prérequis:
• Étudiant en médecine ou sciences infirmières
• Bon relationnel avec les enfants
• Rigueur et sens des responsabilités
• Vaccination à jour obligatoire''',
        domain: AppConstants.domainHealth,
        location: 'Jérusalem, Palestine',
        duration: '3 mois',
        internshipType: AppConstants.internshipTypeMandatory,
        requiredSkills: ['Soins infirmiers', 'Communication', 'Empathie'],
        startDate: DateTime.now().add(const Duration(days: 40)),
        endDate: DateTime.now().add(const Duration(days: 130)),
        applicationDeadline: DateTime.now().add(const Duration(days: 25)),
        recruiterId: adminId,
      ),

      // 5. Enseignant Stagiaire
      Internship.create(
        title: 'Enseignant Stagiaire - Mathématiques',
        company: 'École Secondaire Al-Bireh',
        description: '''Stage d\'enseignement dans une école secondaire renommée.

Tâches:
• Préparation et animation de cours de mathématiques
• Correction de devoirs et examens
• Soutien scolaire individualisé
• Participation aux conseils de classe

Profil:
• Étudiant en sciences de l\'éducation
• Excellente maîtrise des mathématiques
• Patience et pédagogie
• Expérience avec les adolescents souhaitée''',
        domain: AppConstants.domainEducation,
        location: 'Al-Bireh, Palestine',
        duration: '6 mois',
        internshipType: AppConstants.internshipTypeFinal,
        requiredSkills: ['Mathématiques', 'Pédagogie', 'Communication'],
        startDate: DateTime.now().add(const Duration(days: 35)),
        endDate: DateTime.now().add(const Duration(days: 215)),
        applicationDeadline: DateTime.now().add(const Duration(days: 18)),
        recruiterId: adminId,
      ),

      // 6. Designer Graphique
      Internship.create(
        title: 'Designer Graphique Junior',
        company: 'Creative Studio Palestine',
        description: '''Studio de création recherche un stagiaire designer graphique talentueux.

Missions:
• Création de supports visuels (affiches, flyers, logos)
• Design d\'interfaces utilisateur (UI)
• Animation graphique simple
• Collaboration avec l\'équipe créative

Compétences:
• Formation en design graphique ou arts appliqués
• Maîtrise d\'Adobe Creative Suite (Photoshop, Illustrator, InDesign)
• Portfolio de créations personnelles
• Sens artistique développé''',
        domain: AppConstants.domainArts,
        location: 'Naplouse, Palestine',
        duration: '3 mois',
        internshipType: AppConstants.internshipTypeOptional,
        requiredSkills: ['Photoshop', 'Illustrator', 'UI/UX', 'Créativité'],
        startDate: DateTime.now().add(const Duration(days: 25)),
        endDate: DateTime.now().add(const Duration(days: 115)),
        applicationDeadline: DateTime.now().add(const Duration(days: 12)),
        recruiterId: adminId,
      ),

      // 7. Assistant Juridique
      Internship.create(
        title: 'Assistant Juridique',
        company: 'Cabinet d\'Avocats Al-Haq',
        description: '''Stage au sein d\'un cabinet d\'avocats spécialisé en droit des affaires.

Responsabilités:
• Recherche juridique et documentation
• Rédaction de notes de synthèse
• Assistance lors des consultations
• Classement et archivage de dossiers

Profil recherché:
• Étudiant en droit (minimum 2ème année)
• Excellentes capacités rédactionnelles
• Rigueur et confidentialité
• Intérêt pour le droit des affaires''',
        domain: AppConstants.domainLaw,
        location: 'Ramallah, Palestine',
        duration: '3 mois',
        internshipType: AppConstants.internshipTypeMandatory,
        requiredSkills: ['Droit', 'Recherche juridique', 'Rédaction'],
        startDate: DateTime.now().add(const Duration(days: 50)),
        endDate: DateTime.now().add(const Duration(days: 140)),
        applicationDeadline: DateTime.now().add(const Duration(days: 30)),
        recruiterId: adminId,
      ),

      // 8. Chercheur en Biologie
      Internship.create(
        title: 'Assistant de Recherche - Biologie Moléculaire',
        company: 'Université An-Najah - Laboratoire de Recherche',
        description: '''Stage de recherche dans un laboratoire universitaire de pointe.

Activités:
• Préparation d\'échantillons biologiques
• Manipulation d\'équipements de laboratoire
• Analyse de données expérimentales
• Rédaction de rapports scientifiques

Exigences:
• Étudiant en biologie, biochimie ou biotechnologie
• Connaissances en biologie moléculaire
• Rigueur scientifique
• Capacité à travailler de manière autonome''',
        domain: AppConstants.domainScience,
        location: 'Naplouse, Palestine',
        duration: '6 mois',
        internshipType: AppConstants.internshipTypeFinal,
        requiredSkills: ['Biologie', 'Laboratoire', 'Analyse', 'Rédaction'],
        startDate: DateTime.now().add(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 240)),
        applicationDeadline: DateTime.now().add(const Duration(days: 35)),
        recruiterId: adminId,
      ),

      // 9. Développeur Mobile (URGENT)
      Internship.create(
        title: 'Développeur Mobile Flutter (URGENT)',
        company: 'Startup Innovation Hub',
        description: '''Startup en forte croissance recherche développeur mobile Flutter.

Projet:
• Développement d\'une application mobile éducative
• Collaboration avec l\'équipe produit
• Implémentation de fonctionnalités innovantes
• Tests et optimisation des performances

Profil idéal:
• Passion pour le développement mobile
• Connaissance de Flutter/Dart
• Expérience avec Firebase appréciée
• Esprit startup et autonomie''',
        domain: AppConstants.domainInformatics,
        location: 'Ramallah, Palestine',
        duration: '3 mois',
        internshipType: AppConstants.internshipTypeOptional,
        requiredSkills: ['Flutter', 'Dart', 'Mobile', 'Firebase'],
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 100)),
        applicationDeadline: DateTime.now().add(const Duration(days: 5)),
        recruiterId: adminId,
      ),

      // 10. Comptable Assistant
      Internship.create(
        title: 'Assistant Comptable',
        company: 'Fiduciaire Expertise Comptable',
        description: '''Cabinet comptable recherche stagiaire pour la saison fiscale.

Missions:
• Saisie comptable et rapprochements bancaires
• Préparation des déclarations fiscales
• Classement et archivage de documents
• Assistance aux audits

Compétences:
• Formation en comptabilité, gestion ou finance
• Maîtrise d\'Excel
• Sens de l\'organisation
• Discrétion professionnelle''',
        domain: AppConstants.domainBusiness,
        location: 'Hébron, Palestine',
        duration: '3 mois',
        internshipType: AppConstants.internshipTypeMandatory,
        requiredSkills: ['Comptabilité', 'Excel', 'Fiscalité', 'Organisation'],
        startDate: DateTime.now().add(const Duration(days: 28)),
        endDate: DateTime.now().add(const Duration(days: 118)),
        applicationDeadline: DateTime.now().add(const Duration(days: 14)),
        recruiterId: adminId,
      ),
    ];

    // Insérer toutes les offres
    for (final internship in internships) {
      await db.insert(AppConstants.internshipsTable, internship.toMap());
    }

    print('   ✓ Created ${internships.length} internship offers');
  }
}
