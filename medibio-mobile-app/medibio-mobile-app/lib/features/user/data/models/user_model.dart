class UserModel {
  
  final String id;
  final String token;
  final String name;
  final String realname;
  final String speciality;
  final String profil;

  UserModel({
    required this.id,
    required this.token,
    required this.name,
    required this.realname,
    required this.speciality,
    required this.profil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      realname: json['realname'] ?? '',
      speciality: json['speciality'] ?? '',
      profil: json['profil'] ?? '',
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'token': token,
      'name': name,
      'realname':realname,
      'speciality': speciality,
      'profil': profil,
      
    };
  }
}
