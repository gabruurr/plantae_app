import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageService {
  static const String _apiKey = '6df95ef9f0c14cee435aa746d8fd2b92';

  Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$_apiKey');
    
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    try {
      final response = await http.post(
        uri,
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['display_url'];
      } else {
        print('Erro no upload da imagem: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exceção no upload da imagem: $e');
      return null;
    }
  }
}