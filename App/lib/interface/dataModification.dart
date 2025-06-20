import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/custom_form_builder.dart';
import '../models/button_creator.dart';
import '../services/login_validators.dart';
import '../controllers/dataModificationController.dart';

class DataModification extends StatefulWidget {
  final int id;
  final String role;

  DataModification({required this.id, required this.role});

  @override
  _DataModificationState createState() => _DataModificationState();
}

class _DataModificationState extends State<DataModification> {
  final _formKey = GlobalKey<FormState>();
  final DataModificationController controller = DataModificationController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextField(
                            controller: controller.nombreController,
                            label: 'Nombre',
                            icon: Icons.person,
                          ),
                          buildTextField(
                            controller: controller.apellidosController,
                            label: 'Apellidos',
                            icon: Icons.person,
                          ),
                          buildTextField(
                            controller: controller.correoController,
                            label: 'Correo electrónico',
                            icon: Icons.email,
                            validator: validateEmailWithoutEmpty,
                          ),
                          buildTextField(
                            controller: controller.passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            obscureText: true,
                            helperText: 'Debe tener al menos 6 caracteres',
                            validator: validatePasswordWithoutEmpty,
                          ),
                          buildTextField(
                            controller: controller.repetirPasswordController,
                            label: 'Repite Contraseña',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) => validateConfirmPasswordWithoutEmpty(
                              controller.passwordController.text,
                              value,
                            ),
                          ),
                          buildTextField(
                            controller: controller.fechaNacimientoController,
                            label: 'Fecha de nacimiento',
                            icon: Icons.calendar_today,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                                setState(() {
                                  controller.fechaNacimientoController.text = formattedDate;
                                });
                              }
                            },
                          ),
                          buildTextField(
                            controller: controller.telefonoController,
                            label: 'Número de teléfono',
                            icon: Icons.phone,
                            validator: validatePhoneWithoutEmpty,
                          ),
                          const SizedBox(height: 20),
                          buildCustomButton(
                            "Guardar y Salir",
                                () {
                              if (_formKey.currentState!.validate()) {
                                final noChanges = controller.nombreController.text.trim().isEmpty &&
                                    controller.apellidosController.text.trim().isEmpty &&
                                    controller.correoController.text.trim().isEmpty &&
                                    controller.passwordController.text.trim().isEmpty &&
                                    controller.repetirPasswordController.text.trim().isEmpty &&
                                    controller.fechaNacimientoController.text.trim().isEmpty &&
                                    controller.telefonoController.text.trim().isEmpty;

                                if (noChanges) {
                                  Navigator.pop(context);
                                  return;
                                }

                                controller.saveData(context, widget.id, widget.role);
                              }
                            },
                            verticalPadding: 15,
                            horizontalPadding: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => Navigator.pop(context),
              hoverColor: Colors.white.withOpacity(0.1),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    String? helperText,
    FormFieldValidator<String>? validator,
    GestureTapCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: label,
          helperText: helperText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: validator,
      ),
    );
  }
}
