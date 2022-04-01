import 'package:flutter/cupertino.dart';

class LogUtil {
  static var _separator = "=";
  static var _split =
      "$_separator$_separator$_separator$_separator$_separator$_separator$_separator$_separator$_separator";
  static var _title = "Log -- start";
  static var _isDebug = true;
  static int _limitLength = 800;
  static String _startLine = "$_split$_title$_split";
  static String _endLine = "$_split$_separator$_separator$_separator$_split";



  //仅Debug模式可见
  static void d(dynamic obj) {
    if (_isDebug) {
      _log(obj.toString());
    }
  }

  static void v(dynamic obj) {
    _log(obj.toString());
  }

  static void _log(String msg) {
    print("$_startLine");
    _logEmpyLine();
    if(msg.length<_limitLength){
      print(msg);
    }else{
      segmentationLog(msg);
    }
    _logEmpyLine();
    print("$_endLine");
  }

  static void segmentationLog(String msg) {
    var outStr = StringBuffer();
    outStr.write('        ');
    for (var index = 0; index < msg.length; index++) {
      outStr.write(msg[index]);
      if (index % _limitLength == 0 && index!=0) {
        print(outStr);
        outStr.clear();
        var lastIndex = index+1;
        if(msg.length-lastIndex<_limitLength){
          var remainderStr = msg.substring(lastIndex,msg.length);
          print(remainderStr);
          break;
        }
      }
    }
  }

  static void _logEmpyLine(){
    print("");
  }
}

