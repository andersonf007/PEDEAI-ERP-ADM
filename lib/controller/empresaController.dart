import 'package:pedeaierpadm/controller/authService.dart';
import 'package:pedeaierpadm/controller/databaseService.dart';
import 'package:pedeaierpadm/script/script.dart';

class Empresacontroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  Script script = Script();

  // Buscar empresa no banco de dados
  Future<Map<String, dynamic>?> buscarEmpresaNoBanco(String cnpj, String schemaEmpresa) async {
    try {
      // Buscar dados da empresa usando o método executeSql
      final resultado = await _databaseService.executeSql(script.scriptBuscarEmpresa(cnpj), params: {'cnpj': cnpj}, schema: schemaEmpresa ?? 'empresa_$cnpj');

      return resultado.isNotEmpty ? resultado.first : null;
    } catch (e) {
      print('Erro ao buscar empresa no banco: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> inserirEmpresa(String schema, Map<String, dynamic> dados) async {
    try {
      return await _databaseService.executeSql(script.scriptInsertEmpresa(schema!, dados), schema: schema);
    } catch (e) {
      throw Exception('Erro ao salvar empresa: ${e.toString()}');
    }
  }
}
