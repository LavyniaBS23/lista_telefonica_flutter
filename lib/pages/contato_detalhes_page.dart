import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/cor.dart';
import 'package:lista_telefonica/pages/contato_page.dart';
import 'package:lista_telefonica/pages/home_page.dart';
import 'package:lista_telefonica/repositories/contatos_back4app_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lista_telefonica/mascaras.dart';

class ContatoDetalhesPage extends StatefulWidget {
  final String objectId;
  final String cor;

  const ContatoDetalhesPage(
      {Key? key, required this.objectId, required this.cor})
      : super(key: key);

  @override
  State<ContatoDetalhesPage> createState() => _ContatoDetalhesPageState();
}

class _ContatoDetalhesPageState extends State<ContatoDetalhesPage> {
  ContatoModel contato = ContatoModel.vazio();

  ContatosBack4AppRepository contatoRepository = ContatosBack4AppRepository();
  var mascaras = Mascaras();
  late Color cor;
  @override
  void initState() {
    super.initState();
    cor = Cor.stringToColor(widget.cor);
    getContato();
  }

  getContato() async {
    contato = await contatoRepository.getContato(widget.objectId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            contato.favorito = !contato.favorito;
                          });
                          await contatoRepository.atualizar(contato);
                        },
                        icon: Icon(
                          contato.favorito ? Icons.star : Icons.star_outline,
                          color: Cor.createMaterialColor(
                              const Color(0xFFFFF176)), // Cor do ícone
                          size: 25, // Tamanho do ícone
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContatoPage(
                                        contato: contato,
                                      )));
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Cor.createMaterialColor(
                              const Color(0xFFD1C4E9)), // Cor do ícone
                          size: 25, // Tamanho do ícone
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          var tipo = contato.marcadorNumero == 1
                              ? "Telefone"
                              : "Celular";
                          var num = contato.marcadorNumero == 1
                              ? mascaras.mascaraTelefone
                                  .maskText(contato.numero.toString())
                              : mascaras.mascaraCelular
                                  .maskText(contato.numero.toString());
                          var texto =
                              "Contato: ${contato.nome} ${contato.sobrenome}\n${tipo}: ${num}";
                          Share.share(texto);
                        },
                        icon: Icon(
                          Icons.share,
                          color: Cor.createMaterialColor(
                              const Color(0xFFD1C4E9)), // Cor do ícone
                          size: 25, // Tamanho do ícone
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await contatoRepository.remover(contato.objectId);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Cor.createMaterialColor(
                              const Color(0xFFD1C4E9)), // Cor do ícone
                          size: 25, // Tamanho do ícone
                        ),
                      )
                    ])),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                _buildImageContato(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Text(
                      "${contato.nome} ${contato.sobrenome}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Text(
                      "Dados de contato:",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(Icons.phone, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        contato.marcadorNumero == 1
                            ? mascaras.mascaraTelefone
                                .maskText(contato.numero.toString())
                            : mascaras.mascaraCelular
                                .maskText(contato.numero.toString()),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(Icons.email, color: Colors.deepPurple),
                      ),
                      Text(
                        contato.email,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            )));
  }

  Widget _buildImageContato() {
    String primeiraLetra = '';
    if (contato.nome != null && contato.nome.isNotEmpty) {
      primeiraLetra = contato.nome.substring(0, 1);
    }
    return Container(
      width: double.infinity,
      height: 300,
      child: contato.foto.toString() != ""
          ? GestureDetector(
              child: Container(
                width: double.infinity,
                height: 90,
                child: Image.file(
                  File(contato.foto.toString()),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 90,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Container(
                            color: Colors.black,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: Image.file(File(contato.foto.toString()),
                                      fit: BoxFit.contain),
                                ),
                                Positioned(
                                  left: 10,
                                  top:
                                      500, // Ajuste a posição vertical do texto conforme necessário
                                  child: Text(
                                    "${contato.nome} ${contato.sobrenome}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Container(
              color: cor,
              child: Center(
                child: Text(
                  primeiraLetra,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                ),
              ),
            ),
    );
  }
}
