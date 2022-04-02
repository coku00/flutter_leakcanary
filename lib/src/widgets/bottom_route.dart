import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomRoute extends PopupRoute {
  final Widget widget;
  final double height;

  BottomRoute(this.widget, this.height);

  @override
  Color? get barrierColor => Color(0x00000000);

  @override
  String? get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomWindow = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomWindowLayoutDelegate(animation.value,
                  contentHeight: height),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff4a2c2c),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.0),
                      topRight: Radius.circular(14.0)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Container(
                            height: 2,
                            width: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    // ShrinkWrappingViewport(offset:_position,slivers: _children(),),
                    Material(
                      child: widget,
                      color: Color(0xff706b6b),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    return bottomWindow;
  }

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
}

class _BottomWindowLayoutDelegate extends SingleChildLayoutDelegate {
  final double? contentHeight;
  final double progress;

  _BottomWindowLayoutDelegate(this.progress, {this.contentHeight});

  @override
  bool shouldRelayout(covariant _BottomWindowLayoutDelegate oldDelegate) {
    return progress != oldDelegate.progress;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      // 当指定高度时设置指定高度，没有指定高度则对最大高度不加限制
      maxHeight: 520,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }
}





class BottomPopupCard {
  static void show(BuildContext buildContext, Widget widget) {
    Navigator.of(buildContext).push(BottomRoute(widget, 200));
  }
}
