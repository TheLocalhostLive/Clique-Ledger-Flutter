
import 'package:json_annotation/json_annotation.dart';

class Member{
   @JsonKey(name: "member_name")
  final String name;
  @JsonKey(name: "member_id")
  final String memberId;

  @JsonKey(name: "user_id")
  final String userId;

  Member({
    required this.name,
    required this.memberId,
    required this.userId
  });
 
  

  factory Member.fromJson(Map<String,dynamic> json){
    return Member(
      name: json["member_name"],
      memberId: json["member_id"],
      userId: json['user_id']
      );
  }
  Map<String,dynamic> toJson(){
    return {
      'member_name':name,
      'member_id':memberId,
      'user_id': userId
    };

  }
}