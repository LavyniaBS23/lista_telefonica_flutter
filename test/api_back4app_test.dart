import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/repositories/contatos_back4app_repository.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  var faker = Faker();
  var objectId = "";

  group('ContatosBack4AppRepository', () {
    late ContatosBack4AppRepository repository;

    setUp(() {
      repository = ContatosBack4AppRepository();
    });

    test('Obter contatos', () async {
      var contatos = await repository.obterContatos(false, false);
      expect(contatos.contatos, isA<List<ContatoModel>>());
    });

    test('Adicionar novo contato', () async {
      var contato = ContatoModel("", "", "", faker.person.firstName(),
          999999999, 2, "", "teste@email.com", "", false, "ff8d98c4");
      await repository.criar(contato);
      var lista = await repository.obterContatos(false, false);
      bool encontrado = false;
      for (var c in lista.contatos) {
        if (c.nome == contato.nome &&
            c.numero == contato.numero &&
            c.email == contato.email &&
            c.foto == contato.foto &&
            c.favorito == contato.favorito) {
          encontrado = true;
          objectId = c.objectId;
          break;
        }
      }
      expect(encontrado, true);
      var contato2 = ContatoModel("", "", "", "Contato Teste", 88888888, 2, "",
          "teste2@email.com", "", false, "ff8d98c4");
      await repository.criar(contato);
    });

    test('Obter Contato', () async {
      var contato = await repository.getContato(objectId);
      expect(contato, isA<ContatoModel>());
      expect(contato.objectId, equals(objectId));
    });

    test('Atualizar contato existente', () async {
      var contato = await repository.getContato(objectId);

      contato.favorito = true;
      contato.nome = "${contato.nome} atualizado";

      await repository.atualizar(contato);
      var contatoAtualizado = await repository.getContato(objectId);

      expect(contatoAtualizado.nome, equals(contato.nome));
      expect(contatoAtualizado.favorito, isTrue);
    });

    test('Remover um contato existente', () async {
      await repository.remover(objectId);

      await expectLater(
        () async => await repository.getContato(objectId),
        throwsA(isA<DioException>()),
      );
    });
  });
}
