import 'package:flutter/foundation.dart';
import '../data/models/internship.dart';
import '../data/models/internship_application.dart';
import '../data/repositories/internship_repository.dart';

/// Provider pour la gestion des offres de stage (Module 5)
class InternshipProvider with ChangeNotifier {
  final InternshipRepository _repository = InternshipRepository();

  List<Internship> _internships = [];
  List<InternshipApplication> _applications = [];
  bool _isLoading = false;
  String? _error;

  // Filtres actifs
  String? _selectedDomain;
  String? _selectedLocation;
  String? _selectedDuration;
  String? _selectedType;
  String _searchQuery = '';

  // Getters
  List<Internship> get internships => _internships;
  List<InternshipApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedDomain => _selectedDomain;
  String? get selectedLocation => _selectedLocation;
  String? get selectedDuration => _selectedDuration;
  String? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  /// F5.1.1 & F5.2.2 - Charger toutes les offres actives
  Future<void> loadInternships() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _internships = await _repository.getAllActiveInternships();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des offres: $e';
      _internships = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// F5.1.2 - Filtrer les offres
  Future<void> filterInternships({
    String? domain,
    String? location,
    String? duration,
    String? type,
  }) async {
    _selectedDomain = domain;
    _selectedLocation = location;
    _selectedDuration = duration;
    _selectedType = type;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _internships = await _repository.filterInternships(
        domain: domain,
        location: location,
        duration: duration,
        internshipType: type,
      );
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du filtrage: $e';
      _internships = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// F5.1.3 - Rechercher des offres
  Future<void> searchInternships(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      await loadInternships();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _internships = await _repository.searchInternships(query);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
      _internships = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialiser les filtres
  void clearFilters() {
    _selectedDomain = null;
    _selectedLocation = null;
    _selectedDuration = null;
    _selectedType = null;
    _searchQuery = '';
    loadInternships();
  }

  /// F5.2.1 - Créer une offre (Admin/Recruteur)
  Future<bool> createInternship(Internship internship) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createInternship(internship);
      await loadInternships();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Erreur lors de la création: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// F5.2.3 - Mettre à jour une offre
  Future<bool> updateInternship(Internship internship) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateInternship(internship);
      await loadInternships();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// F5.2.3 - Supprimer une offre
  Future<bool> deleteInternship(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteInternship(id);
      _internships.removeWhere((internship) => internship.id == id);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ GESTION DES CANDIDATURES ============

  /// F5.1.5 - Postuler à une offre
  Future<bool> applyToInternship({
    required String internshipId,
    required String studentId,
    String? coverLetter,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier si déjà postulé
      final hasApplied = await _repository.hasApplied(internshipId, studentId);
      if (hasApplied) {
        _error = 'Vous avez déjà postulé à cette offre';
        return false;
      }

      final application = InternshipApplication.create(
        internshipId: internshipId,
        studentId: studentId,
        coverLetter: coverLetter,
      );

      await _repository.applyToInternship(application);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Erreur lors de la candidature: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les candidatures d'un étudiant
  Future<void> loadStudentApplications(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await _repository.getStudentApplications(studentId);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des candidatures: $e';
      _applications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vérifier si l'étudiant a postulé
  Future<bool> hasApplied(String internshipId, String studentId) async {
    try {
      return await _repository.hasApplied(internshipId, studentId);
    } catch (e) {
      return false;
    }
  }

  /// Récupérer les candidatures pour une offre (Recruteur)
  Future<List<InternshipApplication>> getInternshipApplications(String internshipId) async {
    try {
      return await _repository.getInternshipApplications(internshipId);
    } catch (e) {
      return [];
    }
  }

  /// Mettre à jour le statut d'une candidature (Recruteur)
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    try {
      await _repository.updateApplicationStatus(applicationId, status);
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      return false;
    }
  }
}
