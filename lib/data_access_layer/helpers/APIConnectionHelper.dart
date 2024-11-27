import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class APIConnectionHelper {
  static Future<String> getJwtToken() async{
    const storage = FlutterSecureStorage();
    var jwt = await storage.read(key: 'jwt');
    if (jwt == null) return "";

    return jwt;
  }
}