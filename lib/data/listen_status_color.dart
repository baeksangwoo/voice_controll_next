import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
class ListenStatusColor extends ChangeNotifier{

  bool _listening;
  Color _color = Colors.redAccent;

  Color get color => _color;

  void setColor(bool listening){
    if(listening == _listening) return;
    print('listening - listeing');
    _listening = listening;
    _color = listening ? Colors.greenAccent : Colors.redAccent;
    notifyListeners();
  }
}