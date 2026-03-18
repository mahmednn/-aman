import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final response = await http.get(Uri.parse('http://102.203.200.14/api/public/suppliers'));
  if (response.statusCode == 200) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] != null && (decoded['data'] as List).isNotEmpty) {
        final supplier = decoded['data'][0];
        print('Supplier 0: ${supplier['id']} - ${supplier['user']?['name']}');
        
        if (supplier['products'] != null && (supplier['products'] as List).isNotEmpty) {
           final firstProduct = supplier['products'][0];
           
           // Format JSON with indentation for readability
           const JsonEncoder encoder = JsonEncoder.withIndent('  ');
           print('Product JSON:');
           print(encoder.convert(firstProduct));
           
           if (firstProduct['pivot'] != null) {
              print('Pivot explicitly:');
              print(encoder.convert(firstProduct['pivot']));
           }
        }
      }
    } catch (e) {
      print('Error parsing: $e');
    }
  } else {
    print('Failed api: ${response.statusCode}');
  }
}
