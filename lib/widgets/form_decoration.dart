import 'package:material_ui/material_ui.dart';

const BorderRadius formFieldRadius = BorderRadius.all(Radius.circular(5.0));

InputDecoration formFieldDecoration(
  String labelText, {
  String? hintText,
  String? helperText,
  String? errorText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    helperText: helperText,
    errorText: errorText,
    suffixIcon: suffixIcon,
    border: const OutlineInputBorder(borderRadius: formFieldRadius),
  );
}
