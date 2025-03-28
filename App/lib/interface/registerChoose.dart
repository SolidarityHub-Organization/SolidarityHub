import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en pubspec.yaml

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegisterChoose(),
  ));
}

class RegisterChoose extends StatefulWidget {
  @override
  _RegisterChooseState createState() => _RegisterChooseState();
}

class _RegisterChooseState extends State<RegisterChoose> {
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _fechaController = TextEditingController();
  final _telefonoController = TextEditingController();

  DateTime? _fechaSeleccionada;
  String _rolSeleccionado = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[600],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Botón de regreso
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "S", // Aquí va tu logo
                style: TextStyle(
                  fontSize: 80,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(
                      controller: _nombreController,
                      label: "Nombre",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _apellidosController,
                      label: "Apellidos",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _telefonoController,
                      label: "Número de teléfono",
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Elige una opción de registro:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildRolButton("Afectado")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildRolButton("Voluntario")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: const UnderlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _fechaController,
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode()); // Cierra el teclado
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _fechaSeleccionada ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _fechaSeleccionada = picked;
            _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
          });
        }
      },
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.access_time),
        labelText: "Fecha de Nacimiento",
        border: UnderlineInputBorder(),
      ),
    );
  }

  Widget _buildRolButton(String rol) {
    final bool isSelected = _rolSeleccionado == rol;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _rolSeleccionado = rol;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red : Colors.red[100],
        foregroundColor: isSelected ? Colors.white : Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(rol),
    );
  }
}
