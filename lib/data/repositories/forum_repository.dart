import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';
import '../../core/constants/app_constants.dart';

/// Repository for forum operations - Module 4
class ForumRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== FORUM POSTS ====================

  /// Get all posts for a course
  Future<List<ForumPost>> getPostsByCourse(int courseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumPosts,
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return maps.map((map) => ForumPost.fromMap(map)).toList();
  }

  /// Get posts by chapter
  Future<List<ForumPost>> getPostsByChapter(int chapterId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumPosts,
      where: 'chapterId = ?',
      whereArgs: [chapterId],
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return maps.map((map) => ForumPost.fromMap(map)).toList();
  }

  /// Get a specific post by ID
  Future<ForumPost?> getPostById(int postId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumPosts,
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return ForumPost.fromMap(maps.first);
  }

  /// Search posts by keywords
  Future<List<ForumPost>> searchPosts(int courseId, String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumPosts,
      where: 'courseId = ? AND (title LIKE ? OR content LIKE ? OR tags LIKE ?)',
      whereArgs: [courseId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => ForumPost.fromMap(map)).toList();
  }

  /// Filter posts by tags
  Future<List<ForumPost>> getPostsByTags(int courseId, List<String> tags) async {
    final db = await _dbHelper.database;
    
    // Build WHERE clause for tags
    final tagConditions = tags.map((tag) => 'tags LIKE ?').join(' OR ');
    final tagArgs = tags.map((tag) => '%$tag%').toList();
    
    final maps = await db.query(
      AppConstants.tableForumPosts,
      where: 'courseId = ? AND ($tagConditions)',
      whereArgs: [courseId, ...tagArgs],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => ForumPost.fromMap(map)).toList();
  }

  /// Get posts by author
  Future<List<ForumPost>> getPostsByAuthor(String authorId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumPosts,
      where: 'authorId = ?',
      whereArgs: [authorId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => ForumPost.fromMap(map)).toList();
  }

  /// Create a new post
  Future<int> createPost(ForumPost post) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableForumPosts,
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a post
  Future<int> updatePost(ForumPost post) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableForumPosts,
      post.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  /// Delete a post
  Future<int> deletePost(int postId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableForumPosts,
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  /// Increment likes count
  Future<void> incrementLikes(int postId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableForumPosts} SET likesCount = likesCount + 1 WHERE id = ?',
      [postId],
    );
  }

  /// Decrement likes count
  Future<void> decrementLikes(int postId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableForumPosts} SET likesCount = likesCount - 1 WHERE id = ? AND likesCount > 0',
      [postId],
    );
  }

  /// Increment comments count
  Future<void> incrementComments(int postId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableForumPosts} SET commentsCount = commentsCount + 1 WHERE id = ?',
      [postId],
    );
  }

  /// Mark post as solved
  Future<void> markAsSolved(int postId) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableForumPosts,
      {'isSolved': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  // ==================== FORUM COMMENTS ====================

  /// Get comments for a post
  Future<List<ForumComment>> getCommentsByPost(int postId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumComments,
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: 'isAccepted DESC, createdAt ASC',
    );
    return maps.map((map) => ForumComment.fromMap(map)).toList();
  }

  /// Get a specific comment by ID
  Future<ForumComment?> getCommentById(int commentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumComments,
      where: 'id = ?',
      whereArgs: [commentId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return ForumComment.fromMap(maps.first);
  }

  /// Create a new comment
  Future<int> createComment(ForumComment comment) async {
    final db = await _dbHelper.database;
    final commentId = await db.insert(
      AppConstants.tableForumComments,
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Increment post's comments count
    await incrementComments(comment.postId);
    
    return commentId;
  }

  /// Update a comment
  Future<int> updateComment(ForumComment comment) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableForumComments,
      comment.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [comment.id],
    );
  }

  /// Delete a comment
  Future<int> deleteComment(int commentId) async {
    final db = await _dbHelper.database;
    
    // Get comment to know which post to update
    final comment = await getCommentById(commentId);
    
    final result = await db.delete(
      AppConstants.tableForumComments,
      where: 'id = ?',
      whereArgs: [commentId],
    );
    
    // Decrement post's comments count if comment was deleted
    if (result > 0 && comment != null) {
      await db.rawUpdate(
        'UPDATE ${AppConstants.tableForumPosts} SET commentsCount = commentsCount - 1 WHERE id = ? AND commentsCount > 0',
        [comment.postId],
      );
    }
    
    return result;
  }

  /// Increment comment likes count
  Future<void> incrementCommentLikes(int commentId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableForumComments} SET likesCount = likesCount + 1 WHERE id = ?',
      [commentId],
    );
  }

  /// Decrement comment likes count
  Future<void> decrementCommentLikes(int commentId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableForumComments} SET likesCount = likesCount - 1 WHERE id = ? AND likesCount > 0',
      [commentId],
    );
  }

  /// Mark comment as accepted answer
  Future<void> acceptComment(int commentId, int postId) async {
    final db = await _dbHelper.database;
    
    // First, unaccept all other comments on this post
    await db.update(
      AppConstants.tableForumComments,
      {'isAccepted': 0},
      where: 'postId = ?',
      whereArgs: [postId],
    );
    
    // Then accept this comment
    await db.update(
      AppConstants.tableForumComments,
      {'isAccepted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [commentId],
    );
    
    // Mark post as solved
    await markAsSolved(postId);
  }

  // ==================== LIKES ====================

  /// Check if user liked a post
  Future<bool> hasUserLikedPost(String userId, int postId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumLikes,
      where: 'userId = ? AND postId = ?',
      whereArgs: [userId, postId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// Check if user liked a comment
  Future<bool> hasUserLikedComment(String userId, int commentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableForumLikes,
      where: 'userId = ? AND commentId = ?',
      whereArgs: [userId, commentId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// Like a post
  Future<void> likePost(String userId, int postId) async {
    final db = await _dbHelper.database;
    
    try {
      await db.insert(
        AppConstants.tableForumLikes,
        {
          'userId': userId,
          'postId': postId,
          'commentId': null,
          'createdAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      
      await incrementLikes(postId);
    } catch (e) {
      // Already liked - ignore
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String userId, int postId) async {
    final db = await _dbHelper.database;
    
    final result = await db.delete(
      AppConstants.tableForumLikes,
      where: 'userId = ? AND postId = ?',
      whereArgs: [userId, postId],
    );
    
    if (result > 0) {
      await decrementLikes(postId);
    }
  }

  /// Like a comment
  Future<void> likeComment(String userId, int commentId) async {
    final db = await _dbHelper.database;
    
    try {
      await db.insert(
        AppConstants.tableForumLikes,
        {
          'userId': userId,
          'postId': null,
          'commentId': commentId,
          'createdAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      
      await incrementCommentLikes(commentId);
    } catch (e) {
      // Already liked - ignore
    }
  }

  /// Unlike a comment
  Future<void> unlikeComment(String userId, int commentId) async {
    final db = await _dbHelper.database;
    
    final result = await db.delete(
      AppConstants.tableForumLikes,
      where: 'userId = ? AND commentId = ?',
      whereArgs: [userId, commentId],
    );
    
    if (result > 0) {
      await decrementCommentLikes(commentId);
    }
  }
}
