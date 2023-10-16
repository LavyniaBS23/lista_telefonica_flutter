class ContatosModel {
  List<ContatoModel> contatos = [];

  ContatosModel(this.contatos);

  ContatosModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      contatos = <ContatoModel>[];
      json['results'].forEach((v) {
        contatos.add(ContatoModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['results'] = contatos.map((v) => v.toJson()).toList();
    return data;
  }
}

class ContatoModel {
  String objectId = "";
  String createdAt = "";
  String updatedAt = "";
  String nome = "";
  int numero = 0;
  int marcadorNumero = 0;
  String sobrenome = "";
  String email = "";
  String foto = "";
  bool favorito = false;
  String cor = "";

  ContatoModel(
      this.objectId,
      this.createdAt,
      this.updatedAt,
      this.nome,
      this.numero,
      this.marcadorNumero,
      this.sobrenome,
      this.email,
      this.foto,
      this.favorito, this.cor);
  ContatoModel.vazio();

  ContatoModel.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    nome = json['nome'];
    numero = json['numero'];
    marcadorNumero = json['marcador_numero'];
    sobrenome = json['sobrenome'];
    email = json['email'];
    foto = json['foto'];
    favorito = json['favorito'];
    cor = json['cor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectId'] = objectId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['nome'] = nome;
    data['numero'] = numero;
    data['marcador_numero'] = marcadorNumero;
    data['sobrenome'] = sobrenome;
    data['email'] = email;
    data['foto'] = foto;
    data['favorito'] = favorito;
    data['cor'] = cor;
    return data;
  }

  Map<String, dynamic> toJsonEndPoint() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['numero'] = numero;
    data['marcador_numero'] = marcadorNumero;
    data['sobrenome'] = sobrenome;
    data['email'] = email;
    data['foto'] = foto;
    data['favorito'] = favorito;
    data['cor'] = cor;
    return data;
  }

  Map<String, dynamic> toJsonCompartilhar() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['foto'] = foto;
    data['nome'] = nome;
    data['sobrenome'] = sobrenome;
    data['numero'] = numero;
    data['marcador_numero'] = marcadorNumero;
    data['email'] = email;
    return data;
  }
}
