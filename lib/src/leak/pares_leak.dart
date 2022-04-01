import 'dart:async';
import 'package:flutter_leakcanary/src/leak/code_info.dart';
import 'package:flutter_leakcanary/src/utils/object_util.dart';
import 'package:vm_service/vm_service.dart';
import 'leak_node.dart';

abstract class Parser<T extends ObjRef> {
  Future<bool> paresRefSkip(T objRef, String? parentField, LeakNode leakNode);
}

class ClassParser extends Parser<ClassRef> {
  @override
  Future<bool> paresRefSkip(
      ClassRef classRef, String? parentField, LeakNode leakNode) async {
    leakNode.id = classRef.id;
    leakNode.name = classRef.name;
    leakNode.type = NodeType.CLASS;
    leakNode.isRoot = false;
    return false;
  }
}

class CodeParser extends Parser<CodeRef> {
  @override
  Future<bool> paresRefSkip(
      CodeRef objRef, String? parentField, LeakNode leakNode) async {
    // leakNode.id = objRef.id;
    // leakNode.name = objRef.name;
    // leakNode.isRoot = false;
    // leakNode.type = NodeType.CODE;
    return true;
  }
}

class ContextParser extends Parser<ContextRef> {
  @override
  Future<bool> paresRefSkip(
      ContextRef contextRef, String? parentField, LeakNode leakNode) async {
    leakNode.id = contextRef.id;
    leakNode.name = 'LeakContext';
    leakNode.type = NodeType.CONTEXT;
    leakNode.isRoot = false;
    return false;
  }
}

class ErrorParser extends Parser<ErrorRef> {
  @override
  Future<bool> paresRefSkip(
      ErrorRef erorRef, String? parentField, LeakNode leakNode) async {
    leakNode.id = erorRef.id;
    leakNode.name = 'Error';
    leakNode.type = NodeType.ERROR;
    leakNode.isRoot = false;
    return false;
  }
}

class FieldParser extends Parser<FieldRef> {
  @override
  Future<bool> paresRefSkip(
      FieldRef fieldRef, String? parentField, LeakNode leakNode) async {
    leakNode.id = fieldRef.id;
    leakNode.name = fieldRef.name;
    leakNode.type = NodeType.FIELD;
    leakNode.isRoot = fieldRef.isStatic ?? false;
    Field field = await getObjectOfType(fieldRef.id!);
    leakNode.codeInfo = await _getFieldCode(field);
    return false;
  }
}

class FuncParser extends Parser<FuncRef> {
  @override
  Future<bool> paresRefSkip(
      FuncRef funcRef, String? parentField, LeakNode leakNode) async {
    leakNode.id = funcRef.id;
    leakNode.name = funcRef.name;
    leakNode.type = NodeType.FUNC;
    leakNode.isRoot = false;
    return false;
  }
}

class InstanceParser extends Parser<InstanceRef> {
  @override
  Future<bool> paresRefSkip(
      InstanceRef instanceRef, String? parentField, LeakNode leakNode) async {
    leakNode.id = instanceRef.id;
    leakNode.name = instanceRef.name ?? instanceRef.classRef?.name;
    leakNode.type = NodeType.INSTANCE;
    leakNode.isRoot = false;
    return false;
  }
}

class ScriptParser extends Parser<ScriptRef> {
  @override
  Future<bool> paresRefSkip(
      ScriptRef scriptRef, String? parentField, LeakNode leakNode) async {
    leakNode.id = scriptRef.id;
    leakNode.name = 'ScriptRef';
    leakNode.type = NodeType.SCRIPT;
    leakNode.isRoot = false;
    return false;
  }
}

class TypeArgumentsParser extends Parser<TypeArgumentsRef> {
  @override
  Future<bool> paresRefSkip(TypeArgumentsRef typeArgumentsRef,
      String? parentField, LeakNode leakNode) async {
    leakNode.id = typeArgumentsRef.id;
    leakNode.name = typeArgumentsRef.name;
    leakNode.type = NodeType.ARGS;
    leakNode.isRoot = false;
    return false;
  }
}

Map<Type, Parser> parsers = {
  ClassParser: ClassParser(),
  CodeRef: CodeParser(),
  ContextRef: ContextParser(),
  ErrorRef: ErrorParser(),
  FieldRef: FieldParser(),
  FuncRef: FuncParser(),
  InstanceRef: InstanceParser(),
  ScriptRef: ScriptParser(),
  TypeArgumentsRef: TypeArgumentsParser(),
};

Future<CodeInfo?> _getFieldCode(Field field) async {
  if (field.location?.script?.id != null) {
    Script? script = await getObjectOfType(field.location!.script!.id!);

    if (script != null && field.location?.tokenPos != null) {
      int? line = script.getLineNumberFromTokenPos(field.location!.tokenPos!);
      int? column =
          script.getColumnNumberFromTokenPos(field.location!.tokenPos!);
      String? codeLine;
      codeLine = script.source
          ?.substring(field.location!.tokenPos!, field.location!.endTokenPos)
          .split('\n')
          .first;

      CodeInfo codeInfo = CodeInfo(line, column, codeLine, script.uri);

      return codeInfo;
    }
  }
  return null;
}
