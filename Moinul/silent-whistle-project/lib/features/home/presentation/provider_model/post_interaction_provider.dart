import 'package:flutter/material.dart';
import 'package:jwells/features/home/presentation/provider_model/_unliked_provider.dart';
import 'package:provider/provider.dart';
import 'package:jwells/features/home/presentation/provider_model/_isLiked_provider_model.dart';


class PostInteractionProvider extends ChangeNotifier {
  bool isLiked;
  int likeCount;


  PostInteractionProvider({
    required this.isLiked,
    required this.likeCount,
  });

  Future<void> handleLikeAction(BuildContext context, String postId) async {

    if (isLiked) {

      isLiked = false;
      likeCount--;
    } else {
 
      isLiked = true;
      likeCount++;
    }

    notifyListeners(); 

    bool success;


    if (isLiked) {
 
      success = await Provider.of<isLikedProvider>(context, listen: false)
          .isliked(id: postId);
    } else {
    
      success = await Provider.of<unLikedProvider>(context, listen: false)
          .isliked(id: postId);
    }

 
    if (!success) {
      if (isLiked) {
        isLiked = false;
        likeCount--;
      } else {
        isLiked = true;
        likeCount++;
      }
      notifyListeners(); 
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Action failed, please try again")),
        );
      }
    }
  }
}