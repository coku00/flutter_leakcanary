import 'dart:isolate' as sdk;
import 'package:flutter_leakcanary/src/utils/vm_service_util.dart';
import 'package:vm_service/vm_service.dart';

int _key = 0;

/// 顶级函数，必须常规方法，生成 key 用
String generateNewKey() {
  return "${++_key}";
}

Map<String, dynamic> _objCache = Map();

/// 顶级函数，根据 key 返回指定对象
dynamic key2Obj(String key) {
  return _objCache[key];
}

//dart对象转vm中的id
Future<String> obj2Id(dynamic obj, {sdk.Isolate? sdkIsolate}) async {
  String isolateId = getIsolateId(sdkIsolate: sdkIsolate);
  VmService vmService = await getVmService();
  Isolate isolate = await vmService.getIsolate(isolateId);

  LibraryRef libraryRef = isolate.libraries!
      .where((element) =>
          element.uri == 'package:flutter_leakcanary/src/generate_key.dart')
      .first;

  String libraryId = libraryRef.id!;

  // 用 vm service 执行 generateNewKey 函数生成 一个key
  Response keyRef =
      await vmService.invoke(isolateId, libraryId, "generateNewKey", []);
  //获取 generateNewKey 生成的key
  String key = keyRef.json!['valueAsString'];
  //把obj存到map
  _objCache[key] = obj;

  //key在vm中对应的id
  String vmId = keyRef.json!['id'];
  try {
    // 调用 key2Obj 顶级函数,获取obj的在vm中的信息 (ps:使用vmService调用有参数的函数不能直接传参数的值，需要传参数在VM中对应的id)
    Response objRef =
        await vmService.invoke(isolateId, libraryId, "key2Obj", [vmId]);
    // 获取obj在vm中的id
    // print('objRef =${objRef.json}');
    return objRef.json!['id'];
  } finally {
    //移除map中的值
    _objCache.remove(key);
  }
}
