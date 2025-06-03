import 'package:flutter/material.dart';
import 'package:solidarityhub/screens/dashboard/dashboard.dart';
import 'package:http/http.dart' as http;

class Loginadmin extends StatefulWidget {
  final Function? onLoginSuccess;

  const Loginadmin({Key? key, this.onLoginSuccess}) : super(key: key);

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
      _isFormValid = _emailController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _attemptLogin() async {
    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Introduzca un correo electrónico válido';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:5170/api/v1/admins/LogInAdmin/${_emailController.text.trim()},${_passwordController.text}',
        ),
      );

      if (!mounted) return; // make sure widget is still in the tree

      if (response.statusCode == 200) {
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        } else {
          // Solo navegamos directamente si no hay callback de éxito definido
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'El usuario o la contraseña son incorrectos';
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF44336),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Image.asset('assets/images/logo.png', height: 100, alignment: Alignment.center),
                        const Text(
                          "Solidarity Hub",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        const Spacer(),

                        Container(
                          height: 400,
                          width: 500,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  "Log in Admin",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFFF44336), fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Bienvenido a Solidarity Hub",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                _userTextField(),
                                const SizedBox(height: 20),
                                _passwordTextField(),
                                const SizedBox(height: 40),
                                if (_errorMessage.isNotEmpty)
                                  Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      color: Color(0xFFF44336),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 20),
                                _loginButton(),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userTextField() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          icon: Icon(Icons.email),
          hintText: 'ejemplo@correo.com',
          labelText: 'Correo electrónico',
        ),
        onChanged: (value) {},
        onSubmitted: (_) {
          if (_isFormValid) {
            _attemptLogin();
          }
        },
      ),
    );
  }

  Widget _passwordTextField() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _passwordController,
        keyboardType: TextInputType.emailAddress,
        obscureText: true,
        decoration: const InputDecoration(icon: Icon(Icons.lock), hintText: 'Contraseña', labelText: 'Contraseña'),
        onChanged: (value) {},
        onSubmitted: (_) {
          if (_isFormValid) {
            _attemptLogin();
          }
        },
      ),
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF44336),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        disabledBackgroundColor: Colors.grey,
      ),
      onPressed: !_isFormValid ? null : _attemptLogin,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
        child: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
