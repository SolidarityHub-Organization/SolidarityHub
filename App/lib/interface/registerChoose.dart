import 'package:flutter/material.dart';
import '../controllers/registerChooseController.dart';
import '../models/user_registration_data.dart';
import 'package:flutter/services.dart';

class RegisterChoose extends StatefulWidget {
  final UserRegistrationData userData;
  RegisterChoose(this.userData);

  @override
  _RegisterChooseState createState() => _RegisterChooseState();
}

class _RegisterChooseState extends State<RegisterChoose> {
  bool _nameHasError = false;
  bool _surnameHasError = false;
  bool _birthDateHasError = false;
  bool _phoneHasError = false;
  bool _identificationHasError = false;

  String? _nameErrorText;
  String? _surnameErrorText;
  String? _birthDateErrorText;
  String? _phoneErrorText;
  String? _identificationErrorText;

  late RegisterChooseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterChooseController(widget.userData);
  }

  void _submitFormConValidacion(String rol, BuildContext context) {
    setState(() {
      _nameHasError = false;
      _surnameHasError = false;
      _birthDateHasError = false;
      _phoneHasError = false;
      _identificationHasError = false;

      _nameErrorText = null;
      _surnameErrorText = null;
      _birthDateErrorText = null;
      _phoneErrorText = null;
      _identificationErrorText = null;

      bool isValid = true;

      if (_controller.nameController.text.trim().isEmpty) {
        _nameHasError = true;
        _nameErrorText = 'El nombre no puede estar vacío';
        isValid = false;
      }

      if (_controller.surnameController.text.trim().isEmpty) {
        _surnameHasError = true;
        _surnameErrorText = 'Los apellidos no pueden estar vacíos';
        isValid = false;
      }

      if (_controller.birthDateController.text.trim().isEmpty) {
        _birthDateHasError = true;
        _birthDateErrorText = 'La fecha de nacimiento es obligatoria';
        isValid = false;
      }

      if (_controller.phoneController.text.trim().isEmpty) {
        _phoneHasError = true;
        _phoneErrorText = 'El teléfono no puede estar vacío';
        isValid = false;
      }


      if (_controller.phoneController.text.trim().isEmpty) {
        _phoneHasError = true;
        _phoneErrorText = 'El teléfono no puede estar vacío';
        isValid = false;
      } else if (!_controller.isValidPhone(_controller.phoneController.text.trim())) {
        _phoneHasError = true;
        _phoneErrorText = 'Introduce un número válido de 9 dígitos';
        isValid = false;
      }

      if(_controller.identificationController.text.trim().isEmpty){
        _identificationHasError = true;
        _identificationErrorText = 'El DNI no puede estar vacío';
        isValid = false;
      }
      else if(!_controller.isValidIdentification(_controller.identificationController.text.trim())){
        _identificationHasError = true;
        _identificationErrorText = 'El DNI tiene que seguir el formato de este ejemplo: 00000000X';
        isValid = false;
      }

      if (isValid) {
        _controller.submitForm(rol, context);
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100), // Logo igual que loginUI
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Bienvenido a Solidary Hub",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  //Nombre
                  TextField(
                    controller: _controller.nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre*',
                      errorText: _nameErrorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _nameHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _nameHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  //Apellidos
                  TextField(
                    controller: _controller.surnameController,
                    decoration: InputDecoration(
                      labelText: 'Apellidos*',
                      errorText: _surnameErrorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _surnameHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _surnameHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  //Fecha nac
                  TextField(
                    controller: _controller.birthDateController,
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
                          _controller.birthDateController.text = formattedDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento*',
                      errorText: _birthDateErrorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _birthDateHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _birthDateHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // DNI
                  TextField(
                    controller: _controller.identificationController,
                    decoration: InputDecoration(
                      labelText: 'DNI*',
                      errorText: _identificationErrorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _identificationHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _identificationHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  //Telefono
                  TextField(
                    controller: _controller.phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Teléfono*',
                      errorText: _phoneErrorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _phoneHasError ? Colors.red : Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _phoneHasError ? Colors.red : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),


                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: ()=> _submitFormConValidacion('Victim', context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text("Afectado", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _submitFormConValidacion('Volunteer', context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text("Voluntario", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
