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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: controller.nombreController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.black),
                              labelText: 'Nombre',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: controller.apellidosController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.black),
                              labelText: 'Apellidos',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: controller.correoController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.black),
                              labelText: 'Correo electrónico',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

                            ),
                            validator: validateEmailWithoutEmpty,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: controller.passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Colors.black),
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: validatePasswordWithoutEmpty,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: controller.repetirPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
                              labelText: 'Repite Contraseña',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) => validateConfirmPasswordWithoutEmpty(
                              controller.passwordController.text,
                              value,
                            ),
                          ),
                        ),
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
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                              labelText: 'Fecha de nacimiento',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: controller.telefonoController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone, color: Colors.black),
                              labelText: 'Número de teléfono',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: validatePhoneWithoutEmpty,
                          ),
                        ),
                        const SizedBox(height: 20),
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
