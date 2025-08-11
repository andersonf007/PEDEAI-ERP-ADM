import 'package:pedeaierpadm/controller/authService.dart';
import 'package:pedeaierpadm/controller/databaseService.dart';
import 'package:pedeaierpadm/script/script.dart';

class ConfiguracaoController {
  

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  Script script = Script();

  Future<void> inserirConfiguracao(String schema, Map<String, dynamic> dados) async {
    try {
      await _databaseService.executeSql(script.gerarInsertConfiguracao(schema, dados), schema: schema);
    } catch (e) {
      throw Exception('Erro ao salvar a configuração: ${e.toString()}');
    }
  }
}