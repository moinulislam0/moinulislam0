import 'package:flutter/foundation.dart';

import '../../data/model/home_banner.dart';
import '../../data/model/home_product_model.dart';
import '../../data/model/home_user_model.dart';
import '../../domain/repositories/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  List<String> _homeTab = ["All", "Concerts", "Ideas", "Messages"];
  int _selectedIndex = 0;

  List<String> get homeTab => _homeTab;
  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Example data for each tab
  List<String> getContentForTab() {
    switch (_selectedIndex) {
      case 0:
        return ["All item 1", "All item 2", "All item 3"];
      case 1:
        return ["Concert 1", "Concert 2", "Concert 3"];
      case 2:
        return ["Idea 1", "Idea 2"];
      case 3:
        return ["Message 1", "Message 2", "Message 3", "Message 4"];
      default:
        return [];
    }
  }
}
