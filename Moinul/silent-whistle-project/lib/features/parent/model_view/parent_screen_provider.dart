import 'package:flutter/cupertino.dart';

class ParentScreenProvider extends ChangeNotifier {
  int selectIndex = 0;

  setIndex(int index) {
    selectIndex = index;
    notifyListeners();
  }
}
