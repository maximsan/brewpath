import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:coffee_quest/shared/models/coffee_card_model.dart';
import 'package:coffee_quest/shared/models/lesson_model.dart';
import 'package:coffee_quest/shared/models/module_model.dart';

part 'content_repository.g.dart';

class ContentRepository {
  List<ModuleModel>? _modules;
  List<LessonModel>? _lessons;
  List<CoffeeCardModel>? _cards;

  Future<List<ModuleModel>> getModules() async {
    _modules ??= await _load('assets/content/modules.json', ModuleModel.fromJson);
    return _modules!;
  }

  Future<List<LessonModel>> getLessons() async {
    _lessons ??= await _load('assets/content/lessons.json', LessonModel.fromJson);
    return _lessons!;
  }

  Future<List<CoffeeCardModel>> getCards() async {
    _cards ??= await _load('assets/content/cards.json', CoffeeCardModel.fromJson);
    return _cards!;
  }

  Future<LessonModel?> getLessonById(String id) async {
    final lessons = await getLessons();
    return lessons.where((l) => l.id == id).firstOrNull;
  }

  Future<List<T>> _load<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}

@riverpod
ContentRepository contentRepository(Ref ref) =>
    ContentRepository();
