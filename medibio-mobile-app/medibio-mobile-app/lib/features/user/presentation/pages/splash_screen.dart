import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srasav_vf_v1/features/user/data/repositories/user_repository_impl.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/login_usecase.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/login/login_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/components/square_tile2.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/components/square_tile3.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/loading_screen.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;
  void _startLoading() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _refreshPage() {
    _startLoading();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: _isLoading ? const LoadingScreen() : _buildMainScreen(context),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 50.0,
                          right: 50.0,
                          top: 0.0,
                          bottom: 20,
                        ),
                        child:
                            SquareTile3(imagePath: 'lib/images/medibio22.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 28.0,
                          right: 28.0,
                          top: 0.0,
                          bottom: 20,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.notoSerif(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: const [
                              TextSpan(
                                  text:
                                      'Maximisons l’efficacité et apportons des solutions grâce à notre application'),
                              TextSpan(
                                text: '\nSRASAV\n',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 24, 113, 172),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              TextSpan(
                                  text:
                                      'la référence idéale pour \n nos clients.'),
                            ],
                          ),
                        ),
                      ),
                      const SquareTile2(imagePath: 'lib/images/lampe.png'),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return BlocProvider(
                                create: (context) => LoginBloc(
                                    LoginUseCase(UserRepositoryImpl())),
                                child: const LoginPage(),
                              );
                            },
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 24, 113, 172),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              "Lancer",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: IconButton(
              onPressed: _refreshPage,
              icon: const Icon(
                Icons.refresh,
                color: Color.fromARGB(255, 24, 113, 172),
                size: 32,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}
