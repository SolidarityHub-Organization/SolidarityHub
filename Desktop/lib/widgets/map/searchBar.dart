import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const MapSearchBar({Key? key, required this.controller, required this.onSearch, required this.onClear})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Buscar dirección...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty ? IconButton(icon: Icon(Icons.clear), onPressed: onClear) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        onSubmitted: onSearch,
      ),
    );
  }
}
