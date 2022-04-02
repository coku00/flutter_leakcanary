import 'code_info.dart';

class LeakNode {
  bool isRoot = false;

  LeakNode? next;

  String? id;

  String? name;

  NodeType? type;

  String? parentField;

  CodeInfo? codeInfo;

  String getParent(){
    String? parent;
    if (parentField != null && parentField!.contains('@')) {
      parent = parentField!.split('@')[0];
    } else {
      parent = parentField;
    }
    return parent ?? "";
  }

  @override
  String toString() {
    String? parent;
    if (parentField != null && parentField!.contains('@')) {
      parent = parentField!.split('@')[0];
    } else {
      parent = parentField;
    }
    String empty = '';
    return '[${_formatAlign('${type == NodeType.FIELD ? '${codeInfo?.uri}; ${isRoot ? ' GC Root' : ""} Field -> $name' : 'name : $name'}${codeInfo == null ? '' : '  >>>  ${codeInfo?.toString()}  <<<'}', type == NodeType.FIELD ? 200 : 50)} ] ${next == null ? ' ' : '${_formatAlign(parent == null ? empty : ' field -> $parent', 30)}    ↓    '
        '\n${next?.toString()}'}';
  }
}

List<LeakNode> toList(LeakNode leakNode) {
  List<LeakNode> list = [];
  LeakNode? current = leakNode;
  while (current != null) {
    list.add(current);
    current = current.next;
  }
  return list;
}

enum NodeType {
  CLASS,
  CONTEXT,
  CODE,
  FIELD,
  ERROR,
  FUNC,
  INSTANCE,
  SCRIPT,
  ARGS,
  UN_KNOW
}

String _formatAlign(String name, int len) {
  StringBuffer sb = StringBuffer();

  if (name.length > len) {
    name = name.substring(0, len);
  }
  sb.write(name);
  int fixLen = len - name.length;
  for (var i = 0; i < fixLen; i++) {
    sb.write(' ');
  }
  return sb.toString();
}
