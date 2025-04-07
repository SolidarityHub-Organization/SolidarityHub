import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicPresentation/dashboard/dashboard.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 197, 50, 50),
        body: Center(
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', height: 100, alignment: Alignment.center,
              ),
              Text(
                "Solidarity Hub",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 100,),
              Text(
                "Log in Admin",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20,),
              Text(
                "Bienvenido a Solidarity Hub",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20,),
              _userTextField(),
              SizedBox(height: 20),
              _passwordTextField(),
              SizedBox(height: 20),
              _loginButton(),
            ]
          )
        ),
      )
    );
      
  }
  Widget _userTextField() {
    return StreamBuilder(
        stream: null,
       builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 200),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              hintText: 'ejemplo@correo.com',
              labelText: 'Correo electronico',
            ),
            onChanged: (value){

            },
          ),
        );
       }
    );
  }

  Widget _passwordTextField() {
    return StreamBuilder(
        stream: null,
       builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 200),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
           keyboardType: TextInputType.emailAddress,
            obscureText: true,
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              hintText: 'Contraseña',
              labelText: 'Contraseña',
            ),
            onChanged: (value){
              
            },
          ),
        );
       }
    );
  }

  Widget _loginButton() {
    return StreamBuilder(
      stream: null,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        return ElevatedButton(
          
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: () {
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
            child: Text('Iniciar Sesion'),
          )
       );
      }
    );
  }
}