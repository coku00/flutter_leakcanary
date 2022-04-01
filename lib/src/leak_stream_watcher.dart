import 'dart:async';

import 'package:flutter_leakcanary/src/leak/leak_node.dart';

class LeakStream {
  static LeakStream? _leakWatcherStream;

  LeakStream._();

  static LeakStream getInstance() {
    if (_leakWatcherStream == null) {
      _leakWatcherStream = LeakStream._();
    }

    return _leakWatcherStream!;
  }

  StreamController<LeakNode> _streamController = StreamController.broadcast();

  void addLeakNode(LeakNode leakNode) {
    _streamController.add(leakNode);
  }

  void _closeStream() {
    _streamController.close();
  }

  Stream<LeakNode> get stream => _streamController.stream;
}
