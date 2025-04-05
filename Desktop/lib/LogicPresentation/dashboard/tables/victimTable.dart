import 'package:flutter/material.dart';
import '../../../LogicBusiness/services/victimServices.dart';
import '../../../LogicPersistence/models/victimNeedsData.dart';

class VictimsTab extends StatefulWidget {
  final String selectedPeriod;

  const VictimsTab({Key? key, required this.selectedPeriod}) : super(key: key);

  @override
  _VictimsTabState createState() => _VictimsTabState();
}

class _VictimsTabState extends State<VictimsTab> {
  late Future<List<VictimNeedsData>> _victimNeedsFuture;
  final VictimService _victimService = VictimService(
    'http://backend-url',
  ); // Replace

  @override
  void initState() {
    super.initState();
    _victimNeedsFuture = _victimService.fetchVictimNeeds();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VictimNeedsData>>(
      future: _victimNeedsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          final data = snapshot.data!;
          return Column(
            children: [
              const Text(
                'Comparison of Victims and Their Needs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ListTile(
                      title: Text(item.need),
                      trailing: Text(item.count.toString()),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
