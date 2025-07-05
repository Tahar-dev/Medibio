// user_details_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/home_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? savedName;
  String? savedProfil;
  String? savedEmail;
  String? savedRealName;

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final profil = prefs.getString('profil');
    final email = prefs.getString('email');
    final realname = prefs.getString('realname');

    setState(() {
      savedName = name;
      savedProfil = profil;
      savedEmail = email;
      savedRealName = realname;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text('Profil',
                  style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),),
          backgroundColor: ThemeColors.buildCardBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('lib/images/mehrezAVATAR.png'),
              ),
              const SizedBox(height: 20),
              if (savedRealName != null && savedEmail != null) ...[
                itemProfile('Nom et Prénom', savedRealName!, CupertinoIcons.person),
                const SizedBox(height: 10),
                itemProfile('E-mail', savedEmail!, CupertinoIcons.mail),
              ] else
                const Text('Données utilisateur non disponibles'),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.blue.withOpacity(.4),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(iconData, size: 30, color: ThemeColors.buildCardBlue,),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
