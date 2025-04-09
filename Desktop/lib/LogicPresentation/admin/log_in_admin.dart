import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicPresentation/dashboard/dashboard.dart';
import 'package:http/http.dart' as http;

class Loginadmin extends StatefulWidget {
  const Loginadmin({super.key});

  @override
  State<Loginadmin> createState() => _LoginadminState();
}

class _LoginadminState extends State<Loginadmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF44336),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  alignment: Alignment.center,
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
                SizedBox(height: 100),

                Container(
                  height: 400,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Log in Admin",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF44336),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Bienvenido a Solidarity Hub",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        _userTextField(),
                        SizedBox(height: 20),
                        _passwordTextField(),
                        SizedBox(height: 40),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Color(0xFFF44336),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        SizedBox(height: 20),
                        _loginButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userTextField() {
    return StreamBuilder(
      stream: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              hintText: 'ejemplo@correo.com',
              labelText: 'Correo electronico',
            ),
            onChanged: (value) {},
          ),
        );
      },
    );
  }

  Widget _passwordTextField() {
    return StreamBuilder(
      stream: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: _passwordController,
            keyboardType: TextInputType.emailAddress,
            obscureText: true,
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              hintText: 'Contraseña',
              labelText: 'Contraseña',
            ),
            onChanged: (value) {},
          ),
        );
      },
    );
  }

  Widget _loginButton() {
    return StreamBuilder(
      stream: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 197, 50, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed:
              !_isFormValid
                  ? null
                  : () async {
                    try {
                      final response = await http.get(
                        Uri.parse(
                          'http://localhost:5170/api/v1/admins/LogInAdmin/${_emailController.text},${_passwordController.text}',
                        ),
                      );

                      if (response.statusCode == 200) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Dashboard(),
                          ),
                        );
                      } else if (response.statusCode == 401) {
                        setState(() {
                          _errorMessage = 'Credenciales inválidas';
                        });
                      } else {
                        setState(() {
                          _errorMessage = 'Error en el servidor';
                        });
                      }
                    } catch (e) {
                      setState(() {
                        _errorMessage = 'Error de conexión';
                      });
                    }
                  },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
            child: Text(
              'Iniciar Sesion',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
