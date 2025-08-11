class Script {
  String gerarInsertEmpresa(String schema, Map<String, dynamic> dados) {
    return '''
      INSERT INTO ${schema}.empresa 
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

  String gerarInsertUsuario(String schema, Map<String, dynamic> dados) {
    return '''
    INSERT INTO ${schema}.usuario (nome, email, uid, is_admin)
    VALUES (
      '${dados['nome']}',
      '${dados['email']}',
      '${dados['uid']}',
      ${dados['is_admin']}
    ) RETURNING id;''';
  }

  String buscarEmpresa(String cnpj){
return "SELECT * FROM {schema}.empresa WHERE cnpj = '$cnpj' LIMIT 1;";
}
}
