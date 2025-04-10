import 'package:flutter/material.dart';
import '/controllers/addressScreenController.dart';
import '/models/user_registration_data.dart';
import 'package:flutter/services.dart';
import '/interface/victimNeeds.dart'; // Siguiente pantalla

class AddressScreen extends StatefulWidget {
  final UserRegistrationData userData;
  const AddressScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late AddressController controller;

  @override
  void initState() {
    super.initState();
    controller = AddressController(widget.userData);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Dirección de contacto',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField("Línea de Dirección 1", controller.addressLine1Controller),
                    _buildTextField("Línea de Dirección 2", controller.addressLine2Controller),
                    _buildTextField("País", controller.countryController),
                    _buildTextField("Provincia", controller.provinceController),
                    _buildTextField("Localidad", controller.cityController),
                    _buildTextField("Código postal", controller.postalCodeController),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (controller.validateFields()) {
                          controller.submitAddress();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Dirección enviada correctamente")),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VictimNecessities(userData: widget.userData),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Por favor, completa los campos obligatorios.")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Siguiente paso', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    final bool isPostalCode = label.toLowerCase().contains("código postal");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.play_arrow),
          border: const UnderlineInputBorder(),
        ),
        keyboardType: isPostalCode ? TextInputType.number : TextInputType.text,
        inputFormatters: isPostalCode
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
      ),
    );
  }
}
