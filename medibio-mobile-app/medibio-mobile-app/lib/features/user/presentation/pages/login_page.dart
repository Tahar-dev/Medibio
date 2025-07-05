import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/home_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/splash_screen.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_event.dart';
import '../blocs/login/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
      
        return false;
      },
      child: Scaffold(
        body: LoginForm(),
      ),
    );
  }
}

// ignore: must_be_immutable
class LoginForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late String email;
  late String password;
  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Connecté avec succès",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: ThemeColors.vertClaire,
              duration: Duration(seconds: 2),
            ),
          );

          final user = state.user;
          email = emailController.text;
          password = passwordController.text;

          final prefs = await SharedPreferences.getInstance();
          
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          await prefs.setString('name', user.name);
          await prefs.setString('profil', user.profil);
          await prefs.setString('realname', user.realname);
          


          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: ThemeColors.burgundy,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'SRA',
                                      style: TextStyle(
                                          fontSize: 28.0, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'SAV',
                                      style: TextStyle(
                                          fontSize: 28.0,
                                          //color: Colors.blue[700]
                                          color: ThemeColors.buildCardBlue,
                                          ),
                                    ),
                                    TextSpan(
                                      text: '■',
                                      style: TextStyle(
                                          fontSize: 9.0,
                                          color: ThemeColors.buildCardBlue),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:
                                      Image.asset('lib/images/medibio22.png'),
                                ),
                              ),
                            //  const SizedBox(height: 20),
                             /* const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 25),
                                  child: Text(
                                    'Se Connecter',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 23,
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),*/
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MyTextField(
                                      controller: emailController,
                                      hintText: 'E-mail',
                                      obscureText: false,
                                    ),
                                    const SizedBox(height: 20),
                                    MyTextField(
                                      controller: passwordController,
                                      hintText: 'Mot de passe',
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 30),
                                    GestureDetector(
                                      onTap: () {
                                        BlocProvider.of<LoginBloc>(context).add(
                                          LoginButtonPressed(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 24, 113, 172),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Se connecter",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
              // Icône de porte bien placée en bas
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.exit_to_app, // Icône de porte
                        color: Color.fromARGB(255, 24, 113, 172),
                        size: 32, // Taille de l'icône
                      ),
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

class SquareTile extends StatelessWidget {
  final String imagePath;
  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 35,
        width: 35,
      ),
    );
  }
}

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    widget.controller.addListener(_removeSpaces);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    widget.controller.removeListener(_removeSpaces);
    super.dispose();
  }

  void _removeSpaces() {
    // Update the text without spaces
    String newText = widget.controller.text.replaceAll(' ', '');
    if (widget.controller.text != newText) {
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          fillColor: Colors.grey.shade50,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
