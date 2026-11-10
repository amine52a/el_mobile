import '../data/models/forum_post.dart';
import '../data/models/forum_comment.dart';
import '../data/repositories/forum_repository.dart';

/// Service for managing forum-related business logic - Module 4
class ForumService {
  final ForumRepository _repository = ForumRepository();

  // ==================== FORUM POSTS METHODS ====================

  /// Get all posts for a specific course
  Future<List<ForumPost>> getPostsByCourse(int courseId) async {
    return await _repository.getPostsByCourse(courseId);
  }

  /// Get posts for a specific chapter
  Future<List<ForumPost>> getPostsByChapter(int chapterId) async {
    return await _repository.getPostsByChapter(chapterId);
  }

  /// Get a specific post by ID
  Future<ForumPost?> getPostById(int postId) async {
    return await _repository.getPostById(postId);
  }

  /// Search posts within a course
  Future<List<ForumPost>> searchPosts(int courseId, String query) async {
    if (query.trim().isEmpty) {
      return await getPostsByCourse(courseId);
    }
    return await _repository.searchPosts(courseId, query);
  }

  /// Filter posts by tags
  Future<List<ForumPost>> getPostsByTags(
      int courseId, List<String> tags) async {
    return await _repository.getPostsByTags(courseId, tags);
  }

  /// Get all posts by a specific author
  Future<List<ForumPost>> getPostsByAuthor(String authorId) async {
    return await _repository.getPostsByAuthor(authorId);
  }

  /// Create a new forum post
  Future<int> createPost({
    required String authorId,
    required String authorName,

    required int courseId,
    int? chapterId,
    required String title,
    required String content,
    List<String> tags = const [],
    bool isPinned = false,
  }) async {
    final post = ForumPost(
      authorId: authorId,
      authorName: authorName,

      courseId: courseId,
      chapterId: chapterId,
      title: title,
      content: content,
      tags: tags,
      isPinned: isPinned,
    );

    return await _repository.createPost(post);
  }

  /// Update an existing post
  Future<bool> updatePost(ForumPost post) async {
    final result = await _repository.updatePost(post);
    return result > 0;
  }

  /// Delete a post
  Future<bool> deletePost(int postId) async {
    final result = await _repository.deletePost(postId);
    return result > 0;
  }

  /// Mark a post as solved (for Q&A posts)
  Future<void> markPostAsSolved(int postId) async {
    await _repository.markAsSolved(postId);
  }

  /// Toggle like on a post
  Future<void> togglePostLike(String userId, int postId) async {
    final hasLiked = await _repository.hasUserLikedPost(userId, postId);
    
    if (hasLiked) {
      await _repository.unlikePost(userId, postId);
    } else {
      await _repository.likePost(userId, postId);
    }
  }

  /// Check if user has liked a post
  Future<bool> hasUserLikedPost(String userId, int postId) async {
    return await _repository.hasUserLikedPost(userId, postId);
  }

  // ==================== COMMENTS METHODS ====================

  /// Get all comments for a post
  Future<List<ForumComment>> getCommentsByPost(int postId) async {
    return await _repository.getCommentsByPost(postId);
  }

  /// Get a specific comment by ID
  Future<ForumComment?> getCommentById(int commentId) async {
    return await _repository.getCommentById(commentId);
  }

  /// Create a new comment on a post
  Future<int> createComment({
    required int postId,
    required String authorId,
    required String authorName,

    required String content,
  }) async {
    final comment = ForumComment(
      postId: postId,
      authorId: authorId,
      authorName: authorName,

      content: content,
    );

    return await _repository.createComment(comment);
  }

  /// Update an existing comment
  Future<bool> updateComment(ForumComment comment) async {
    final result = await _repository.updateComment(comment);
    return result > 0;
  }

  /// Delete a comment
  Future<bool> deleteComment(int commentId) async {
    final result = await _repository.deleteComment(commentId);
    return result > 0;
  }

  /// Toggle like on a comment
  Future<void> toggleCommentLike(String userId, int commentId) async {
    final hasLiked = await _repository.hasUserLikedComment(userId, commentId);
    
    if (hasLiked) {
      await _repository.unlikeComment(userId, commentId);
    } else {
      await _repository.likeComment(userId, commentId);
    }
  }

  /// Check if user has liked a comment
  Future<bool> hasUserLikedComment(String userId, int commentId) async {
    return await _repository.hasUserLikedComment(userId, commentId);
  }

  /// Accept a comment as the answer (for Q&A posts)
  Future<void> acceptComment(int commentId, int postId) async {
    await _repository.acceptComment(commentId, postId);
  }

  // ==================== UTILITY METHODS ====================

  /// Get post statistics
  Future<Map<String, int>> getPostStats(int postId) async {
    final post = await getPostById(postId);
    if (post == null) {
      return {
        'likes': 0,
        'comments': 0,
      };
    }

    return {
      'likes': post.likesCount,
      'comments': post.commentsCount,
    };
  }

  /// Get user's contribution stats
  Future<Map<String, int>> getUserStats(String userId) async {
    final posts = await getPostsByAuthor(userId);
    
    int totalLikes = 0;
    int totalComments = 0;
    
    for (var post in posts) {
      totalLikes += post.likesCount;
      totalComments += post.commentsCount;
    }

    return {
      'totalPosts': posts.length,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
    };
  }

  /// Get trending posts (most liked in last 7 days)
  Future<List<ForumPost>> getTrendingPosts(int courseId) async {
    final allPosts = await getPostsByCourse(courseId);
    
    // Filter posts from last 7 days
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentPosts = allPosts.where((post) => 
      post.createdAt.isAfter(sevenDaysAgo)
    ).toList();
    
    // Sort by likes count (descending)
    recentPosts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    
    // Return top 10
    return recentPosts.take(10).toList();
  }

  /// Get unanswered posts
  Future<List<ForumPost>> getUnansweredPosts(int courseId) async {
    final allPosts = await getPostsByCourse(courseId);
    
    // Filter posts with no comments and not solved
    return allPosts.where((post) => 
      !post.isSolved && post.commentsCount == 0
    ).toList();
  }

  /// Get solved posts
  Future<List<ForumPost>> getSolvedPosts(int courseId) async {
    final allPosts = await getPostsByCourse(courseId);
    return allPosts.where((post) => post.isSolved).toList();
  }
}

