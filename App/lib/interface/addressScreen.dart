import 'package:app/interface/schedules.dart';
import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '/controllers/addressScreenController.dart';
import '/models/user_registration_data.dart';
import 'package:flutter/services.dart';
import '/interface/victimNeeds.dart'; // Siguiente pantalla

class AddressScreen extends StatefulWidget {
  final RegisterFlowManager manager;
  const AddressScreen({Key? key, required this.manager}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _address1HasError = false;
  bool _countryHasError = false;
  bool _provinceHasError = false;
  bool _cityHasError = false;
  bool _postalCodeHasError = false;

  String? _address1Error;
  String? _countryError;
  String? _provinceError;
  String? _cityError;
  String? _postalCodeError;


  late AddressController controller;

  void _saveState(){
    final address = [
      controller.addressLine1Controller.text,
      controller.addressLine2Controller.text,
      controller.postalCodeController.text,
      controller.cityController.text,
      controller.provinceController.text,
      controller.countryController.text,
    ].join(', ');

    widget.manager.userData.address = address;
    widget.manager.saveStep();
  }

  void _validateAndSubmitAddress() {
    setState(() {
      _address1HasError = controller.addressLine1Controller.text.isEmpty;
      _countryHasError = controller.countryController.text.isEmpty;
      _provinceHasError = controller.provinceController.text.isEmpty;
      _cityHasError = controller.cityController.text.isEmpty;
      _postalCodeHasError = controller.postalCodeController.text.isEmpty;

      _address1Error = _address1HasError ? 'Este campo es obligatorio' : null;
      _countryError = _countryHasError ? 'Este campo es obligatorio' : null;
      _provinceError = _provinceHasError ? 'Este campo es obligatorio' : null;
      _cityError = _cityHasError ? 'Este campo es obligatorio' : null;
      _postalCodeError = _postalCodeHasError ? 'Este campo es obligatorio' : null;

      if (!(_address1HasError || _countryHasError || _provinceHasError || _cityHasError || _postalCodeHasError)) {
        _saveState();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dirección enviada correctamente")),
        );

        if(widget.manager.userData.role == 'Volunteer'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Schedules(manager: widget.manager),
            ),
          );
        }
        else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VictimNecessities(manager: widget.manager),
            ),
          );
        }

      }
    });
  }


  @override
  void initState() {
    super.initState();
    controller = AddressController(widget.manager.userData);

    final addressParts = (widget.manager.userData.address ?? '').split(', ');
    if (addressParts.length >= 6) {
      controller.addressLine1Controller.text = addressParts[0];
      controller.addressLine2Controller.text = addressParts[1];
      controller.postalCodeController.text = addressParts[2];
      controller.cityController.text = addressParts[3];
      controller.provinceController.text = addressParts[4];
      controller.countryController.text = addressParts[5];
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            _saveState();
            widget.manager.restorePreviousStep();
            Navigator.pop(context);
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: 3 / 6, // Paso 2 de 6
              backgroundColor: Colors.red[100],
              color: Colors.white,
              minHeight: 4,
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.red,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Image.asset('assets/logo.png', height: 100),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
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

                              _buildTextField("Línea de Dirección 1*", controller.addressLine1Controller),
                              _buildTextField("Línea de Dirección 2", controller.addressLine2Controller),
                              _buildTextField("País*", controller.countryController),
                              _buildTextField("Provincia*", controller.provinceController),
                              _buildTextField("Localidad*", controller.cityController),
                              _buildTextField("Código postal*", controller.postalCodeController),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: _validateAndSubmitAddress,
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    final bool isPostalCode = label.toLowerCase().contains("código postal");

    bool hasError;
    String? errorText;

    if (label.contains("Línea de Dirección 1")) {
      hasError = _address1HasError;
      errorText = _address1Error;
    } else if (label.contains("País")) {
      hasError = _countryHasError;
      errorText = _countryError;
    } else if (label.contains("Provincia")) {
      hasError = _provinceHasError;
      errorText = _provinceError;
    } else if (label.contains("Localidad")) {
      hasError = _cityHasError;
      errorText = _cityError;
    } else if (label.contains("Código postal")) {
      hasError = _postalCodeHasError;
      errorText = _postalCodeError;
    } else {
      hasError = false;
      errorText = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isPostalCode ? TextInputType.number : TextInputType.text,
        inputFormatters: isPostalCode ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          prefixIcon: const Icon(Icons.play_arrow),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
