import 'package:flutter/services.dart';

class TimeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    final StringBuffer newText = StringBuffer();
    if(newTextLength < oldValue.text.length){
      newText.write(newValue.text.substring(0, newTextLength));
    } else if(newTextLength == 2 && !newValue.text.contains("/")) {
      newText.write(newValue.text.substring(0, 2)+"/");
      selectionIndex++;
    } else if(newTextLength == 5 && !newValue.text.contains(" ")) {
      newText.write(newValue.text.substring(0, 5)+" ");
      selectionIndex++;
    } else if(newTextLength == 8 && !newValue.text.contains(":")) {
      newText.write(newValue.text.substring(0, 8)+":");
      selectionIndex++;
    } else if(newTextLength < 12) {
      newText.write(newValue.text.substring(0, newTextLength));
    } else {
      return oldValue;
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}