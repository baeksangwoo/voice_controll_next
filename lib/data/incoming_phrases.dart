import 'package:flutter/material.dart';
class IncomingPhrases extends ChangeNotifier{
  String _phrases = "";

  String get phrases => _phrases;

  PageNextActions _nextActions = PageNextActions.idle;

  void setPhrases(String value){
    if(_phrases == value){
      return;
    }

    _phrases = value;

    if(_phrases.split(" ").last.contains('다음')){
      _nextActions = PageNextActions.next;
    }else if(_phrases.split(" ").last.contains('이전')){
      _nextActions = PageNextActions.prev;

    }
    notifyListeners();
  }

  PageNextActions get action => _nextActions;

  void resetAction(){
    _nextActions = PageNextActions.idle;
  }

}

enum PageNextActions{ prev, next, idle}