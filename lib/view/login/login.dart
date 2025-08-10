
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:pedeaierpadm/controller/authService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController textSenha = TextEditingController();
  TextEditingController textUsuario = TextEditingController();
  final AuthService _authService = AuthService();
  late SharedPreferences prefs;
  String versaoApi = '1.0.0';

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _checkAuthState();
  }

  void _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _checkAuthState() {
    // Escutar mudanças de autenticação
    _authService.authStateChanges.listen((AuthState data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Salvar token localmente se necessário
        prefs.setString('user_email', session.user.email ?? '');
        prefs.setString('access_token', session.accessToken);
        
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (p0) => false);
      } else if (event == AuthChangeEvent.signedOut) {
        // Limpar dados locais
        prefs.remove('user_email');
        prefs.remove('access_token');
      }
    });

    // Verificar se já está logado
    if (_authService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (p0) => false);
      });
    }
  }

  Future<String?> _onRecoverPassword(String email) async {
        try {
      await _authService.resetPassword(email: email);
      return null; // Sucesso
    } catch (e) {
      return 'Erro ao enviar email de recuperação: ${e.toString()}';
    }
  }

  Future<String?> _loginUser(LoginData data) async {
       try {
      final response = await _authService.signIn(
        email: data.name,
        password: data.password,
      );

      if (response.user != null) {
        // Verificar se email foi confirmado
        if (!_authService.isEmailConfirmed) {
          return 'Por favor, confirme seu email antes de fazer login';
        }
        return null; // Sucesso
      } else {
        return 'Credenciais inválidas';
      }
    } catch (e) {
      return 'Erro ao fazer login: ${e.toString()}';
    }
  }

  Future<String?> _signupUser(SignupData data) async {
        try {
      final response = await _authService.signUp(
        email: data.name ?? '',
        password: data.password ?? '',
        //name: data.additionalSignupData?['name'] ?? '',
        //phone: data.additionalSignupData?['phone'],
      );

      if (response.user != null) {
        return null; // Sucesso - usuário precisa confirmar email
      } else {
        return 'Erro ao criar conta';
      }
    } catch (e) {
      return 'Erro ao criar conta: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        title: 'Pede Ai ERP ADM',
        onLogin: _loginUser,
        onRecoverPassword: _onRecoverPassword,
        onSignup: _signupUser,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (p0) => false);
        },
        messages: LoginMessages(
          userHint: 'E-mail',
          passwordHint: 'Senha',
          confirmPasswordHint: 'Confirmar Senha',
          loginButton: 'ENTRAR',
          signupButton: 'CADASTRAR',
          forgotPasswordButton: 'Esqueci minha senha',
          recoverPasswordButton: 'RECUPERAR',
          goBackButton: 'VOLTAR',
          confirmPasswordError: 'As senhas não coincidem',
          recoverPasswordDescription: 'Enviaremos um e-mail para recuperar sua senha',
          recoverPasswordSuccess: 'E-mail de recuperação enviado',
        ),
        theme: LoginTheme(
          primaryColor: Colors.teal,
          accentColor: Colors.yellow,
          errorColor: Colors.red,
          titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
          bodyStyle: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
          textFieldStyle: TextStyle(color: Colors.black, fontSize: 16),
          buttonStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 5,
            margin: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        /*additionalSignupFields: [
          UserFormField(
            keyName: 'name',
            displayName: 'Nome Completo',
            fieldValidator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu nome completo';
              }
              if (value.length < 2) {
                return 'Nome deve ter pelo menos 2 caracteres';
              }
              return null;
            },
            icon: Icon(Icons.person),
          ),
          // Você pode adicionar mais campos se necessário
          UserFormField(
            keyName: 'phone',
            displayName: 'Telefone',
            fieldValidator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu telefone';
              }
              // Validação simples de telefone
              if (!RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$').hasMatch(value)) {
                return 'Formato: (11) 99999-9999';
              }
              return null;
            },
            icon: Icon(Icons.phone),
          ),
        ],*/
      ),
    );
  }
}
