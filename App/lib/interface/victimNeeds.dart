import 'package:flutter/material.dart';
import 'package:app/controllers/victimNeedsController.dart';
import '/models/user_registration_data.dart';

class VictimNecessities extends StatefulWidget {
  final UserRegistrationData userData;
  VictimNecessities({required this.userData});

  @override
  _VictimNecessitiesState createState() => _VictimNecessitiesState();
}

class _VictimNecessitiesState extends State<VictimNecessities> {
  late VictimNeedsController controller;

  @override
  void initState() {
    super.initState();
    controller = VictimNeedsController(widget.userData);
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
              child: SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Ya casi hemos terminado...',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Seleccione sus necesidades:'),
                      const SizedBox(height: 10),
                      ...controller.needs.keys.map((String need) {
                        return CheckboxListTile(
                          title: Text(need),
                          value: controller.needs[need],
                          activeColor: Colors.deepPurple,
                          onChanged: (bool? value) {
                            setState(() {
                              controller.toggleNeed(need);
                            });
                          },
                        );
                      }).toList(),
                      if (!controller.isAtLeastOneSelected())
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            '* Se debe escoger al menos 1',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: controller.isAtLeastOneSelected()
                              ? () {
                            controller.finalizeRegistration(context);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Finalizar el registro', style: TextStyle(color: Colors.white)),
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
    );
  }
}
