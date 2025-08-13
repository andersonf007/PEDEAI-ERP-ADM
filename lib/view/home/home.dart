// lib/view/home/home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pedeaierpadm/controller/authService.dart';
import 'package:pedeaierpadm/controller/configuracaoController.dart';
import 'package:pedeaierpadm/controller/databaseService.dart';
import 'package:pedeaierpadm/controller/empresaController.dart';
import 'package:pedeaierpadm/controller/usuarioController.dart';
import 'package:pedeaierpadm/script/script.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCPF = false; // Controla se é CPF ou CNPJ
  bool _dadosPesquisados = false; // Controla se os dados foram pesquisados

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final Script _script = Script();
  Empresacontroller empresacontroller = Empresacontroller();
  Usuariocontroller usuariocontroller = Usuariocontroller();
  ConfiguracaoController configuracaoController = ConfiguracaoController();
  final _cnpjCpfController = TextEditingController();
  final _nomeController = TextEditingController();
  final _fantasiaController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _municipioController = TextEditingController();
  final _ufController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailEmpresaController = TextEditingController();
  final _schemaController = TextEditingController();
  final _nomeUsuarioController = TextEditingController();
  final _emailUsuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  String uidUsuarioCadastrado = '';
  // Schema da empresa (será baseado no campo schema)
  String? _schemaEmpresa;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    uidUsuarioCadastrado = '';
  }

  void _checkAuth() {
    if (!_authService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (p0) => false);
      });
    }
  }

  @override
  void dispose() {
    _cnpjCpfController.dispose();
    _nomeController.dispose();
    _fantasiaController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _municipioController.dispose();
    _ufController.dispose();
    _telefoneController.dispose();
    _emailEmpresaController.dispose();
    _schemaController.dispose();
    _nomeUsuarioController.dispose();
    _emailUsuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Verificar se é CPF ou CNPJ
  void _verificarTipoDocumento() {
    String documento = _cnpjCpfController.text.replaceAll(RegExp(r'[^\d]'), '');

    setState(() {
      if (documento.length == 11) {
        _isCPF = true;
        _dadosPesquisados = false;
      } else if (documento.length == 14) {
        _isCPF = false;
      } else {
        _isCPF = false;
        _dadosPesquisados = false;
      }
    });
  }

  // Buscar dados por CNPJ
  Future<void> _buscarDadosCNPJ() async {
    if (_cnpjCpfController.text.isEmpty) {
      _mostrarMensagem('Por favor, digite um CNPJ', Colors.orange);
      return;
    }

    String cnpjLimpo = _cnpjCpfController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (cnpjLimpo.length != 14) {
      _mostrarMensagem('CNPJ deve ter 14 dígitos', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar se a empresa já existe no banco
      final empresaExistente = await empresacontroller.buscarEmpresaNoBanco(cnpjLimpo, _schemaEmpresa!);

      if (empresaExistente?['id'] != null) {
        _preencherDadosEmpresa(empresaExistente!);
        _mostrarMensagem('Dados carregados do banco!', Colors.green);
        setState(() {
          _dadosPesquisados = true;
        });
      } else {
        // Buscar na Receita Federal
        final response = await http.get(Uri.parse('https://www.receitaws.com.br/v1/cnpj/$cnpjLimpo'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'ERROR') {
            _mostrarMensagem('CNPJ não encontrado ou inválido', Colors.red);
            _limparDados();
            setState(() {
              _dadosPesquisados = false;
            });
          } else {
            _preencherDadosEmpresa(data);
            _mostrarMensagem('Dados carregados da Receita Federal!', Colors.green);
            setState(() {
              _dadosPesquisados = true;
            });
          }
        } else {
          _mostrarMensagem('Erro ao buscar dados do CNPJ', Colors.red);
        }
      }
    } catch (e) {
      _mostrarMensagem('Erro de conexão', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Preencher dados da empresa
  void _preencherDadosEmpresa(Map<String, dynamic> data) {
    setState(() {
      _nomeController.text = data['nome'] ?? '';
      _fantasiaController.text = data['fantasia'] ?? '';
      _cepController.text = data['cep'] ?? '';
      _logradouroController.text = data['logradouro'] ?? '';
      _numeroController.text = data['numero'] ?? '';
      _bairroController.text = data['bairro'] ?? '';
      _municipioController.text = data['municipio'] ?? '';
      _ufController.text = data['uf'] ?? '';
      _telefoneController.text = data['telefone'] ?? '';
      _emailEmpresaController.text = data['email'] ?? '';

      // Schema não é preenchido automaticamente - removido
      if (data['schema'] != null && data['schema'].toString().isNotEmpty) {
        _schemaController.text = data['schema'];
        _schemaEmpresa = data['schema'];
      }
    });
  }

  // Limpar dados da empresa
  void _limparDados() {
    _nomeController.clear();
    _fantasiaController.clear();
    _cepController.clear();
    _logradouroController.clear();
    _numeroController.clear();
    _bairroController.clear();
    _municipioController.clear();
    _ufController.clear();
    _telefoneController.clear();
    _emailEmpresaController.clear();
    _schemaEmpresa = '';
    _nomeUsuarioController.clear();
    _emailUsuarioController.clear();
    _senhaController.clear();
    uidUsuarioCadastrado = '';
    setState(() {
      _dadosPesquisados = false;
    });
  }

  // Validar e atualizar schema
  void _validarSchema() {
    String novoSchema = _schemaController.text.trim();
    if (novoSchema.isNotEmpty) {
      setState(() {
        _schemaEmpresa = novoSchema;
      });
    }
  }

  // Salvar dados
  Future<void> _salvarDados() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_schemaController.text.trim().isEmpty) {
      _mostrarMensagem('Por favor, defina um schema para a empresa', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _schemaEmpresa = _schemaController.text.trim();
      String documentoLimpo = _cnpjCpfController.text.replaceAll(RegExp(r'[^\d]'), '');

      // Verificar se empresa já existe (apenas para CNPJ)
      if (!_isCPF) {
        final empresaExistente = await empresacontroller.buscarEmpresaNoBanco(documentoLimpo, _schemaEmpresa!);
        if (empresaExistente?['id'] != null) {
          _mostrarMensagem('Essa empresa já existe!', Colors.orange);
          return;
        }
      }

      // Verificar usuário
      /*final response = await _authService.signIn(email: _emailUsuarioController.text, password: _senhaController.text);
      if (response.user != null) {
        _mostrarMensagem('Esse usuário já existe!', Colors.orange);
        return;
      }*/
      final emailExists = await usuariocontroller.verificarEmailSeExiste(_emailUsuarioController.text);
      if (emailExists != null) {
        uidUsuarioCadastrado = emailExists;
      } else {
        final response2 = await usuariocontroller.cadastrarUsuario(_emailUsuarioController.text, _senhaController.text);
        if (response2.user == null) {
          _mostrarMensagem('Erro ao cadastrar usuário', Colors.red);
          return;
        }
        uidUsuarioCadastrado = response2.user!.id;
      }

      List<Map<String, dynamic>> response = await empresacontroller.inserirEmpresa(_schemaEmpresa!, {
        'cnpj': documentoLimpo,
        'razao': _nomeController.text.trim(),
        'fantasia': _fantasiaController.text.trim(),
        'cep': _cepController.text.trim(),
        'logradouro': _logradouroController.text.trim(),
        'numero': _numeroController.text.trim(),
        'bairro': _bairroController.text.trim(),
        'municipio': _municipioController.text.trim(),
        'uf': _ufController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'email': _emailEmpresaController.text.trim(),
        'schema': _schemaEmpresa!,
      });
      if (emailExists == null) {
        await usuariocontroller.inserirUsuario(_schemaEmpresa!, {'nome': _nomeUsuarioController.text.trim(), 'email': _emailUsuarioController.text.trim(), 'uid': uidUsuarioCadastrado, 'is_admin': true});
      }
      await usuariocontroller.scriptInsertUsuarioDaEmpresa(_schemaEmpresa!, {'uid': uidUsuarioCadastrado, 'id_empresa': response.first['id']});
      // Inserir usuário admin da empresa
      

      //configuracaoController.inserirConfiguracao('public', {'uid': uidUsuarioCadastrado, 'cnpj': documentoLimpo, 'schema': _schemaEmpresa});
      //await configuracaoController.criarSchemaDaEmpresa(_schemaEmpresa!);
      _mostrarMensagem('Dados salvos com sucesso!', Colors.green);
      //_limparDados();
    } catch (e) {
      // await _authService.deletarUsuario(uidUsuarioCadastrado);
      _mostrarMensagem('Erro ao salvar dados: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Logout
  Future<void> _logout() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (p0) => false);
    } catch (e) {
      _mostrarMensagem('Erro ao fazer logout', Colors.red);
    }
  }

  // Mostrar mensagem
  void _mostrarMensagem(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Cadastro de Empresa e Usuário'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout, tooltip: 'Sair')],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Card Dados da Empresa
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Row(
                        children: [
                          Icon(Icons.business, color: Colors.blue[600], size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Dados da Empresa',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[600]),
                          ),
                          Spacer(),
                          if (_isCPF) Chip(label: Text('CPF'), backgroundColor: Colors.orange[100]),
                          if (!_isCPF && _cnpjCpfController.text.replaceAll(RegExp(r'[^\d]'), '').length == 14) Chip(label: Text('CNPJ'), backgroundColor: Colors.blue[100]),
                        ],
                      ),
                      SizedBox(height: 20),

                      // CNPJ/CPF com botão de busca
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cnpjCpfController,
                              decoration: InputDecoration(
                                labelText: 'CNPJ/CPF *',
                                hintText: _isCPF ? '000.000.000-00' : '00.000.000/0000-00',
                                prefixIcon: Icon(_isCPF ? Icons.person : Icons.assignment_ind),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                helperText: _isCPF ? 'CPF - Preencha os dados manualmente' : 'CNPJ - Use o botão para pesquisar',
                              ),
                              inputFormatters: [_DocumentoFormatter()],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite o CNPJ ou CPF';
                                }
                                String limpo = value.replaceAll(RegExp(r'[^\d]'), '');
                                if (limpo.length != 11 && limpo.length != 14) {
                                  return 'Digite um CNPJ (14 dígitos) ou CPF (11 dígitos) válido';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _verificarTipoDocumento();
                                if (value.length < 14) {
                                  if (!_isCPF) {
                                    _limparDados();
                                  }
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (_isLoading || _isCPF) ? null : _buscarDadosCNPJ,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isCPF ? Colors.grey[400] : Colors.blue[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.zero,
                              ),
                              child: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.search, color: _isCPF ? Colors.grey[600] : Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Campos da empresa - Agora sempre editáveis
                      _buildCampoEmpresa('Nome da Empresa *', _nomeController, Icons.business, obrigatorio: true),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('Nome Fantasia', _fantasiaController, Icons.store),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('CEP', _cepController, Icons.location_on),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('Logradouro', _logradouroController, Icons.streetview),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('Número', _numeroController, Icons.numbers),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('Bairro', _bairroController, Icons.location_city),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('Município', _municipioController, Icons.location_city),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('UF', _ufController, Icons.map),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('Telefone', _telefoneController, Icons.phone),
                      SizedBox(height: 16),
                      _buildCampoEmpresa('Email da Empresa', _emailEmpresaController, Icons.email),
                      SizedBox(height: 16),

                      // Campo Schema - Não preenchido automaticamente
                      TextFormField(
                        controller: _schemaController,
                        decoration: InputDecoration(
                          labelText: 'Schema da Empresa *',
                          hintText: 'ex: empresa_12345678000100',
                          prefixIcon: Icon(Icons.storage),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          helperText: 'Nome do schema usado nas consultas SQL',
                          filled: true,
                          fillColor: Colors.yellow[50],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite o schema da empresa';
                          }
                          if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(value.trim())) {
                            return 'Schema deve conter apenas letras, números e underscore';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _validarSchema();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Card Dados do Usuário
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.green[600], size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Dados do Usuário',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Campos do usuário
                      TextFormField(
                        controller: _nomeUsuarioController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Usuário *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o nome do usuário';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _emailUsuarioController,
                        decoration: InputDecoration(
                          labelText: 'Email do Usuário *',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o email do usuário';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Digite um email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        decoration: InputDecoration(
                          labelText: 'Senha do Usuário *',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a senha do usuário';
                          }
                          if (value.length < 6) {
                            return 'Senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarDados,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Salvar Dados',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para campos da empresa (agora sempre editáveis)
  Widget _buildCampoEmpresa(String label, TextEditingController controller, IconData icon, {bool obrigatorio = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: false, // Removido o fundo cinza
      ),
      validator: obrigatorio
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo é obrigatório';
              }
              return null;
            }
          : null,
    );
  }
}

// Formatter para CNPJ/CPF
class _DocumentoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limitar a 14 dígitos (CNPJ)
    if (text.length > 14) {
      text = text.substring(0, 14);
    }

    String formatted = '';

    // Formatação para CPF (11 dígitos)
    if (text.length <= 11) {
      for (int i = 0; i < text.length; i++) {
        if (i == 3 || i == 6) {
          formatted += '.';
        } else if (i == 9) {
          formatted += '-';
        }
        formatted += text[i];
      }
    }
    // Formatação para CNPJ (12-14 dígitos)
    else {
      for (int i = 0; i < text.length; i++) {
        if (i == 2 || i == 5) {
          formatted += '.';
        } else if (i == 8) {
          formatted += '/';
        } else if (i == 12) {
          formatted += '-';
        }
        formatted += text[i];
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
