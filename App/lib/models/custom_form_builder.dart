import 'package:flutter/material.dart';

class CustomFormBuilder extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool autoValidate;

  const CustomFormBuilder({
    Key? key,
    required this.formKey,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.autoValidate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}