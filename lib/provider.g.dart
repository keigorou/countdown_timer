// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TrainingMenu _$$_TrainingMenuFromJson(Map<String, dynamic> json) =>
    _$_TrainingMenu(
      time: json['time'] as int? ?? 30,
      trainingName: json['trainingName'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$_TrainingMenuToJson(_$_TrainingMenu instance) =>
    <String, dynamic>{
      'time': instance.time,
      'trainingName': instance.trainingName,
      'imagePath': instance.imagePath,
      'description': instance.description,
    };
