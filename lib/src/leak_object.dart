import 'package:flutter_leakcanary/src/task/leak_task.dart';
import 'package:flutter_leakcanary/src/widgets/leak_observer.dart';

class LeakObject {
  static LeakObject _leakObject = LeakObject._();

  factory LeakObject() => _leakObject;

  LeakObject._();

  LeakWatcher leakObject(Object object) {
    _checkKey(object);
    LeakWatcher leakWatcher = LeakWatcher();
    leakWatcher._add(object);
    return leakWatcher;
  }
}

class LeakWatcher {
  Expando? _expando;

  void _add(Object object) {
    _expando = Expando();
    _expando![object] = true;
  }

  void start() {
    if (_expando != null) {
      Future.delayed(Duration(seconds: defaultCheckLeakDelay), () {
        print('开始检测 object');
        LeakTask(_expando).start(tag: 'object');
      });
    }
  }
}

void _checkKey(Object? object) {
  if (object is String || object is bool || object is num || object == null) {
    throw LeakWatchException('not support String, bool, num, null');
  }
}

class LeakWatchException implements Exception {
  String message;

  LeakWatchException(this.message);
}
