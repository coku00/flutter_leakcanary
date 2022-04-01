import 'package:flutter_leakcanary/src/leak/leak_node.dart';
import 'package:flutter_leakcanary/src/leak/pares_leak.dart';
import 'package:flutter_leakcanary/src/leak_stream_watcher.dart';
import 'package:flutter_leakcanary/src/utils/log_util.dart';
import 'package:flutter_leakcanary/src/utils/object_util.dart';
import 'package:vm_service/vm_service.dart';

class LeakTask {
  Expando? expando;

  LeakTask(this.expando);

  Future<List<LeakNode>?> start({String? tag}) async {
    List<LeakNode>? leakNodes;
    if (expando == null) {
      print('checkLeak expando = null');
      return leakNodes;
    }

    await gc();

    var weakPropertyKeys = await getWeakKeyRefs(expando!);

    if (weakPropertyKeys.isEmpty) {
      expando = null;
      return null;
    }
    expando = null;

    await gc();

    for (int i = 0; i < weakPropertyKeys.length; i++) {
      InstanceRef instanceRef = weakPropertyKeys[i];
      if (instanceRef.id == 'objects/null') {
        print('checkLeak instanceRef = $instanceRef');
        break;
      }

      RetainingPath retainingPath = await getRetainingPath(instanceRef.id!);
      LeakNode? _leakInfoHead;
      LeakNode? pre;
      bool isBreak = false;
      for (var i = 0; i < retainingPath.elements!.length; i++) {
        RetainingObject p = retainingPath.elements![i];

        LeakNode current = LeakNode();

        bool skip = await parsers[p.value!.runtimeType]
                ?.paresRefSkip(p.value!, p.parentField, current) ??
            true;

        if (skip) {
          isBreak = true;
          break;
        }

        if (_leakInfoHead == null) {
          _leakInfoHead = current;
          pre = _leakInfoHead;
        } else {
          pre?.next = current;
          pre = current;
        }
      }

      if (isBreak) {
        break;
      }

      if (_leakInfoHead != null) {
        leakNodes?.add(_leakInfoHead);
        LeakStream.getInstance().addLeakNode(_leakInfoHead);
      }
    }

    return leakNodes;
  }
}
