import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import 'package:app/controllers/volunteerPreferencesController.dart';
import '/models/user_registration_data.dart';

class VolunteerPreferences extends StatefulWidget {
  final RegisterFlowManager manager;
  VolunteerPreferences({required this.manager});

  @override
  _VolunteerPreferencesState createState() => _VolunteerPreferencesState();
}

class _VolunteerPreferencesState extends State<VolunteerPreferences> {
  late VolunteerPreferencesController controller;

  @override
  void initState() {
    super.initState();
    controller = VolunteerPreferencesController(widget.manager);
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
          )
      ),
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
                      const Text('Seleccione sus preferencias:'),
                      const SizedBox(height: 10),
                      ...controller.preferences.keys.map((String pref) {
                        return CheckboxListTile(
                          title: Text(pref),
                          value: controller.preferences[pref],
                          activeColor: Colors.deepPurple,
                          onChanged: (bool? value) {
                            setState(() {
                              controller.togglePreference(pref);
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
                            widget.manager.saveStep();
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
