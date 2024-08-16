class User{
  final String name;
  final String id;
 

  User({
    required this.name,
    required this.id,

  });

  factory User.fromJson(Map<String,dynamic> json){
    return User(    
      name: json['name'] ,
      id: json['id'] ,
      );
  }

}