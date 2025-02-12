import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_item.dart';
class StorageService {
  final secureStorage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(encryptedSharedPreferences:true);
  IOSOptions _getIOSOptions() => const IOSOptions(accountName: 'Pard');
  WebOptions _getWebOptions() => const WebOptions();
  Future<void> writeSecureData(StorageItem newItem) async
  {
    await secureStorage.write(key:newItem.key,value:newItem.value,aOptions: _getAndroidOptions(),iOptions:_getIOSOptions());
  }
  Future<String?> readSecureData(String key) async
  {
    var readData = await secureStorage.read(key:key,aOptions:_getAndroidOptions(),iOptions:_getIOSOptions());
    return readData;
  }
  Future<void> deleteSecureData(StorageItem item) async
  {
    await secureStorage.delete(key:item.key,aOptions:_getAndroidOptions(),iOptions:_getIOSOptions());
  }
  Future<bool> containsKey(String key) async
  {
    var contains = await secureStorage.containsKey(key:key,aOptions:_getAndroidOptions(),iOptions:_getIOSOptions());
    return contains;
  }
  Future<List<StorageItem>> readAllSecureData() async
  {
    var allData = await secureStorage.readAll(aOptions:_getAndroidOptions());
    List<StorageItem> list = allData.entries.map((e)=>StorageItem(e.key,e.value)).toList();
    return list;
  }
  Future<void> deleteAllSecureData() async
  {
    await secureStorage.deleteAll(aOptions: _getAndroidOptions(),iOptions:_getIOSOptions());
  }
}