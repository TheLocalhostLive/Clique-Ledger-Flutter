import 'package:json_annotation/json_annotation.dart';
part 'clique_media.g.dart';

@JsonSerializable()
class CliqueMediaResponse {
  CliqueMediaResponse({
    required this.mediaId,
    required this.cliqueId,
    required this.fileUrl,
    required this.createdAt,
    required this.mediaType,
    required this.senderId,
  });

  @JsonKey(name: 'media_id')
  final String mediaId;
  @JsonKey(name: 'clique_id')
  final String cliqueId;
  @JsonKey(name: 'file_url')
  final String fileUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'sender_id')
  final String senderId;
  

  factory CliqueMediaResponse.fromJson(Map<String, dynamic> json) =>
      _$CliqueMediaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CliqueMediaResponseToJson(this);

  @override
  String toString() {
    return {
      'media_id': mediaId,
      'clique_id': cliqueId,
      'file_url': fileUrl,
      'created_at': createdAt,
      'media_type': mediaType,
      'sender_id': senderId,
    }.toString();
  }
}

