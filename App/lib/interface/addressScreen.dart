import 'package:flutter/material.dart';
import '/controllers/addressScreenController.dart';
// Main para ejecutar solo la ventana
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solidary Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: AddressScreen(), // Pantalla de inicio
    );
  }
}

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final AddressController controller = AddressController();

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
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.play_arrow), // ← flechita
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
