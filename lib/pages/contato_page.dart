import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lista_telefonica/mascaras.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/cor.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lista_telefonica/repositories/contatos_back4app_repository.dart';
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
  String _selectedItem = 'Tipo';
  bool edit = false;
  ContatosBack4AppRepository contatoRepository = ContatosBack4AppRepository();
  var contatoModel = ContatoModel("", "", "", "", 0, 0, "", "", "", false, "");
  bool isPhoneNumberEnabled = false;
  String erro = "";
  var _contatos = ContatosModel([]);
  var mascaras = Mascaras();

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
        isPhoneNumberEnabled = true;
        numeroController.text = widget.contato!.numero.toString();
        numeroController.value = numeroController.value.copyWith(
          text: mascaras.mascaraTelefone
              .maskText(widget.contato!.numero.toString()),
          selection: TextSelection.collapsed(
            offset: mascaras.mascaraTelefone
                .maskText(widget.contato!.numero.toString())
                .length,
          ),
        );
      } else if (widget.contato!.marcadorNumero == 2) {
        // Celular
        _selectedItem = 'Celular';
        isPhoneNumberEnabled = true;
        numeroController.text = widget.contato!.numero.toString();
        numeroController.value = numeroController.value.copyWith(
          text: mascaras.mascaraCelular
              .maskText(widget.contato!.numero.toString()),
          selection: TextSelection.collapsed(
            offset: mascaras.mascaraCelular
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
            toolbarTitle: 'Editar imagem',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Editar imagem',
        ),
      ],
    );
    if (croppedFile != null) {
      await GallerySaver.saveImage(croppedFile.path);
      image = XFile(croppedFile.path);
      setState(() {});
    }
  }

  bool isEmail(String texto) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(texto);
  }

  insertOrUpdate() async {
    if (edit == true) {
      debugPrint("clica3");
      await contatoRepository.atualizar(contatoModel);
    } else {
      debugPrint("clica4");
      await contatoRepository.criar(contatoModel);
      //await contatoRepository.obterContatos(false, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(edit ? 'Editar Contato' : 'Adicionar Contato'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Cor.createMaterialColor(const Color(0xFFD1C4E9));
                      }
                      return Cor.createMaterialColor(const Color(0xFFB39DDB));
                    },
                  ),
                  fixedSize: MaterialStateProperty.all(const Size(60, 44)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  debugPrint("clica");
                  if (nomeController.text.isEmpty) {
                    erro = "O nome é obrigatório";
                    _buildMsgErro(erro, context);
                    return;
                  }
                  if (_selectedItem == 'Tipo') {
                    erro = "Você deve selecionar o tipo do número";
                    _buildMsgErro(erro, context);
                    return;
                  }
                  if (numeroController.text.isEmpty) {
                    erro = "O número é obrigatório";
                    _buildMsgErro(erro, context);
                    return;
                  }
                  if (!isEmail(emailController.text) && emailController.text != "") {
                    erro = "Email informado não é um email válido";
                    _buildMsgErro(erro, context);
                    return;
                  }
                  debugPrint("clica2");
                  setState(() {
                    contatoModel.nome = nomeController.text;
                    contatoModel.sobrenome = sobrenomeController.text;
                    contatoModel.marcadorNumero =
                        _selectedItem == 'Telefone' ? 1 : 2;
                    contatoModel.numero = int.parse(numeroController.text
                        .replaceAll(RegExp(r'[\s()-]'), ''));
                    contatoModel.email = emailController.text;
                    if (image != null) {
                      contatoModel.foto = image!.path.toString();
                    }
                    Color cor = Cor.gerarCorAleatoria();
                    contatoModel.cor = Cor.colorToString(cor);
                    if (widget.contato != null) {
                      contatoModel.objectId = widget.contato!.objectId;
                    }
                  });
                  insertOrUpdate();
                  Navigator.pop(context);
                },
                child: const Text(
                  key: Key("salvar"),
                  "Salvar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSelectImage(context),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInput("Nome", [], nomeController, true,
                          Icons.person, "nomeTextField"),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInput("Sobrenome", [], sobrenomeController,
                          true, Icons.account_circle, "sobrenomeTextField"),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildDropDown(context, Icons.numbers, "dropdownKey"),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInput(
                          "Número",
                          [
                            _selectedItem == 'Telefone'
                                ? mascaras.mascaraTelefone
                                : mascaras.mascaraCelular,
                          ],
                          numeroController,
                          isPhoneNumberEnabled,
                          Icons.phone,
                          "numeroTextField"),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInput("Email", [], emailController, true,
                          Icons.email, "emailTextField"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      String texto,
      List<TextInputFormatter>? inputFormaters,
      TextEditingController controller,
      bool enabled,
      IconData iconData,
      String key) {
    return Container(
      width: 230,
      height: 55,
      child: Row(
        children: [
          Icon(iconData, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: Key(key),
              enabled: enabled,
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
                    color: Cor.createMaterialColor(const Color(0xFFBDBDBD)),
                  ),
                  borderRadius: BorderRadius.circular(35.0),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Cor.createMaterialColor(const Color(0xFFBDBDBD)),
                  ),
                  borderRadius: BorderRadius.circular(35.0),
                ),
              ),
            ),
          ),
        ],
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
                            .path;
                        String name = basename(image.path);
                        String fullPath = '$path/$name';
                        await File(image.path).copy(fullPath);

                        Navigator.pop(context);
                        //setState(() {});
                        cropImage(image);
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Cor.createMaterialColor(const Color(0xFFD1C4E9)),
            ),
            child: Center(
              child: image != null
                  ? ClipOval(
                      child: Image.file(
                        File(image!.path.toString()),
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        size: 60,
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

  _buildMsgErro(String erro, BuildContext context) {
    if (erro != "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  Widget _buildDropDown(BuildContext context, IconData iconData, String key) {
    return Row(
      children: [
        Icon(iconData, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Container(
          width: 317,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35.0),
            border: Border.all(
              color: Cor.createMaterialColor(const Color(0xFFBDBDBD)),
            ),
          ),
          child: DropdownButton<String>(
            key: Key(key),
            value: _selectedItem,
            onChanged: (String? newValue) {
              setState(() {
                _selectedItem = newValue!;
                if (_selectedItem == 'Telefone' || _selectedItem == 'Celular') {
                  isPhoneNumberEnabled = true;
                }
              });
            },
            icon: const Icon(Icons.arrow_drop_down),
            isExpanded: true,
            underline: Container(),
            items: <String>['Tipo', 'Telefone', 'Celular'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Text(
                        value,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
