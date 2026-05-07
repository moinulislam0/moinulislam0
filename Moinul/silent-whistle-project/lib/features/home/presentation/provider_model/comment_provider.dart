import 'package:flutter/material.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart';

class CommentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<CommentObj> _comments = [];
  List<CommentObj> get comments => _comments;

  bool _isLoading = false;
  bool get isLoading => _isLoading; // এই গেটারটি মিসিং ছিল

  bool _isPosting = false;
  bool get isPosting => _isPosting;

  // কমেন্ট লিস্ট ফেচ করার মেথড
  Future<void> fetchComments(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndPoints.comment(postId));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? [];
        _comments = data.map((json) => CommentObj.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // নতুন কমেন্ট পোস্ট করার মেথড (৪০০ এরর ফিক্স করা হয়েছে)
  Future<bool> postComment(String postId, String content) async {
    _isPosting = true;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndPoints.comment(postId),
        data: {
          // "shout_id" পাঠানো যাবে না, শুধু content পাঠাতে হবে
          "content": content
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newComment = CommentObj.fromJson(response.data['data']);
        _comments.insert(0, newComment);
        return true;
      }
    } catch (e) {
      debugPrint("Error posting comment: $e");
    } finally {
      _isPosting = false;
      notifyListeners();
    }
    return false;
  }

  // --- লোকাল লিস্ট আপডেট করার মেথডগুলো ---
  void addRepliesToLocalList(String parentId, List<CommentObj> fetchedReplies) {
    _comments = _updateRepliesRecursive(_comments, parentId, fetchedReplies);
    notifyListeners();
  }

  void addReplyToLocalList(String parentId, CommentObj newReply) {
    _comments = _appendSingleReplyRecursive(_comments, parentId, newReply);
    notifyListeners();
  }

  List<CommentObj> _updateRepliesRecursive(List<CommentObj> list, String targetId, List<CommentObj> newReplies) {
    return list.map((comment) {
      if (comment.id == targetId) return comment.copyWith(replies: newReplies);
      if (comment.replies.isNotEmpty) return comment.copyWith(replies: _updateRepliesRecursive(comment.replies, targetId, newReplies));
      return comment;
    }).toList();
  }

  List<CommentObj> _appendSingleReplyRecursive(List<CommentObj> list, String targetId, CommentObj newReply) {
    return list.map((comment) {
      if (comment.id == targetId) return comment.copyWith(replies: [...comment.replies, newReply], repliesCount: (comment.repliesCount) + 1);
      if (comment.replies.isNotEmpty) return comment.copyWith(replies: _appendSingleReplyRecursive(comment.replies, targetId, newReply));
      return comment;
    }).toList();
  }
}