import 'dart:convert';
import 'dart:io';

import 'package:formvalidation/src/preferencias_usuario/preferencias_usuario.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

import 'package:formvalidation/src/models/producto_model.dart';

class ProductosProvider {
  final String _url = 'https://udemy-curso-8dc29.firebaseio.com';
  final _prefs = new PreferenciasUsuario();

  Future<bool> crearProducto(ProductoModel producto) async {
    final url = '$_url/producto.json?auth=${_prefs.token}';

    final resp = await http.post(url, body: productoModelToJson(producto));
    final decodeData = json.decode(resp.body);

    print(decodeData);

    return true;
  }

  Future<bool> editarProducto(ProductoModel producto) async {
    final url = '$_url/producto/${producto.id}.json?auth=${_prefs.token}';

    final resp = await http.put(url, body: productoModelToJson(producto));
    final decodeData = json.decode(resp.body);

    print(decodeData);

    return true;
  }

  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/producto.json?auth=${_prefs.token}';
    final resp = await http.get(url);

    final Map<String, dynamic> decodeData = json.decode(resp.body);
    final List<ProductoModel> productos = new List();

    if (decodeData == null) return [];

    // TODO se debe mostrar mensaje y botar al usuario al login
    if (decodeData['error'] != null) return [];

    decodeData.forEach((key, prod) {
      final prodTemp = ProductoModel.fromJson(prod);
      prodTemp.id = key;

      productos.add(prodTemp);
    });

//    print(productos);
    return productos;
  }

  Future<int> borrarProducto(String id) async {
    final url = '$_url/producto/$id.json?auth=${_prefs.token}';

    final resp = await http.delete(url);

    print(json.decode(resp.body));
  }

  Future<String> subirImagen(File imagen) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/ds5vvyosu/image/upload?upload_preset=vzaivua5');

    final mimeType = mime(imagen.path).split('/'); // image/jpeg tipo de file

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath(
      'file',
      imagen.path,
      contentType: MediaType(mimeType[0], mimeType[1]),
    );

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');
      print(resp.body);
      return null;
    }

    final respData = json.decode(resp.body);
    print(respData);

    return respData['secure_url'];
  }
}
