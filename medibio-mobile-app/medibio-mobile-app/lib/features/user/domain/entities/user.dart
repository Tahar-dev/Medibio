class UserModel {
  final String name;
  final String email;
  final String password; // Si vous souhaitez inclure le mot de passe
  final String realname;
  final String speciality;
  final String profil;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.realname,
    required this.speciality,
    required this.profil,
  });
}
