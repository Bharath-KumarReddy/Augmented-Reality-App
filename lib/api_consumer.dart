import 'dart:typed_data';
import 'package:furni/global.dart';
import 'package:http/http.dart' as http;

class ApiConsumer {
  Future<Uint8List> removeImageBackgroundApi(String imagePath) async {
    var requestApi = http.MultipartRequest("POST", Uri.parse("https://api.remove.bg/v1.0/removebg"));

    requestApi.files.add(await http.MultipartFile.fromPath("image_file", imagePath));

    requestApi.headers.addAll({"X-API-KEY": apikeyRemoveImageBackground});

    final responseFromapi = await requestApi.send();

    if (responseFromapi.statusCode == 200) {
      http.Response getTransparentImage = await http.Response.fromStream(responseFromapi);

      return getTransparentImage.bodyBytes;
    } else {
      throw Exception("Error Ocurrend${responseFromapi.statusCode}");
    }
  }
}
