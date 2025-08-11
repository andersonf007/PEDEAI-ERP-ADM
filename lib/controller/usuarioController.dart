import 'package:pedeaierpadm/controller/authService.dart';
import 'package:pedeaierpadm/controller/databaseService.dart';
import 'package:pedeaierpadm/script/script.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Usuariocontroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  Script script = Script();

  Future<String?> verificarEmailSeExiste(String email) async {
    try {
      return _authService.emailJaExiste(email);
    } catch (e) {
      throw Exception('Erro ao verificar email: ${e.toString()}');
    }
  }

  Future<AuthResponse> cadastrarUsuario(String email, String senha) async {
    try {
      return await _authService.signUp(email: email, password: senha);
    } catch (e) {
      throw Exception('Erro ao cadastrar usuário: ${e.toString()}');
    }
  }

Future<void> inserirUsuario(String schema, Map<String, dynamic> dados) async {
    try {
      await _databaseService.executeSql(script.gerarInsertUsuario(schema, dados), schema: schema);
    } catch (e) {
      throw Exception('Erro ao salvar usuário: ${e.toString()}');
    }
  }
}
