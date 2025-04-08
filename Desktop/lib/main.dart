import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicPresentation/admin/log_in_admin.dart';
import 'package:solidarityhub/LogicPresentation/tasks/create_task.dart';
import 'package:solidarityhub/requests.dart';
import 'package:solidarityhub/LogicPresentation/dashboard/dashboard.dart';
import 'package:solidarityhub/populate_database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter API Database Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Requests _requests = Requests();
  String data = '';

  Future<void> _populateDatabase() async {
    final result = await PopulateDatabase.populateAsync();
    setState(() {
      data = result;
    });
  }

  Future<void> _clearDatabase() async {
    final result = await PopulateDatabase.clearDatabase();
    setState(() {
      data = result;
    });
  }

  Future<void> _fetchTest() async {
    final result = await _requests.fetchTest();
    setState(() {
      data = result;
    });
  }

  Future<void> _addUser() async {
    final result = await _requests.addUser();
    setState(() {
      data = result;
    });
  }

  Future<void> _getUsers() async {
    final result = await _requests.getUsers();
    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _populateDatabase,
              child: const Text("Populate database (Inacabado)"),
            ),

            ElevatedButton(
              onPressed: _clearDatabase,
              child: const Text("Clear database (Inacabado)"),
            ),
            
            ElevatedButton(
              onPressed: _fetchTest,
              child: const Text("Get example data"),
            ),

            ElevatedButton(
              onPressed: _addUser,
              child: const Text("Add user to database"),
            ),

            ElevatedButton(
              onPressed: _getUsers,
              child: const Text("Get all the users in the database"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
              child: const Text("Go to Dashboard"),
            ),

            ElevatedButton (
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateTask()),
                );
              },
              child: const Text("Create Task"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginadmin()),
                );
              },
              child: const Text("Log in Admin"),
            ),

            Text(data.isNotEmpty ? data : "Press a button to fetch data"),
          ],
        ),
      ),
    );
  }
}
