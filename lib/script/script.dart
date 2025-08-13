class Script {
  String scriptInsertEmpresa(String schema, Map<String, dynamic> dados) {
    return '''
      INSERT INTO public.empresas 
      (cnpj, razao, fantasia, cep, logradouro, numero, bairro, municipio, uf, telefone, email, schema) 
      VALUES (
        '${dados['cnpj']}',
        '${dados['razao']}',
        '${dados['fantasia']}',
        '${dados['cep']}',
        '${dados['logradouro']}',
        '${dados['numero']}',
        '${dados['bairro']}',
        '${dados['municipio']}',
        '${dados['uf']}',
        '${dados['telefone']}',
        '${dados['email']}',
        '${dados['schema']}'
      ) RETURNING id;''';
  }

  String scriptInsertUsuario(Map<String, dynamic> dados) {
    return '''
    INSERT INTO public.usuarios (nome, email, uid, is_admin)
    VALUES (
      '${dados['nome']}',
      '${dados['email']}',
      '${dados['uid']}',
      ${dados['is_admin']}
    ) RETURNING id;''';
  }

  String scriptInsertUsuarioDaEmpresa(Map<String, dynamic> dados) {
    return '''
    INSERT INTO public.usuarios_empresas (uid_usuario, id_empresa)
    VALUES (
      '${dados['uid']}',
      '${dados['id_empresa']}'
    ) RETURNING id;''';
  }

  String scriptBuscarEmpresa(String cnpj) {
    return "SELECT * FROM public.empresas WHERE cnpj = '$cnpj' LIMIT 1;";
  }

  String scriptInsertConfiguracao(String schema, Map<String, dynamic> dados) {
    return '''
    INSERT INTO ${schema}.configuracaogeral (uid, cnpj, schema)
    VALUES (
      '${dados['uid']}',
      '${dados['cnpj']}',
      '${dados['schema']}'
    ) RETURNING id;''';
  }

  String scriptCriarSchemaDaEmpresa(String schema) {
    return "SELECT public.criar_schema_empresa('$schema');";
  }
}
