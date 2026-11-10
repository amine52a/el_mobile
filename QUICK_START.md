# 🚀 Guide de Démarrage Rapide - EduPalestine

## Prérequis Installés ✅
- Flutter SDK
- Android Studio / VS Code
- Git

## 📦 Installation Déjà Effectuée

Les dépendances ont déjà été installées avec `flutter pub get`.

## 🎯 Lancer l'Application

### Option 1: Windows Desktop (Recommandé pour tester)
```powershell
flutter run -d windows
```

### Option 2: Chrome (Web)
```powershell
flutter run -d chrome
```

### Option 3: Android Emulator
1. Démarrer un émulateur Android depuis Android Studio
2. Exécuter:
```powershell
flutter run
```

### Option 4: Appareil Physique
1. Connecter votre téléphone en mode développeur
2. Activer le débogage USB
3. Exécuter:
```powershell
flutter run
```

## 🧪 Tester l'Application

### 1. Créer un Compte
- Cliquer sur "S'inscrire"
- Email: `test@exemple.com`
- Prénom: `Test`
- Nom: `User`
- Rôle: `Étudiant`
- Mot de passe: `Test1234` (respecte les exigences)
- Confirmer le mot de passe

### 2. Se Connecter
- Email: `test@exemple.com`
- Mot de passe: `Test1234`

### 3. Explorer l'Application
- ✅ Dashboard avec statistiques
- ✅ Profil utilisateur
- ✅ Modification du profil
- ✅ Changement de mot de passe

### 4. Tester le Mot de Passe Oublié
1. Déconnectez-vous
2. Cliquez sur "Mot de passe oublié ?"
3. Entrez l'email
4. Le code de réinitialisation s'affichera dans un message
5. Copiez le code et créez un nouveau mot de passe

## 🐛 Résolution de Problèmes

### Problème: "No devices found"
**Solution**: Choisissez un appareil spécifique:
```powershell
flutter run -d windows   # Pour Windows
flutter run -d chrome    # Pour navigateur
```

### Problème: Erreurs de build
**Solution**: Nettoyer et reconstruire:
```powershell
flutter clean
flutter pub get
flutter run
```

### Problème: Base de données corrompue
**Solution**: Supprimer l'application et la réinstaller

## 📱 Structure de Test

### Comptes de Test Suggérés

**Étudiant**
- Email: `etudiant@edupalestine.com`
- Mot de passe: `Etudiant123`
- Rôle: Étudiant

**Mentor**
- Email: `mentor@edupalestine.com`
- Mot de passe: `Mentor123`
- Rôle: Mentor

**Administrateur**
- Email: `admin@edupalestine.com`
- Mot de passe: `Admin123`
- Rôle: Administrateur

## ✅ Fonctionnalités à Tester

- [ ] Inscription avec validation
- [ ] Connexion
- [ ] Affichage du profil
- [ ] Modification du profil
- [ ] Changement de mot de passe
- [ ] Mot de passe oublié
- [ ] Déconnexion
- [ ] Persistance de session (fermer et rouvrir l'app)

## 📊 Performance

L'application devrait:
- Se lancer en < 2 secondes
- Connexion en < 2 secondes
- Navigation fluide sans lag

## 🎨 Thème

L'application utilise les couleurs du drapeau palestinien:
- Vert: #2E7D32
- Rouge: #E53935

## 📞 Support

Pour toute question:
1. Consulter `DOCUMENTATION_MODULE_AUTH.md`
2. Vérifier les erreurs dans le terminal
3. Contacter l'équipe de développement

---

**Bon développement ! 🇵🇸**
