# 📱 EduPalestine — Documentation Technique Complète

**Développeur :** Amine Abdellah  
**Date :** Novembre 2026  
**Version :** 1.0.0  
**Plateforme :** Flutter (Windows Desktop / Android / iOS)  
**Base de données :** SQLite (sqflite + sqflite_common_ffi)

---

## 📋 Table des Matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Architecture du projet](#2-architecture-du-projet)
3. [Stack technique](#3-stack-technique)
4. [Installation et lancement](#4-installation-et-lancement)
5. [Module 1 — Authentification](#5-module-1--authentification)
6. [Module 2 — Cours et Contenus](#6-module-2--cours-et-contenus)
7. [Module 3 — Quiz et Évaluations](#7-module-3--quiz-et-évaluations)
8. [Module 4 — Communauté et Mentorat](#8-module-4--communauté-et-mentorat)
9. [Module 5 — Offres de Stage](#9-module-5--offres-de-stage)
10. [Base de données SQLite](#10-base-de-données-sqlite)
11. [Sécurité](#11-sécurité)
12. [Fonctionnalités Bonus](#12-fonctionnalités-bonus)
13. [Comptes de test](#13-comptes-de-test)
14. [Résolution de problèmes](#14-résolution-de-problèmes)

---

## 1. Vue d'ensemble

**EduPalestine** est une application mobile éducative complète développée avec Flutter. Elle offre une plateforme d'apprentissage, de mentorat et de gestion de stages pour les étudiants.

### Fonctionnalités principales

| Module | Description | Statut |
|--------|-------------|--------|
| Authentification | Inscription, connexion, profil, sécurité | ✅ Complet |
| Cours & Contenus | Catalogue de cours, chapitres, vidéos, PDFs | ✅ Complet |
| Quiz & Évaluations | Questions, passages de quiz, scores | ✅ Complet |
| Communauté & Mentorat | Forum, messagerie, mentorat | ✅ Complet |
| Offres de Stage | Publication, candidatures, suivi | ✅ Complet |

### Thème visuel

L'application utilise les couleurs du drapeau palestinien :

| Couleur | Code HEX | Usage |
|---------|----------|-------|
| Vert Palestine | `#2E7D32` | Couleur primaire |
| Rouge Palestine | `#E53935` | Couleur secondaire |
| Fond | `#F5F5F5` | Arrière-plan |
| Surface | `#FFFFFF` | Cartes et formulaires |

---

## 2. Architecture du projet

L'application suit une architecture **Clean Architecture** à 5 couches :

```
┌─────────────────────────────────────────────────┐
│          PRESENTATION LAYER (UI / Screens)       │
│    LoginScreen, HomeScreen, CourseScreen…        │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│        STATE MANAGEMENT (Providers)              │
│  AuthProvider, CourseProvider, QuizProvider…    │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│          BUSINESS LOGIC (Services)               │
│          AuthService, CourseService…             │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│          DATA ACCESS (Repositories)              │
│    UserRepository, CourseRepository…            │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│          DATA SOURCE (SQLite)                    │
│               DatabaseHelper                     │
└─────────────────────────────────────────────────┘
```

### Structure des dossiers

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # Constantes globales (tables, rôles, niveaux)
│   ├── theme/
│   │   └── app_theme.dart              # Thème Palestine (vert/rouge)
│   └── utils/
│       ├── validators.dart              # Validation des formulaires
│       ├── password_helper.dart         # Hachage SHA-256
│       └── course_seed_helper.dart      # Données de test pour les cours
│
├── data/
│   ├── database/
│   │   ├── database_helper.dart         # Configuration SQLite (v6, migrations)
│   │   ├── chapter_seed_helper.dart     # Seed chapitres
│   │   ├── resource_seed_helper.dart    # Seed ressources vidéo/PDF
│   │   ├── user_seed_helper.dart        # Seed utilisateurs admin/test
│   │   ├── module4_seed_helper.dart     # Seed forum, messages, mentorat
│   │   └── module5_seed_helper.dart     # Seed offres de stage
│   ├── models/
│   │   ├── user.dart
│   │   ├── course.dart
│   │   ├── chapter.dart
│   │   ├── resource.dart
│   │   ├── course_progress.dart
│   │   ├── quiz.dart
│   │   ├── question.dart
│   │   ├── quiz_attempt.dart
│   │   ├── forum_post.dart
│   │   ├── forum_comment.dart
│   │   ├── conversation.dart
│   │   ├── message.dart
│   │   ├── mentor_profile.dart
│   │   ├── mentorship_request.dart
│   │   ├── mentorship_session.dart
│   │   └── internship.dart
│   └── repositories/
│       ├── user_repository.dart
│       ├── course_repository.dart
│       ├── quiz_repository.dart
│       ├── forum_repository.dart
│       ├── messaging_repository.dart
│       ├── mentorship_repository.dart
│       └── internship_repository.dart
│
├── services/
│   ├── auth_service.dart
│   └── course_service.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── course_provider.dart
│   ├── quiz_provider.dart
│   ├── forum_provider.dart
│   ├── messaging_provider.dart
│   ├── mentorship_provider.dart
│   └── internship_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── change_password_screen.dart
│   ├── courses/
│   │   ├── course_list_screen.dart
│   │   ├── course_detail_screen.dart
│   │   ├── course_form_screen.dart
│   │   ├── chapter_form_screen.dart
│   │   ├── resource_list_screen.dart
│   │   ├── resource_form_screen.dart
│   │   ├── video_player_screen.dart
│   │   └── pdf_viewer_screen.dart
│   ├── quiz/
│   │   ├── quiz_list_screen.dart
│   │   ├── quiz_view_screen.dart
│   │   └── quiz_results_screen.dart
│   ├── forum/
│   │   ├── forum_list_screen.dart
│   │   ├── forum_post_detail_screen.dart
│   │   └── forum_create_post_screen.dart
│   ├── messaging/
│   │   ├── conversations_screen.dart
│   │   └── chat_screen.dart
│   ├── mentorship/
│   │   ├── mentor_list_screen.dart
│   │   └── mentorship_request_screen.dart
│   └── internship/
│       ├── internship_list_screen.dart
│       ├── internship_detail_screen.dart
│       └── internship_form_screen.dart
│
├── widgets/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── message_widgets.dart
│   └── captcha_widget.dart
│
└── main.dart
```

---

## 3. Stack technique

### Framework & Langage

| Technologie | Version | Usage |
|-------------|---------|-------|
| Flutter | 3.47.9 | Framework UI multiplateforme |
| Dart | 3.13.7 | Langage de programmation |

### Packages principaux

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.1

  # Base de données
  sqflite: ^2.3.0
  sqflite_common_ffi: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3

  # Authentification & Sécurité
  flutter_secure_storage: ^9.0.0
  crypto: ^3.0.3
  email_validator: ^2.1.17

  # Médias
  video_player: ^2.8.1
  chewie: ^1.7.4
  syncfusion_flutter_pdfviewer: ^27.2.5

  # Utilitaires
  intl: ^0.18.1
  uuid: ^4.2.1
  http: ^1.1.2
  url_launcher: ^6.2.2
  file_picker: ^8.1.4
```

---

## 4. Installation et lancement

### Prérequis

- Flutter SDK (extrait dans `C:\Users\<user>\Desktop\flutter`)
- Visual Studio Build Tools 2022 (composant `VC.Tools.x86.x64` + `VC.ATL`)
- Developer Mode Windows activé

### Première installation

```powershell
# Cloner le dépôt
git clone https://github.com/RawenLb/ProjetMobile.git .

# Ajouter Flutter au PATH
$env:Path += ";C:\Users\abdellah\Desktop\flutter\bin"

# Installer les dépendances
flutter pub get

# Lancer sur Windows Desktop
flutter run -d windows

# Lancer dans Edge (web — fonctionnalités limitées, pas de DB)
flutter run -d edge

# Vérifier l'environnement
flutter doctor
```

### Commandes utiles

```powershell
# Nettoyer et reconstruire
flutter clean; flutter pub get; flutter run -d windows

# Lister les appareils disponibles
flutter devices

# Lancer en mode profil (plus rapide)
flutter run -d windows --profile
```

### Initialisation automatique au démarrage

Au premier lancement, `main.dart` exécute automatiquement :

```dart
await UserSeedHelper.createTestUsersIfNeeded();    // Crée admin + étudiant test
await CourseSeedHelper.seedIfEmpty();               // 8 cours de démo
await ChapterSeedHelper.seedChaptersIfNeeded();     // Chapitres des cours
await ResourceSeedHelper.seedTestResources();       // Vidéos + PDFs de test
await Module4SeedHelper.seedIfNeeded();             // Forum, messages, mentorat
await Module5SeedHelper.seedIfNeeded();             // 10 offres de stage
```

---

## 5. Module 1 — Authentification

### Fonctionnalités implémentées

#### F1.1.1 — Inscription utilisateur

- Champs : Email, Prénom, Nom, Rôle, Bio (optionnel), Mot de passe + confirmation
- Validation en temps réel avec messages d'erreur clairs
- Hachage sécurisé du mot de passe (SHA-256 + salt)
- Vérification d'unicité de l'email
- Choix du rôle : Étudiant, Mentor, Administrateur, Recruteur
- CAPTCHA mathématique anti-bot
- Redirection automatique après inscription

**Fichier :** `lib/screens/auth/register_screen.dart`

#### F1.1.2 — Mot de passe oublié

- Interface en deux étapes : demande du token, puis réinitialisation
- Génération d'un token unique (expire après 1 heure)
- Validation du nouveau mot de passe

**Fichier :** `lib/screens/auth/forgot_password_screen.dart`

#### F1.1.3 — Profil utilisateur

- Affichage des informations personnelles
- Avatar avec initiales colorées
- Mode édition / lecture
- Modification du prénom, nom et bio
- Email et rôle non modifiables (sécurité)
- Sauvegarde automatique de la session

**Fichier :** `lib/screens/profile/profile_screen.dart`

#### F1.1.4 — Changement de mot de passe

- Vérification de l'ancien mot de passe avant mise à jour
- Validation du nouveau mot de passe (min 8 caractères, 1 majuscule, 1 chiffre)
- Confirmation de mot de passe obligatoire

**Fichier :** `lib/screens/profile/change_password_screen.dart`

#### F1.2.1 — CRUD Utilisateur

```dart
createUser(email, password, firstName, lastName, role, bio)
getUserById(id)
getUserByEmail(email)
getAllUsers()
authenticateUser(email, password)
updateUser(user)
deleteUser(id)        // Soft delete (isActive = 0)
hardDeleteUser(id)    // Suppression définitive
```

**Fichier :** `lib/data/repositories/user_repository.dart`

#### F1.2.3 — Gestion des rôles

4 rôles disponibles :

| Rôle | Constante | Permissions |
|------|-----------|-------------|
| Étudiant | `roleStudent` | Accès cours, quiz, forum |
| Mentor | `roleMentor` | + Profil mentor, sessions |
| Administrateur | `roleAdmin` | + Création cours, utilisateurs |
| Recruteur | `roleRecruiter` | + Publication stages |

### Flux de navigation

```
SplashScreen
    ├─→ LoginScreen (si non connecté)
    │       ├─→ RegisterScreen
    │       ├─→ ForgotPasswordScreen
    │       └─→ HomeScreen (après connexion)
    └─→ HomeScreen (si déjà connecté)
            ├─→ Cours
            ├─→ Quiz
            ├─→ Communauté
            ├─→ Stages
            └─→ Profil
                    └─→ ChangePasswordScreen
```

### Gestion de session

- Stockage via `flutter_secure_storage` (chiffrement hardware)
- Persistance de session entre les lancements
- Token d'authentification : `token_{userId}_{timestamp}`
- Expiration automatique des tokens de réinitialisation (1 heure)

---

## 6. Module 2 — Cours et Contenus

### Données de démonstration (8 cours pré-chargés)

| # | Titre | Niveau | Langue |
|---|-------|--------|--------|
| 1 | Développement Mobile avec Flutter | Débutant | Français |
| 2 | Programmation Python | Intermédiaire | Français |
| 3 | Histoire de Palestine | Avancé | Arabe |
| 4 | Design Graphique Adobe | Intermédiaire | Anglais |
| 5 | Sciences Physiques Lycée | Intermédiaire | Français |
| 6 | Anglais pour Débutants | Débutant | Arabe |
| 7 | Entrepreneuriat et Startups | Avancé | Français |
| 8 | Géographie du Monde Arabe | Débutant | Arabe |

### Filtres disponibles

- Niveau : Débutant, Intermédiaire, Avancé
- Matière : Mathématiques, Sciences, Langues, Histoire, Géographie, Programmation, Design, Business
- Langue : Arabe, Anglais, Français
- Recherche par mot-clé

### Fonctionnalités cours

#### Inscription aux cours

```dart
await courseProvider.enrollInCourseWithUUID(userId, courseId);
```

#### Suivi de progression

```dart
await courseProvider.updateProgressWithUUID(
  userId: userId,
  courseId: courseId,
  currentChapterId: chapterId,
  currentResourceId: resourceId,
  additionalTimeSpentSeconds: timeSpent,
);
```

Calcul automatique :
- Pourcentage de progression = (chapitres + ressources complétés) / total
- Temps total passé (incrémenté)
- Dernière ressource visitée
- Date de dernier accès

### F2.2.1 — Lecteur Vidéo

- Lecteur basé sur `video_player` + `chewie`
- Contrôles : Play/Pause, Volume, Seek, Plein écran
- Suivi automatique du temps de visionnage
- Mise à jour automatique de la progression du cours
- Gestion des erreurs de chargement

**Fichier :** `lib/screens/courses/video_player_screen.dart`

### F2.2.2 — Visionneuse PDF

- Basée sur `syncfusion_flutter_pdfviewer`
- Navigation par page (boutons précédent/suivant)
- Indicateur de page (ex : "5 / 24")
- Accès direct à une page (dialogue de recherche)
- Zoom et défilement (pinch-to-zoom)
- Suivi automatique du temps de lecture

**Fichier :** `lib/screens/courses/pdf_viewer_screen.dart`

### Upload de fichiers locaux

- Support PDF (max 10 MB) et vidéo (max 50 MB)
- Sélection via `file_picker`
- Stockage local : `/app_documents/uploaded_resources/`
- Format de nommage : `{type}_{timestamp}.{extension}`
- URL scheme personnalisé : `local://chemin/vers/fichier`

### Ressources de test incluses

| Ressource | Type | Durée |
|-----------|------|-------|
| Introduction à Flutter | Vidéo | 9:56 |
| Les Widgets Flutter | Vidéo | 10:53 |
| Architecture Flutter | Vidéo | — |
| Guide Flutter PDF | PDF | — |
| Tutoriel Dart Complet | PDF | — |

---

## 7. Module 3 — Quiz et Évaluations

### Types de questions supportés

| Type | Description |
|------|-------------|
| `single_choice` | Une seule réponse correcte parmi plusieurs options |
| `multiple_choice` | Plusieurs réponses correctes possibles |
| `true_false` | Vrai ou Faux |
| `short_answer` | Réponse texte courte |

### Fonctionnalités

- Association quiz ↔ cours et ↔ chapitre
- Durée limite configurable (en minutes)
- Nombre maximum de tentatives configurable
- Score minimum de réussite configurable (% par défaut 50%)
- Mélange aléatoire des questions (optionnel)
- Affichage des résultats après soumission

### Modèle de quiz

```dart
class Quiz {
  final int? id;
  final int courseId;
  final int? chapterId;
  final String title;
  final String? description;
  final int? durationMinutes;
  final int maxAttempts;        // 0 = illimité
  final double passingScore;    // Pourcentage
  final bool shuffleQuestions;
  final bool showResults;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
}
```

### Suivi des tentatives

Chaque tentative enregistre :
- Score obtenu et score maximum
- Pourcentage et statut réussite/échec
- Réponses détaillées par question
- Numéro de tentative
- Dates de début et de soumission

---

## 8. Module 4 — Communauté et Mentorat

### Sous-modules

#### 8.1 — Forum de Questions/Réponses

**Fonctionnalités :**
- Posts associés à un cours (et optionnellement un chapitre)
- Tags par post
- Système de likes sur posts et commentaires
- Marquage des réponses acceptées (Q&A)
- Posts épinglés par l'admin
- Filtrage par cours, matière, popularité
- Recherche par mot-clé

**Tables :** `forum_posts`, `forum_comments`, `forum_likes`

**Route dynamique :**
```
/forum/course/:courseId?title=NomDuCours
/forum/post/:postId
/forum/create/:courseId
```

#### 8.2 — Messagerie directe

**Fonctionnalités :**
- Conversations entre deux utilisateurs
- Aperçu du dernier message
- Compteur de messages non lus
- Historique complet des messages

**Tables :** `conversations`, `messages`

#### 8.3 — Système de Mentorat

**Fonctionnalités :**
- Profils mentors avec expertise, bio, disponibilités, note, nombre de sessions
- Demandes de mentorat (sujet + message)
- Statuts : `pending`, `accepted`, `rejected`
- Sessions planifiées avec date, durée, lieu, notes
- Évaluation des sessions (note + commentaire)

**Tables :** `mentor_profiles`, `mentorship_requests`, `mentorship_sessions`

### Données de test (Module 4)

- Posts de forum créés automatiquement pour les cours existants
- Commentaires de démonstration
- Profils mentors avec expertise variée

---

## 9. Module 5 — Offres de Stage

### Fonctionnalités

- Publication d'offres par les recruteurs
- Filtrage par domaine, lieu, type de stage
- Candidature avec lettre de motivation
- Suivi des candidatures (statuts : `pending`, `accepted`, `rejected`)
- Contrainte UNIQUE par couple `(internshipId, studentId)`

### Données de test

**10 offres de stage pré-créées** dans des domaines variés (informatique, marketing, design, finance, etc.).

### Modèle d'offre

```dart
class Internship {
  final String id;         // UUID
  final String title;
  final String company;
  final String description;
  final String domain;
  final String location;
  final String duration;
  final String internshipType;  // présentiel, distanciel, hybride
  final List<String> requiredSkills;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime applicationDeadline;
  final String recruiterId;
  final bool isActive;
}
```

---

## 10. Base de données SQLite

### Version actuelle : v6

La base de données utilise un système de migrations incrémentales :

| Version | Ajout |
|---------|-------|
| v1 | Table `users` |
| v2 | Tables `courses`, `chapters`, `resources`, `course_progress` |
| v3 | Tables `quizzes`, `questions`, `quiz_attempts` |
| v4 | Colonne `quizId` dans `resources` |
| v5 | Tables forum, messagerie, mentorat |
| v6 | Tables `internships`, `internship_applications` |

### Toutes les tables

```
users                     — Utilisateurs de l'application
courses                   — Catalogue des cours
chapters                  — Chapitres par cours
resources                 — Ressources (vidéo, PDF, texte, quiz)
course_progress           — Progression des étudiants par cours
quizzes                   — Quiz associés aux cours/chapitres
questions                 — Questions de quiz
quiz_attempts             — Tentatives de quiz par utilisateur
forum_posts               — Posts du forum
forum_comments            — Commentaires de forum
forum_likes               — Likes sur posts et commentaires
conversations             — Conversations de messagerie
messages                  — Messages dans les conversations
mentor_profiles           — Profils des mentors
mentorship_requests       — Demandes de mentorat
mentorship_sessions       — Sessions de mentorat planifiées
internships               — Offres de stage
internship_applications   — Candidatures aux stages
```

### Configuration multiplateforme

```dart
// main.dart
if (!kIsWeb) {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
```

- **Windows / Linux / macOS :** `sqflite_common_ffi` (SQLite via FFI)
- **Android / iOS :** `sqflite` natif
- **Web :** Base de données non disponible (limitation du navigateur)

### Index créés pour les performances

```sql
-- users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- courses
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_subject ON courses(subject);
CREATE INDEX idx_courses_language ON courses(language);

-- chapters / resources / progress
CREATE INDEX idx_chapters_courseId ON chapters(courseId);
CREATE INDEX idx_resources_chapterId ON resources(chapterId);
CREATE INDEX idx_resources_courseId ON resources(courseId);
CREATE INDEX idx_progress_userId ON course_progress(userId);
CREATE INDEX idx_progress_courseId ON course_progress(courseId);

-- quiz
CREATE INDEX idx_quizzes_courseId ON quizzes(courseId);
CREATE INDEX idx_questions_quizId ON questions(quizId);
CREATE INDEX idx_attempts_userId ON quiz_attempts(userId);

-- forum
CREATE INDEX idx_forum_posts_courseId ON forum_posts(courseId);
CREATE INDEX idx_forum_posts_authorId ON forum_posts(authorId);
CREATE INDEX idx_forum_comments_postId ON forum_comments(postId);

-- messages / mentorat
CREATE INDEX idx_messages_conversationId ON messages(conversationId);
CREATE INDEX idx_mentorship_requests_studentId ON mentorship_requests(studentId);
CREATE INDEX idx_mentorship_requests_mentorId ON mentorship_requests(mentorId);
```

---

## 11. Sécurité

### Mots de passe

- **Algorithme :** SHA-256 avec salt unique par utilisateur
- Jamais de stockage en clair
- Vérification par comparaison de hash

```dart
// PasswordHelper
static String hashPassword(String password) {
  final salt = uuid.v4();
  final combined = '$password$salt';
  final bytes = utf8.encode(combined);
  final hash = sha256.convert(bytes);
  return '${hash.toString()}:$salt';
}

static bool verifyPassword(String password, String storedHash) {
  final parts = storedHash.split(':');
  final salt = parts[1];
  final reHash = hashPassword(password, existingSalt: salt);
  return reHash == storedHash;
}
```

### Exigences du mot de passe

- Minimum 8 caractères
- Au moins 1 lettre majuscule
- Au moins 1 lettre minuscule
- Au moins 1 chiffre

### Stockage sécurisé

```dart
// flutter_secure_storage — chiffrement hardware
await _secureStorage.write(key: AppConstants.sessionKey, value: sessionJson);
await _secureStorage.write(key: AppConstants.tokenKey, value: token);
```

### Validation des formulaires

| Champ | Règle |
|-------|-------|
| Email | Format regex + unicité en base |
| Prénom/Nom | Lettres uniquement, min 2 caractères |
| Mot de passe | Exigences de complexité |
| Confirmation | Égalité avec le champ mot de passe |

### Soft Delete

Les utilisateurs supprimés ne sont pas effacés physiquement :

```sql
UPDATE users SET isActive = 0 WHERE id = ?;
```

Cela permet la restauration et conserve l'intégrité référentielle.

---

## 12. Fonctionnalités Bonus

### CAPTCHA mathématique

Le formulaire d'inscription intègre un CAPTCHA mathématique anti-bot :

- Génère deux nombres aléatoires entre 1 et 10
- Opération aléatoire : addition ou soustraction
- Résultat toujours positif
- Validation en temps réel avec feedback visuel
- Bouton de rafraîchissement pour nouvelle question
- Bouton "S'inscrire" désactivé jusqu'à résolution

```dart
class CaptchaWidget extends StatefulWidget {
  final Function(bool) onValidationChanged;
  final VoidCallback? onRefresh;
}
```

**États visuels :**

| État | Bordure | Message |
|------|---------|---------|
| Initial | Grise | — |
| Réponse correcte | Verte | ✅ Correct ! |
| Réponse incorrecte | Rouge | ❌ Réponse incorrecte |

### Tokens de réinitialisation

- Token unique généré via UUID v4
- Expiration après 1 heure
- Stocké en base (`resetToken`, `resetTokenExpiry`)
- Invalidé après utilisation

### Upload de fichiers locaux

- Sélection depuis l'appareil via `file_picker`
- Validation du type et de la taille
- Copie dans le répertoire privé de l'application
- URL scheme `local://` pour identification

### Localisation française

- Tous les textes de l'interface en français
- Format de dates localisé (`initializeDateFormatting('fr_FR')`)
- Messages d'erreur contextuels en français

---

## 13. Comptes de test

Les comptes suivants sont créés automatiquement au premier lancement :

### Administrateur

```
Email    : admin@edupalestine.com
Mot de passe : admin123
Rôle     : Administrateur
```

### Étudiant de test

```
Email    : ilyes@test.com
Mot de passe : password123
Rôle     : Étudiant
```

### Créer un nouveau compte

1. Lancer l'application
2. Cliquer sur "S'inscrire"
3. Remplir le formulaire
4. Résoudre le CAPTCHA
5. Choisir un rôle
6. Valider l'inscription

---

## 14. Résolution de problèmes

### Erreur : "No Visual Studio toolchain found"

**Cause :** Visual Studio Build Tools non installé  
**Solution :**
```powershell
winget install Microsoft.VisualStudio.2022.BuildTools
# Cocher : C++ Build Tools + VC.ATL
```

### Erreur : `atlstr.h` introuvable

**Cause :** Composant ATL non installé  
**Solution :**
```powershell
# Via l'installateur Visual Studio
# Ajouter : Microsoft.VisualStudio.Component.VC.ATL
```

### Erreur : "databaseFactory not initialized"

**Cause :** `sqfliteFfiInit()` non appelé sur desktop  
**Solution :** Vérifier le bloc d'initialisation dans `main.dart` :
```dart
if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

### Erreur : "Execution policy" (PowerShell)

**Cause :** Exécution de scripts `.ps1` bloquée  
**Solution :** Utiliser des commandes directes avec `;` au lieu de `&&` :
```powershell
flutter clean; flutter pub get; flutter run -d windows
```

### Erreur : "Unsupported operation: Platform._operatingSystem" (web)

**Cause :** `dart:io` non disponible dans le navigateur  
**Solution :** Utiliser `kIsWeb` avant tout appel à `Platform` :
```dart
import 'package:flutter/foundation.dart' show kIsWeb;
if (!kIsWeb) { /* code plateforme */ }
```

### Base de données corrompue

```powershell
# Supprimer les données de l'application et relancer
flutter clean; flutter run -d windows
```

### Performances lentes au premier lancement

Le premier build compile tout le code C++ natif via MSBuild. Durée estimée : 3–5 minutes. Les builds suivants prennent moins de 15 secondes.

---

## 🔄 Flux complet de l'application

```
Lancement
    └─→ SplashScreen (vérification session)
            ├─→ [Non connecté] LoginScreen
            │       ├─→ RegisterScreen (inscription + CAPTCHA)
            │       └─→ ForgotPasswordScreen (réinitialisation)
            │
            └─→ [Connecté] HomeScreen (tableau de bord)
                    ├─→ Cours
                    │     ├─→ CourseListScreen (filtres, recherche)
                    │     └─→ CourseDetailScreen
                    │           ├─→ Chapitres → Ressources
                    │           ├─→ VideoPlayerScreen
                    │           └─→ PdfViewerScreen
                    │
                    ├─→ Quiz
                    │     ├─→ QuizListScreen
                    │     ├─→ QuizViewScreen
                    │     └─→ QuizResultsScreen
                    │
                    ├─→ Communauté
                    │     ├─→ ForumListScreen
                    │     │     ├─→ ForumPostDetailScreen
                    │     │     └─→ ForumCreatePostScreen
                    │     ├─→ ConversationsScreen
                    │     │     └─→ ChatScreen
                    │     └─→ MentorListScreen
                    │           └─→ MentorshipRequestScreen
                    │
                    ├─→ Stages
                    │     ├─→ InternshipListScreen
                    │     ├─→ InternshipDetailScreen
                    │     └─→ InternshipFormScreen (recruteur)
                    │
                    └─→ Profil
                          ├─→ ProfileScreen (édition)
                          └─→ ChangePasswordScreen
```

---

## 📊 Statistiques du projet

| Métrique | Valeur |
|----------|--------|
| Modules fonctionnels | 5 |
| Tables SQLite | 18 |
| Écrans Flutter | ~30 |
| Packages utilisés | 20+ |
| Version base de données | v6 |
| Cours de démonstration | 8 |
| Offres de stage de démonstration | 10 |
| Lignes de code (estimation) | ~8 000 |

---

## 📝 Notes de version

### v1.0.0 — Novembre 2026

- ✅ Module 1 : Authentification complète avec CAPTCHA
- ✅ Module 2 : Cours, chapitres, vidéos, PDFs, progression
- ✅ Module 3 : Quiz avec 4 types de questions
- ✅ Module 4 : Forum, messagerie, mentorat
- ✅ Module 5 : Offres de stage et candidatures
- ✅ Compatibilité Windows Desktop (sqflite_common_ffi)
- ✅ Thème Palestine (vert #2E7D32 / rouge #E53935)
- ✅ Localisation française complète
- ✅ Données de démonstration pré-chargées

---

**Développé par Amine Abdellah — 2026**  
**Application EduPalestine v1.0.0**
