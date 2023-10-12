import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/pages/contato_detalhes_page.dart';
import 'package:lista_telefonica/pages/contato_page.dart';
import 'package:lista_telefonica/repositories/contatos_back4app_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController(text: "");
  ContatosBack4AppRepository contatoRepository = ContatosBack4AppRepository();
  var _contatos = ContatosModel([]);
  ContatosModel contatosFiltrados = ContatosModel([]);

  bool favoritos = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obterContatos();
  }

  void obterContatos() async {
    _contatos = await contatoRepository.obterContatos(favoritos);
    setState(() {});
  }

  void pesquisarContatos(String query) {
    contatosFiltrados.contatos.clear();
    for (var contato in _contatos.contatos) {
      final nome = contato.nome.toLowerCase();
      final sobrenome = contato.sobrenome.toLowerCase();
      final numero = contato.numero.toString();

      if (nome.contains(query.toLowerCase()) ||
          sobrenome.contains(query.toLowerCase()) ||
          numero.contains(query)) {
        contatosFiltrados.contatos.add(contato);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        //title: const Text("Contatos"),
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  pesquisarContatos(value);
                },
                decoration: InputDecoration(
                    hintText: "Pesquisar por nome ou número",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    filled: true, // Preenche o fundo com a cor definida
                    fillColor:
                        Colors.grey[200], // Cor de preenchimento de fundo
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(25.0), // Arredondar as bordas
                      borderSide: BorderSide.none, // Remove a borda padrão
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(
                          Icons.clear), // Ícone para limpar o campo de pesquisa
                      onPressed: () {
                        searchController.clear(); // Limpa o campo de pesquisa
                      },
                    )),
                cursorColor: Colors.black,

              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple[200],
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ContatoPage()));
          }),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
              child: _buildList(contatosFiltrados.contatos.isNotEmpty
                  ? contatosFiltrados
                  : _contatos),
            )
          ]),
        ),
      ),
    ));
  }

  Widget _buildList(ContatosModel lista) {
    return ListView.builder(
      itemCount: lista.contatos.length,
      itemBuilder: (context, index) {
        final contato = lista.contatos[index];
        final primeiraLetra = contato.nome.substring(0, 1);

        return ListTile(
          key: Key(contato.objectId),
          onTap: () {
            //Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContatoDetalhesPage(objectId: contato.objectId)));
          },
          leading: ClipOval(
            child: contato.foto != ""
                ? Container(
                    color: Colors.blue,
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Text(
                        primeiraLetra,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    child: Text("Teste") /*Image.file(File(contato.foto))*/,
                  ),
          ),
          title: Text("${contato.nome} ${contato.sobrenome}"),
          subtitle: Text(contato.numero.toString()),
        );
      },
    );
  }
}
