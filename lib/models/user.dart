class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final List<double> faceEmbedding;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.faceEmbedding,
});

  Map<String, dynamic> toMap()
  {
    return {
      'id': id,
      'name':name,
      'email':email,
      'password':password,
      'faceEmbedding': faceEmbedding.join(','),
    };
  }
  factory User.fromMap(Map<String,dynamic> map)
  {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      faceEmbedding: map['faceEmbedding']
        .split(',')
        .map<double>((e)=>double.parse(e))
        .toList(),
    );
  }


}