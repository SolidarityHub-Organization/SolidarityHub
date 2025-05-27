import 'package:flutter/material.dart';
import '../controllers/afectadosNecessitiesController.dart';
import 'package:app/services/register_flow_manager.dart';

class AfectadosNecessities extends StatefulWidget {
  final RegisterFlowManager manager;

  const AfectadosNecessities({Key? key, required this.manager}) : super(key: key);

  @override
  _AfectadosNecessitiesState createState() => _AfectadosNecessitiesState();
}

class _AfectadosNecessitiesState extends State<AfectadosNecessities> {
  late AfectadosNecessitiesController controller;
  bool showError = false;

  @override
  void initState() {
    super.initState();
    controller = AfectadosNecessitiesController(widget.manager);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            widget.manager.restorePreviousStep();
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ya casi hemos terminado...',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        const Text('Seleccione sus necesidades:', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 12),
                        ...controller.needs.map((item) {
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.deepPurple,
                            title: Text(item.label),
                            value: item.selected,
                            onChanged: (value) {
                              setState(() {
                                item.selected = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                        if (showError)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              '* Se debe escoger al menos 1',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.getSelectedNeeds().isEmpty) {
                                setState(() {
                                  showError = true;
                                });
                              } else {
                                setState(() {
                                  showError = false;
                                });
                                controller.submit();
                                widget.manager.saveStep(); // Guardar estado final
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Formulario enviado")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Finalizar el registro',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
