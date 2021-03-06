import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_leakcanary/src/leak/leak_node.dart';
import 'package:flutter_leakcanary/src/leak_stream_watcher.dart';
import 'package:flutter_leakcanary/src/task/leak_task.dart';
import 'package:flutter_leakcanary/src/utils/log_util.dart';
import 'package:flutter_leakcanary/src/widgets/leak_widget.dart';

import 'bottom_route.dart';

const int defaultCheckLeakDelay = 15;

typedef ShouldAddedRoute = bool Function(Route route);

class LeakObserver extends NavigatorObserver {
  final ShouldAddedRoute? shouldCheck;
  final int checkLeakDelay;

  LeakObserver(
      {required GlobalKey<NavigatorState> navigatorKey,
      this.checkLeakDelay = defaultCheckLeakDelay,
      this.shouldCheck}) {
    if (kDebugMode) {
      LeakStream.getInstance().stream.listen((node) {
        LogUtil.d("泄漏信息 \n${node.toString()}");
        List<LeakNode> nodeList = toList(node);

        final RenderBox? targetRender =
            navigatorKey.currentContext!.findRenderObject() as RenderBox?;
        // print('targetRender ${targetRender?.paintBounds}');
        BottomPopupCard.show(
            navigatorKey.currentContext!, LeakWidget(nodeList));
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if(kDebugMode)
    _remove(route);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if(kDebugMode)
    _add(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if(kDebugMode)
    _remove(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if(kDebugMode){
      if (newRoute != null) {
        _add(newRoute);
      }
      if (oldRoute != null) {
        _remove(oldRoute);
      }
    }

  }

  Map<String, Expando> _widgetRefMap = {};
  Map<String, Expando> _stateRefMap = {};

  void _add(Route route) {
    if (route is BottomRoute) {
      return;
    }
    route.didPush().then((value) {
      Element? element = _getElementByRoute(route);
      if (element != null) {
        Expando expando = Expando('${element.widget}');
        expando[element.widget] = true;
        _widgetRefMap[_generateKey(route)] = expando;
        if (element is StatefulElement) {
          Expando expandoState = Expando('${element.state}');
          expando[element.state] = true;
          _stateRefMap[_generateKey(route)] = expandoState;
        }
      }
    });
  }

  ///check and analyze the route
  void _remove(Route route) {
    Element? element = _getElementByRoute(route);
    if (element != null) {
      print("开始检测 ${element.widget}");
      Future.delayed(Duration(seconds: checkLeakDelay), () {
        LeakTask(_widgetRefMap.remove(_generateKey(route)))
            .start(tag: "widget leaks");

        if (element is StatefulElement) {
          LeakTask(_stateRefMap.remove(_generateKey(route)))
              .start(tag: "state leaks");
        }
      });
    }
  }

  String _generateKey(Route route) {
    return '${route.hashCode}-${route.runtimeType}';
  }

  Element? _getElementByRoute(Route route) {
    Element? element;
    if (route is ModalRoute &&
        (shouldCheck == null || shouldCheck!.call(route))) {
      //RepaintBoundary
      route.subtreeContext?.visitChildElements((child) {
        //Builder
        child.visitChildElements((child) {
          //Semantics
          child.visitChildElements((child) {
            //My Page
            element = child;
          });
        });
      });
    }
    return element;
  }
}
