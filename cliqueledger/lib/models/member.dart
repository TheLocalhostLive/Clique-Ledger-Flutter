import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

class Member{
   @JsonKey(name: "member_name")
  final String name;
  @JsonKey(name: "member_id")
  final String memberId;

  Member({
    required this.name,
    required this.memberId,
  });
 
  

  factory Member.fromJson(Map<String,dynamic> json){
    return Member(
      name: json["member_name"],
      memberId: json["member_id"],
    
      );
  }
  Map<String,dynamic> toJson(){
    return {
      'member_name':name,
      'member_id':memberId,
     
    };

  }
}