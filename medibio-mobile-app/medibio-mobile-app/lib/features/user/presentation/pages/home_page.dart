import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/data/repositories/user_repository_impl.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/login_usecase.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/login/login_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/calendar_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/components/item_tile.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/list_itvs_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/parcs_list_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? savedName;
  String? savedProfil;
  String? savedEmail;
  String? savedRealName;

  
  // ignore: non_constant_identifier_names
  final List Items = const [
    ["Calendrier", "lib/images/cal2.png"],
    ["Liste des Interventions", "lib/images/itv3.png"],
    ["Liste des Parcs", "lib/images/parc2.png"],
    ["Statistiques", "lib/images/stat3.png"],
    ["Contact", "lib/images/chat.png"],
  ];

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
      savedRealName=realname;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
appBar: AppBar(
  backgroundColor: const Color(0xFFF1F1F1),
  elevation: 0.0,
  title: Row(
    children: [
      Expanded(
        child: Align( // Aligner vers la droite
          alignment: const Alignment(-0.04, 0.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: 'SRA',
                  style: TextStyle(fontSize: 32.0, color: Colors.black),
                ),
                TextSpan(
                  text: 'SAV',
                  style: TextStyle(
                    fontSize: 32.0,
                    color: ThemeColors.buildCardBlue,
                  ),
                ),
                TextSpan(
                  text: '■',
                  style: TextStyle(fontSize: 9.0, color: ThemeColors.buildCardBlue),
                ),
              ],
            ),
          ),
        ),
      ),
      const Icon(FontAwesomeIcons.bell),
    ],
  ),
),


        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(savedRealName ?? 'Nom non disponible'),
                accountEmail: Text(savedEmail ?? 'E-mail non disponible'),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('lib/images/technician.png'),
                ),
                decoration: BoxDecoration(color:Colors.blue),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Accueil'),
                onTap: () => Navigator.pop(context),
              ),
                          ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () => 
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => const ProfilPage(),
            ),
          ),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Déconnexion'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => LoginBloc(LoginUseCase(UserRepositoryImpl())),
                        child: const LoginPage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FadeInUp(
                duration: const Duration(milliseconds: 1400),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: <TextSpan>[
                             TextSpan(
                              text: ' ',
                              style: TextStyle(
                                fontSize: 21.0,
                                
                              ),
                            ),
                            TextSpan(
                              text: 'BON',
                              style: TextStyle(
                                fontSize: 21.0,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.buildCardBlue,
                              ),
                            ),
                            TextSpan(
                              text: 'JOUR',
                              style: TextStyle(
                                fontSize: 21.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Partons, résolvons les problèmes \n et rendons nos clients heureux.',
                        style: TextStyle(fontSize: 20 ,
                       
                        ) ,
                        
                       
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),


ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: Items.length,
  itemBuilder: (context, index) {
    final item = Items[index];
    switch (index) {
      case 0:
        return ItemTile(
          itemName: item[0],
          imagePath: item[1],
          onPressed: () {
         Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InterventionCalendarPage(),
                  ),);
          },
        );
      case 1:
        return ItemTile(
          itemName: item[0],
          imagePath: item[1],
          onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListCardPage(),
                  ),
                );
          },
        );
      case 2:
        return ItemTile(
          itemName: item[0],
          imagePath: item[1],
          onPressed: () {
              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const ParcsListPage(),
  ),
);

          },
        );
      case 3:
        return ItemTile(
          itemName: item[0],
          imagePath: item[1],
          onPressed: () {
            print("Statisques Clicked");
          },
        );

        case 4:
        return ItemTile(
          itemName: item[0],
          imagePath: item[1],
          onPressed: () {
            print("CONTACT Clicked");
          },
        );
      default:
        return const SizedBox(); 
    }
  },
)

                    ],
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
