import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_leakcanary/src/leak/leak_node.dart';

class LeakWidget extends StatelessWidget {
  final List<LeakNode> list;

  LeakWidget(this.list);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 454,
      child: ListView.builder(
        itemBuilder: (_, index) {
          final node = list[index];
          bool isField = node.type == NodeType.FIELD;

          return isField ? _buildField(node) : _buildClass(node);
        },
        itemCount: list.length,
      ),
    );
  }

  Widget _buildField(LeakNode node) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Color(0xff0b28ea),
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'gc root field - > ${node.name!}',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                node.codeInfo?.toString() ?? '',
                style: TextStyle(fontSize: 12, color: Colors.red),
              )),
          Container(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'uri - > ${node.codeInfo?.uri}',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildClass(LeakNode node) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xff0a4c49),
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              node.name!,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              node.getParent(),
              style: TextStyle(fontSize: 12, color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
