import 'dart:developer';
import 'dart:isolate' as sdk;
import 'package:flutter_leakcanary/src/utils/vm_service_util.dart';
import 'package:vm_service/vm_service.dart';

import '../generate_key.dart';

Future<AllocationProfile> gc({sdk.Isolate? sdkIsolate}) async {
  String isolateId = getIsolateId(sdkIsolate: sdkIsolate);
  VmService vmService = await getVmService();
  return await vmService.getAllocationProfile(isolateId, gc: true);
}


Future<T> getObjectOfType<T extends Obj?>(String objectId,
    {sdk.Isolate? sdkIsolate}) async {
  var result = await _getObject(objectId, sdkIsolate: sdkIsolate);
  return result as T;
}

Future<Obj?> _getObject(String objectId, {sdk.Isolate? sdkIsolate}) async {
  sdk.Isolate currentIsolate = sdkIsolate ?? sdk.Isolate.current;
  String isolateId = Service.getIsolateID(currentIsolate)!;
  VmService vmService = await getVmService();
  Obj? obj = await vmService.getObject(isolateId, objectId);
  return obj;
}

Future<List<InstanceRef>> getWeakKeyRefs(Expando expando) async {
  List<InstanceRef> instanceRefs = [];
  final weakPropertyRefs = await _getWeakProperty(expando);

  for (var i = 0; i < weakPropertyRefs.length; i++) {
    final weakPropertyRef = weakPropertyRefs[i];
    final weakPropertyId = weakPropertyRef.json?['id'];
    Obj? weakPropertyObj = await getObjectOfType(weakPropertyId);

    if (weakPropertyObj != null) {
      final weakPropertyInstance = Instance.parse(weakPropertyObj.json);
      if (weakPropertyInstance!.propertyKey != null) {
        instanceRefs.add(weakPropertyInstance.propertyKey!);
      }
    }
  }

  return instanceRefs;
}

Future<List<InstanceRef>> getWeakValueRefs(Expando expando) async {
  List<InstanceRef> instanceRefs = [];
  final weakPropertyRefs = await _getWeakProperty(expando);

  for (var i = 0; i < weakPropertyRefs.length; i++) {
    final weakPropertyRef = weakPropertyRefs[i];
    final weakPropertyId = weakPropertyRef.json?['id'];
    Obj? weakPropertyObj = await getObjectOfType(weakPropertyId);

    if (weakPropertyObj != null) {
      final weakPropertyInstance = Instance.parse(weakPropertyObj.json);
      if (weakPropertyInstance!.propertyKey != null) {
        instanceRefs.add(weakPropertyInstance.propertyValue!);
      }
    }
  }

  return instanceRefs;
}

Future<List<InstanceRef>> _getWeakProperty(Expando expando) async {
  String expandoId = await obj2Id(expando);
  Instance expandoObj = await getObjectOfType(expandoId);
  List<InstanceRef> instanceRefs = [];
  for (var i = 0; i < expandoObj.fields!.length; i++) {
    var filed = expandoObj.fields![i];
    if (filed.decl?.name == '_data') {
      String _dataId = filed.toJson()['value']['id'];
      Instance _data = await getObjectOfType(_dataId);
      if (_data is Instance) {
        for (int j = 0; j < _data.elements!.length; j++) {
          var weakProperty = _data.elements![j];
          if (weakProperty is InstanceRef) {
            InstanceRef weakPropertyRef = weakProperty;
            instanceRefs.add(weakPropertyRef);
          }
        }
      }
    }
  }

  return instanceRefs;
}

Future<RetainingPath> getRetainingPath(String objId,
    {sdk.Isolate? sdkIsolate, int? limit}) async {
  sdk.Isolate currentIsolate = sdkIsolate ?? sdk.Isolate.current;
  String isolateId = Service.getIsolateID(currentIsolate)!;
  VmService vmService = await getVmService();
  return vmService.getRetainingPath(isolateId, objId, limit ?? 3000);
}