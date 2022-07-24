import 'package:countdown_timer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
// import 'package:json_serializable/json_serializable.dart';

part 'provider.freezed.dart';
part 'provider.g.dart';

@freezed
class TrainingMenu with _$TrainingMenu {
  const factory TrainingMenu({
    @Default(30) int time,
    @Default('') String trainingName,
    @Default('') String imagePath,
    @Default('') String description
  }) = _TrainingMenu;

  factory TrainingMenu.fromJson(Map<String, dynamic> json) => _$TrainingMenuFromJson(json);
}

@immutable
class TrainingSet {
  final String title;
  final List<TrainingMenu> trainingMenu;

  const TrainingSet({required this.title, required this.trainingMenu});

  TrainingSet copyWith({title, trainingMenu}) {
    return TrainingSet(title: title ?? this.title, trainingMenu: trainingMenu ?? this.trainingMenu);
  }
}

class TrainingMenuNotifierProvider extends StateNotifier<List<TrainingSet>> {
  TrainingMenuNotifierProvider(List<TrainingSet> trainingSet): super(trainingSet);

  void addTrainingSet(TrainingSet trainingSet) {
    state = [...state, trainingSet];
  }

  void removeTrainingSet(TrainingSet trainingSet) {
    state.remove(trainingSet);
    state = [...state];
  }

  bool isExistTrainingSet(String trainingSetName) {
     for (final trainingSet in state) {
       if (trainingSet.title == trainingSetName) {
         return true;
       }
     }
     return false;
  }

  void change() {
    state = [...state];
  }

  TrainingSet  getTrainingSet(String title) {
    for (final trainingSet in state) {
      if (trainingSet.title == title) {
        return trainingSet;
      }
    }
    return state[0];
  }

  TrainingSet getMenu(int index) {
    return state[index];
  }
}

