import 'package:flutter/material.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/repositories/back4app_custom_dio.dart';

class ContatosBack4AppRepository {
  final _customDio = Back4AppCustomDio();

  ContatosBack4AppRepository();
  Future<ContatosModel> obterContatos(bool favoritos, bool ordem) async {
    var url = "/contatos";

    if (favoritos) {
      url = "$url?where={\"favorito\":true}";
    }

    var result = await _customDio.dio.get(url);

    var contatosModel = ContatosModel.fromJson(result.data);
    if (contatosModel.contatos.isNotEmpty) {
      if (ordem) {
        contatosModel.contatos.sort(
            (b, a) => a.nome.toUpperCase().compareTo(b.nome.toUpperCase()));
      } else {
        contatosModel.contatos.sort(
            (a, b) => a.nome.toUpperCase().compareTo(b.nome.toUpperCase()));
      }
    }
    return contatosModel;
  }

  Future<void> criar(ContatoModel contatoModel) async {
    try {
      var response = await _customDio.dio
          .post("/contatos", data: contatoModel.toJsonEndPoint());
    } catch (e) {
      throw e;
    }
  }

  Future<void> atualizar(ContatoModel contatoModel) async {
    try {
      var response = await _customDio.dio.put(
          "/contatos/${contatoModel.objectId}",
          data: contatoModel.toJsonEndPoint());
    } catch (e) {
      throw e;
    }
  }

  Future<void> remover(String objectId) async {
    try {
      var response = await _customDio.dio.delete("/contatos/$objectId");
    } catch (e) {
      throw e;
    }
  }

  Future<ContatoModel> getContato(String objectId) async {
    try {
      var response = await _customDio.dio.get("/contatos/$objectId");
      return ContatoModel.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }
}
