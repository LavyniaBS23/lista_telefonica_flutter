import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/cor.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lista_telefonica/pages/home_page.dart';
import 'package:lista_telefonica/repositories/contatos_back4app_repository.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart';

class ContatoPage extends StatefulWidget {
  final ContatoModel? contato;

  const ContatoPage({Key? key, this.contato}) : super(key: key);

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  TextEditingController nomeController = TextEditingController(text: "");
  TextEditingController sobrenomeController = TextEditingController(text: "");
  TextEditingController marcadorNumeroController =
      TextEditingController(text: "");
  TextEditingController numeroController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");

  XFile? image;
  String _selectedItem = 'Selecione';
  bool edit = false;
  ContatosBack4AppRepository contatoRepository = ContatosBack4AppRepository();
  var contatoModel = ContatoModel("", "", "", "", 0, 0, "", "", "", false);

  @override
  void initState() {
    super.initState();

    if (widget.contato != null) {
      edit = true;
      // se for diferente de null, é edição de contato
      nomeController.text = widget.contato!.nome;
      sobrenomeController.text = widget.contato!.sobrenome;
      marcadorNumeroController.text = widget.contato!.marcadorNumero.toString();
      numeroController.text = widget.contato!.numero.toString();
      emailController.text = widget.contato!.email;
      
      if (widget.contato!.marcadorNumero == 1) {
        // Telefone
        _selectedItem = 'Telefone';
        numeroController.text = widget.contato!.numero.toString();
        numeroController.value = numeroController.value.copyWith(
          text: mascaraTelefone.maskText(widget.contato!.numero.toString()),
          selection: TextSelection.collapsed(
            offset: mascaraTelefone
                .maskText(widget.contato!.numero.toString())
                .length,
          ),
        );
      } else if (widget.contato!.marcadorNumero == 2) {
        // Celular
        _selectedItem = 'Celular';
        numeroController.text = widget.contato!.numero.toString();
        numeroController.value = numeroController.value.copyWith(
          text: mascaraCelular.maskText(widget.contato!.numero.toString()),
          selection: TextSelection.collapsed(
            offset: mascaraCelular
                .maskText(widget.contato!.numero.toString())
                .length,
          ),
        );
      }

      if (widget.contato!.foto.isNotEmpty) {
        image = XFile(widget.contato!.foto);
      }
    }
  }

  var mascaraTelefone = MaskTextInputFormatter(
      mask: '(##) ####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var mascaraCelular = MaskTextInputFormatter(
      mask: '(##) 9 ####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  cropImage(XFile imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      await GallerySaver.saveImage(croppedFile.path);
      image = XFile(croppedFile.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(edit ? 'Editar Contato' : 'Criar Contato'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Cor.createMaterialColor(
                          const Color(0xFFD1C4E9)); //pressionado
                    }
                    return Cor.createMaterialColor(
                        const Color(0xFFB39DDB)); // padrão
                  },
                ),
                fixedSize: MaterialStateProperty.all(const Size(56, 40)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  contatoModel.nome = nomeController.text;
                  contatoModel.sobrenome = sobrenomeController.text;
                  contatoModel.marcadorNumero =
                      _selectedItem == 'Telefone' ? 1 : 2;
                  contatoModel.numero = int.parse(
                      numeroController.text.replaceAll(RegExp(r'[\s()-]'), ''));
                  contatoModel.email = emailController.text;
                  contatoModel.foto = (image != null ? image.toString() : "");
                  if (widget.contato != null) {
                    contatoModel.objectId = widget.contato!.objectId;
                  }
                });
                if (edit) {
                  await contatoRepository.atualizar(contatoModel);
                } else {
                  await contatoRepository.criar(contatoModel);
                }
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
              child: const Text(
                "Salvar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Centraliza verticalmente
              children: [
                _buildSelectImage(context),
                const SizedBox(height: 20),
                _buildInput("Nome", [], nomeController),
                const SizedBox(height: 10),
                _buildInput("Sobrenome", [], sobrenomeController),
                const SizedBox(height: 10),
                _buildDropDown(context),
                const SizedBox(height: 10),
                _buildInput(
                    "Número",
                    [
                      _selectedItem == 'Telefone'
                          ? mascaraTelefone
                          : mascaraCelular,
                    ],
                    numeroController),
                const SizedBox(height: 10),
                _buildInput("Email", [], emailController),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildInput(String texto, List<TextInputFormatter>? inputFormaters,
      TextEditingController controller) {
    return Container(
      width: 230,
      height: 35,
      child: TextField(
        controller: controller,
        inputFormatters: inputFormaters,
        cursorColor: Colors.black,
        decoration: InputDecoration(
            labelText: texto, // Rótulo flutuante
            labelStyle: const TextStyle(
              color: Colors.black38,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Cor.createMaterialColor(const Color(0xFFBDBDBD))),
              borderRadius: BorderRadius.circular(25.0),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Cor.createMaterialColor(const Color(0xFFBDBDBD))),
              borderRadius: BorderRadius.circular(25.0),
            )),
      ),
    );
  }

  Widget _buildSelectImage(BuildContext context) {
    return TextButton(
      onPressed: () async {
        showModalBottomSheet(
            context: context,
            builder: (_) {
              return Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: const Text("Câmera"),
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();

                      var image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        String path = (await path_provider
                                .getApplicationDocumentsDirectory())
                            .toString();

                        String name = basename(image!.path);
                        await image!.saveTo("$path/$name");
                        await GallerySaver.saveImage(image!.path);
                        Navigator.pop(context);
                        //setState(() {});
                        cropImage(image!);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text("Galeria"),
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();

                      image =
                          await picker.pickImage(source: ImageSource.gallery);
                      Navigator.pop(context);
                      //setState(() {});
                      cropImage(image!);
                    },
                  ),
                ],
              );
            });
      },
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Cor.createMaterialColor(const Color(0xFFD1C4E9)),
            ),
            child: Center(
              child: image.toString() != ""
                  ? Container(
                      width: 40,
                      height: 40,
                      child:
                          Text("TEste") /*Image.file(File(image.toString()))*/,
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            "Adicionar Imagem",
            style: TextStyle(color: Colors.deepPurple, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown(BuildContext context) {
    return Container(
      width: 230,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          color: Cor.createMaterialColor(const Color(0xFFBDBDBD)),
        ),
      ),
      child: DropdownButton<String>(
        value: _selectedItem,
        onChanged: (String? newValue) {
          setState(() {
            _selectedItem = newValue!;
          });
        },
        icon: const Icon(Icons.arrow_drop_down),
        isExpanded: true,
        underline: Container(),
        items: <String>['Selecione', 'Telefone', 'Celular'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                value,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
