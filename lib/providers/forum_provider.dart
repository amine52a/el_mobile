import 'package:flutter/foundation.dart';
import '../data/models/forum_post.dart';
import '../data/models/forum_comment.dart';
import '../data/repositories/forum_repository.dart';

/// Provider for forum state management - Module 4
class ForumProvider with ChangeNotifier {
  final ForumRepository _repository = ForumRepository();

  // State
  List<ForumPost> _posts = [];
  ForumPost? _currentPost;
  List<ForumComment> _comments = [];
  bool _isLoading = false;
  String? _error;

  // Current filters
  int? _currentCourseId;
  int? _currentChapterId;
  String? _searchQuery;
  List<String> _filterTags = [];

  // Getters
  List<ForumPost> get posts => _posts;
  ForumPost? get currentPost => _currentPost;
  List<ForumComment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentCourseId => _currentCourseId;

  // ==================== POSTS ====================

  /// Load posts for a course
  Future<void> loadPostsByCourse(int courseId, {bool refresh = false}) async {
    if (_currentCourseId == courseId && !refresh && _posts.isNotEmpty) {
      return; // Already loaded
    }

    _isLoading = true;
    _error = null;
    _currentCourseId = courseId;
    _currentChapterId = null;
    _searchQuery = null;
    _filterTags = [];
    notifyListeners();

    try {
      _posts = await _repository.getPostsByCourse(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des discussions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load posts for a chapter
  Future<void> loadPostsByChapter(int chapterId) async {
    _isLoading = true;
    _error = null;
    _currentChapterId = chapterId;
    _searchQuery = null;
    _filterTags = [];
    notifyListeners();

    try {
      _posts = await _repository.getPostsByChapter(chapterId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des discussions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search posts
  Future<void> searchPosts(int courseId, String query) async {
    if (query.isEmpty) {
      await loadPostsByCourse(courseId, refresh: true);
      return;
    }

    _isLoading = true;
    _error = null;
    _searchQuery = query;
    notifyListeners();

    try {
      _posts = await _repository.searchPosts(courseId, query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter posts by tags
  Future<void> filterByTags(int courseId, List<String> tags) async {
    if (tags.isEmpty) {
      await loadPostsByCourse(courseId, refresh: true);
      return;
    }

    _isLoading = true;
    _error = null;
    _filterTags = tags;
    notifyListeners();

    try {
      _posts = await _repository.getPostsByTags(courseId, tags);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du filtrage: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific post
  Future<void> loadPost(int postId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPost = await _repository.getPostById(postId);
      if (_currentPost != null) {
        await loadComments(postId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement de la discussion: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new post
  Future<int?> createPost(ForumPost post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final postId = await _repository.createPost(post);
      
      // Reload posts list
      if (_currentCourseId != null) {
        await loadPostsByCourse(_currentCourseId!, refresh: true);
      }
      
      _isLoading = false;
      notifyListeners();
      return postId;
    } catch (e) {
      _error = 'Erreur lors de la création de la discussion: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update a post
  Future<bool> updatePost(ForumPost post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updatePost(post);
      
      // Update in list
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(updatedAt: DateTime.now());
      }
      
      // Update current post if it's the same
      if (_currentPost?.id == post.id) {
        _currentPost = post.copyWith(updatedAt: DateTime.now());
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a post
  Future<bool> deletePost(int postId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deletePost(postId);
      
      // Remove from list
      _posts.removeWhere((p) => p.id == postId);
      
      // Clear current post if it's the deleted one
      if (_currentPost?.id == postId) {
        _currentPost = null;
        _comments = [];
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Like/Unlike a post
  Future<void> togglePostLike(String userId, int postId) async {
    try {
      final hasLiked = await _repository.hasUserLikedPost(userId, postId);
      
      if (hasLiked) {
        await _repository.unlikePost(userId, postId);
        // Update local state
        _updatePostLikes(postId, -1);
      } else {
        await _repository.likePost(userId, postId);
        // Update local state
        _updatePostLikes(postId, 1);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du like: $e';
      notifyListeners();
    }
  }

  /// Helper to update post likes count locally
  void _updatePostLikes(int postId, int delta) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        likesCount: _posts[index].likesCount + delta,
      );
    }
    
    if (_currentPost?.id == postId) {
      _currentPost = _currentPost!.copyWith(
        likesCount: _currentPost!.likesCount + delta,
      );
    }
  }

  // ==================== COMMENTS ====================

  /// Load comments for a post
  Future<void> loadComments(int postId) async {
    try {
      _comments = await _repository.getCommentsByPost(postId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des commentaires: $e';
      notifyListeners();
    }
  }

  /// Create a new comment
  Future<int?> createComment(ForumComment comment) async {
    try {
      final commentId = await _repository.createComment(comment);
      
      // Reload comments
      await loadComments(comment.postId);
      
      // Update post's comments count
      if (_currentPost?.id == comment.postId) {
        _currentPost = _currentPost!.copyWith(
          commentsCount: _currentPost!.commentsCount + 1,
        );
      }
      
      notifyListeners();
      return commentId;
    } catch (e) {
      _error = 'Erreur lors de la création du commentaire: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update a comment
  Future<bool> updateComment(ForumComment comment) async {
    try {
      await _repository.updateComment(comment);
      
      // Update in list
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        _comments[index] = comment.copyWith(updatedAt: DateTime.now());
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(int commentId, int postId) async {
    try {
      await _repository.deleteComment(commentId);
      
      // Remove from list
      _comments.removeWhere((c) => c.id == commentId);
      
      // Update post's comments count
      if (_currentPost?.id == postId) {
        _currentPost = _currentPost!.copyWith(
          commentsCount: _currentPost!.commentsCount - 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      return false;
    }
  }

  /// Like/Unlike a comment
  Future<void> toggleCommentLike(String userId, int commentId) async {
    try {
      final hasLiked = await _repository.hasUserLikedComment(userId, commentId);
      
      if (hasLiked) {
        await _repository.unlikeComment(userId, commentId);
        // Update local state
        _updateCommentLikes(commentId, -1);
      } else {
        await _repository.likeComment(userId, commentId);
        // Update local state
        _updateCommentLikes(commentId, 1);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du like: $e';
      notifyListeners();
    }
  }

  /// Helper to update comment likes count locally
  void _updateCommentLikes(int commentId, int delta) {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      _comments[index] = _comments[index].copyWith(
        likesCount: _comments[index].likesCount + delta,
      );
    }
  }

  /// Accept a comment as the answer
  Future<bool> acceptComment(int commentId, int postId) async {
    try {
      await _repository.acceptComment(commentId, postId);
      
      // Update comments list
      for (int i = 0; i < _comments.length; i++) {
        _comments[i] = _comments[i].copyWith(
          isAccepted: _comments[i].id == commentId,
        );
      }
      
      // Mark post as solved
      if (_currentPost?.id == postId) {
        _currentPost = _currentPost!.copyWith(isSolved: true);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'acceptation: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== UTILITIES ====================

  /// Clear current post and comments
  void clearCurrentPost() {
    _currentPost = null;
    _comments = [];
    notifyListeners();
  }

  /// Check if user has liked a post
  Future<bool> hasUserLikedPost(String userId, int postId) async {
    return await _repository.hasUserLikedPost(userId, postId);
  }

  /// Check if user has liked a comment
  Future<bool> hasUserLikedComment(String userId, int commentId) async {
    return await _repository.hasUserLikedComment(userId, commentId);
  }
}
