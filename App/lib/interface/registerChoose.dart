import 'package:app/services/login_validators.dart';
import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '../controllers/registerChooseController.dart';
import '../models/user_registration_data.dart';
import 'package:flutter/services.dart';
import '../services/dni_input_formatter.dart';

class RegisterChoose extends StatefulWidget {
  final RegisterFlowManager manager;
  RegisterChoose(this.manager);

  @override
  _RegisterChooseState createState() => _RegisterChooseState();
}

class _RegisterChooseState extends State<RegisterChoose> {
  late RegisterChooseController _controller;
  final _formKey = GlobalKey<FormState>(); // NUEVO

  @override
  void initState() {
    super.initState();
    _controller = RegisterChooseController(widget.manager);

    _controller.nameController.text = _controller.name ?? '';
    _controller.surnameController.text = _controller.surname ?? '';
    _controller.birthDateController.text = _controller.birthDate ?? '';
    _controller.phoneController.text = _controller.phone ?? '';
    _controller.identificationController.text = _controller.identification ?? '';
  }

  void _saveState() {
    _controller.name = _controller.nameController.text;
    _controller.surname = _controller.surnameController.text;
    _controller.birthDate = _controller.birthDateController.text;
    _controller.phone = _controller.phoneController.text;
    _controller.identification = _controller.identificationController.text;
    _controller.saveProgress();
  }

  void nextStep(String rol) {
    _saveState();
    _controller.submitForm(rol, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              value: 2 / 6,
              backgroundColor: Colors.red[100],
              color: Colors.white,
              minHeight: 4,
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.red,
      body: Center(
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey, // NUEVO
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bienvenido a Solidary Hub",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _controller.nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                        labelText: 'Nombre*',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: validateIsEmpty,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _controller.surnameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                        labelText: 'Apellidos*',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: validateIsEmpty,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
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
                        prefixIcon: Icon(Icons.calendar_view_day, color: Colors.black),
                        labelText: 'Fecha de nacimiento*',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: validateIsEmpty,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _controller.identificationController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(9),
                        DniInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.card_membership, color: Colors.black),
                        labelText: 'DNI*',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: validateIdentification,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _controller.phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone, color: Colors.black),
                        labelText: 'Teléfono*',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: validatePhone,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                nextStep('Victim');
                              }
                            },
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
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                nextStep('Volunteer');
                              }
                            },
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
            ),
          ],
        ),
      ),
    );
  }
}
