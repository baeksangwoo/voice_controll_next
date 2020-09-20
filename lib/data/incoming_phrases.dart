import 'package:flutter/material.dart';
class IncomingPhrases extends ChangeNotifier{
  String _phrases = "";

  String get phrases => _phrases;

  void setPhrases(String value){
    _phrases = value;
    notifyListeners();
  }
}