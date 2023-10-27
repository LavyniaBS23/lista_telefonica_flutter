import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_telefonica/cor.dart';
import 'package:lista_telefonica/mascaras.dart';
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
  var mascaras = Mascaras();

  bool favoritos = false;
  bool ordem = false;
  bool pesquisa = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obterContatos();
  }

  void obterContatos() async {
    _contatos = await contatoRepository.obterContatos(favoritos, ordem);

    if (mounted) {
      setState(() {});
    }
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
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        if (!pesquisa) {
                          pesquisa = true;
                        }
                        pesquisarContatos(value);
                      },
                      decoration: InputDecoration(
                          hintText: "Pesquisar por nome ou número",
                          contentPadding: const EdgeInsets.only(bottom: 2),
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                          ),
                          filled: true, // Preenche o fundo com a cor definida
                          fillColor:
                              Colors.grey[200], // Cor de preenchimento de fundo
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Arredondar as bordas
                            borderSide:
                                BorderSide.none, // Remove a borda padrão
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Cor.createMaterialColor(
                                const Color(0xFFD1C4E9)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear,
                                color: Cor.createMaterialColor(const Color(
                                    0xFFD1C4E9))), // Ícone para limpar o campo de pesquisa
                            onPressed: () {
                              searchController
                                  .clear(); // Limpa o campo de pesquisa
                            },
                          )),
                      cursorColor: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      ordem = !ordem;
                      _contatos = await contatoRepository.obterContatos(
                          favoritos, ordem);
                      setState(() {});
                    },
                    icon: Icon(
                      ordem ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Cor.createMaterialColor(
                          const Color(0xFFD1C4E9)), // Cor do ícone
                      size: 25, // Tamanho do ícone
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      favoritos = !favoritos;
                      _contatos = await contatoRepository.obterContatos(
                          favoritos, ordem);
                      setState(() {});
                    },
                    icon: Icon(
                      favoritos ? Icons.star : Icons.star_outline,
                      color: Cor.createMaterialColor(
                          const Color(0xFFFFF176)), // Cor do ícone
                      size: 25, // Tamanho do ícone
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple[200],
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContatoPage()),
            ).then((value) {
              obterContatos();
            });
          }),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
              child: _buildList(pesquisa ? contatosFiltrados : _contatos),
            )
          ]),
        ),
      ),
    ));
  }

  Widget _buildList(ContatosModel lista) {
    if (lista.contatos.isEmpty && pesquisa) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ops, nenhum resultado encontrado ",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "\u{1F615}",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    }
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
                    builder: (context) => ContatoDetalhesPage(
                        objectId: contato.objectId, cor: contato.cor)));
          },
          leading: ClipOval(
              child: contato.foto != ""
                  ? Container(
                      width: 55,
                      height: 55,
                      child: Image.file(
                        File(contato.foto),
                        fit: BoxFit.cover,
                        width: 55,
                        height: 55,
                      ),
                    )
                  : Container(
                      color: Cor.stringToColor(contato.cor),
                      width: 55,
                      height: 55,
                      child: Center(
                        child: Text(
                          primeiraLetra,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    )),
          title: Text(
            "${contato.nome} ${contato.sobrenome}",
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(contato.marcadorNumero == 1
              ? mascaras.mascaraTelefone.maskText(contato.numero.toString())
              : mascaras.mascaraCelular.maskText(contato.numero.toString())),
        );
      },
    );
  }
}
