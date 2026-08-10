import 'dart:convert';

import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_repository.g.dart';

/// Loads content models (modules, lessons, cards) from bundled JSON assets.
class ContentRepository {
  List<ModuleModel>? _modules;
  List<LessonModel>? _lessons;
  List<CoffeeCardModel>? _cards;

  /// Loads and caches all modules from bundled JSON.
  Future<List<ModuleModel>> getModules() async {
    _modules ??= await _load(
      'assets/content/modules.json',
      ModuleModel.fromJson,
    );
    return _modules!;
  }

  /// Loads and caches all lessons from bundled JSON.
  Future<List<LessonModel>> getLessons() async {
    _lessons ??= await _load(
      'assets/content/lessons.json',
      LessonModel.fromJson,
    );
    return _lessons!;
  }

  /// Loads and caches all coffee cards from bundled JSON.
  Future<List<CoffeeCardModel>> getCards() async {
    _cards ??= await _load(
      'assets/content/cards.json',
      CoffeeCardModel.fromJson,
    );
    return _cards!;
  }

  /// Returns the lesson with [id], or null if none exists.
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

/// Provides the singleton [ContentRepository].
@riverpod
ContentRepository contentRepository(Ref ref) => ContentRepository();
