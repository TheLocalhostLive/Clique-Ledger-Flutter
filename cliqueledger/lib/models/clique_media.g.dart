// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clique_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CliqueMediaResponse _$CliqueMediaResponseFromJson(Map<String, dynamic> json) =>
    CliqueMediaResponse(
      mediaId: json['media_id'] as String,
      cliqueId: json['clique_id'] as String,
      fileUrl: json['file_url'] as String,
      createdAt: json['created_at'] as String,
      mediaType: json['media_type'] as String,
      senderId: json['sender_id'] as String,
    );

Map<String, dynamic> _$CliqueMediaResponseToJson(
        CliqueMediaResponse instance) =>
    <String, dynamic>{
      'media_id': instance.mediaId,
      'clique_id': instance.cliqueId,
      'file_url': instance.fileUrl,
      'created_at': instance.createdAt,
      'media_type': instance.mediaType,
      'sender_id': instance.senderId,
    };
