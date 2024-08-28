class CliquePostSchema {
  final String name;
  final String? fund;


  CliquePostSchema({
    required this.name,
    this.fund,
    
  });

  // Convert a CliquePostSchema instance to a map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'funds': fund,
      
    };
  }

  // Create a CliquePostSchema instance from a map (JSON)
  factory CliquePostSchema.fromJson(Map<String, dynamic> json) {
    return CliquePostSchema(
      name: json['name'] as String,
      fund: json['fund'] as String?,
     
    );
  }
}
