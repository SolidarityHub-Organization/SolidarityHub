import 'package:flutter/material.dart';
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
                  Image.asset('assets/logo.png', height: 100),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: CustomFormBuilder(
                      formKey: _formKey,
                      children: [
                        _buildField(Icons.person, 'Nombre', controller.nombreController, validateIsEmpty),
                        _buildField(Icons.person, 'Apellidos', controller.apellidosController, validateIsEmpty),
                        _buildField(Icons.email, 'Correo electrónico', controller.correoController, validateEmail),
                        _buildField(Icons.lock, 'Contraseña', controller.passwordController, validatePassword, obscure: true),
                        _buildField(Icons.lock_outline, 'Repite Contraseña', controller.repetirPasswordController,
                                (value) => validateWithConfirmPassword(controller.passwordController.text, value), obscure: true),

                        // Fecha de nacimiento
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: controller.fechaNacimientoController,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/"
                                    "${pickedDate.month.toString().padLeft(2, '0')}/"
                                    "${pickedDate.year}";
                                setState(() {
                                  controller.fechaNacimientoController.text = formattedDate;
                                });
                              }
                            },
                            validator: validateIsEmpty,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                              labelText: 'Fecha de nacimiento',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),

                        _buildField(Icons.phone, 'Número de teléfono', controller.telefonoController, validatePhone),
                        SizedBox(height: 20),
                        buildCustomButton(
                          "Guardar y Salir",
                              () {
                            if (_formKey.currentState!.validate()) {
                              controller.saveData(context, widget.id, widget.role);
                            }
                          },
                          verticalPadding: 15,
                          horizontalPadding: 50,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de retroceso arriba a la izquierda
          Positioned(
            top: 16,
            left: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/ajustes'); // Ajusta la ruta si es necesario
              },
              hoverColor: Colors.white.withOpacity(0.1),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      IconData icon,
      String label,
      TextEditingController controller,
      FormFieldValidator<String>? validator, {
        bool obscure = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
