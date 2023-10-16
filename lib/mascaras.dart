import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Mascaras{
  var mascaraTelefone = MaskTextInputFormatter(
      mask: '(##) ####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var mascaraCelular = MaskTextInputFormatter(
      mask: '(##) 9 ####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
}