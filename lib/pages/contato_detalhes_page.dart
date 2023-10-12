import 'dart:convert';
import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/cor.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lista_telefonica/pages/contato_page.dart';
import 'package:lista_telefonica/pages/home_page.dart';
import 'package:lista_telefonica/repositories/contatos_back4app_repository.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

class ContatoDetalhesPage extends StatefulWidget {
  final String objectId;

  const ContatoDetalhesPage({Key? key, required this.objectId})
      : super(key: key);

  @override
  State<ContatoDetalhesPage> createState() => _ContatoDetalhesPageState();
}

class _ContatoDetalhesPageState extends State<ContatoDetalhesPage> {
  ContatoModel contato = ContatoModel.vazio();

  ContatosBack4AppRepository contatoRepository = ContatosBack4AppRepository();

  @override
  void initState() {
    super.initState();
    getContato();
  }

  getContato() async {
    contato = await contatoRepository.getContato(widget.objectId);
    print(contato.nome);
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
                            if (contato.favorito == false) {
                              contato.favorito = true;
                            } else {
                              contato.favorito = false;
                            }
                          });
                          await contatoRepository.atualizar(contato);
                        },
                        icon: Icon(
                          contato.favorito ? Icons.star : Icons.star_outline,
                          color: Cor.createMaterialColor(
                              const Color(0xFFFFF176)), // Cor do ícone
                          size: 20, // Tamanho do ícone
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
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
                          size: 20, // Tamanho do ícone
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                           Share.share(jsonEncode(contato.toJsonCompartilhar()));
                        },
                        icon: Icon(
                          Icons.share,
                          color: Cor.createMaterialColor(
                              const Color(0xFFD1C4E9)), // Cor do ícone
                          size: 20, // Tamanho do ícone
                        ),
                      )
                    ])),
              ],
            ),
            body: Container(
              width: double.infinity,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildImageContato(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              contato.nome,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " ${contato.sobrenome}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          contato.numero.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          contato.email,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ])),
            )));
  }

  Widget _buildImageContato() {
    String primeiraLetra = '';
    if (contato.nome != null && contato.nome.isNotEmpty) {
      primeiraLetra = contato.nome.substring(0, 1);
    }
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Cor.createMaterialColor(const Color(0xFFD1C4E9)),
          ),
          child: Center(
            child: contato.foto.toString() != ""
                  ? Container(
                      width: 40,
                      height: 40,
                      child: const Text("teste")/*Image.file(File(contato.foto.toString()))*/,
                    )
                  :
                Center(
              child: Text(
                primeiraLetra,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
