import 'dart:convert';

import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/grove_light.dart';
import 'package:brew_path/shared/models/content/grove_variety.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
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
  List<MiniGameFormat>? _miniGames;
  Map<String, List<ContentCard>>? _miniGameRounds;
  List<GroveVariety>? _groveVarieties;
  List<GroveLight>? _groveLights;

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

  /// Loads and caches the mini-game catalog, in the order the bank lists it.
  Future<List<MiniGameFormat>> getMiniGameFormats() async {
    _miniGames ??= await _loadBank(
      'assets/content/generated/mini_games.json',
      MiniGameFormat.fromJson,
    );
    return _miniGames!;
  }

  /// Loads and caches the grove's species, in the order the chooser lists them.
  Future<List<GroveVariety>> getGroveVarieties() async {
    _groveVarieties ??= await _loadBank(
      'assets/content/generated/grove_varieties.json',
      GroveVariety.fromJson,
    );
    return _groveVarieties!;
  }

  /// Loads and caches the grove's lights, in picker order.
  Future<List<GroveLight>> getGroveLights() async {
    _groveLights ??= await _loadBank(
      'assets/content/generated/grove_lights.json',
      GroveLight.fromJson,
    );
    return _groveLights!;
  }

  /// The rounds authored for [formatId], or empty when the bank has none.
  ///
  /// The extractor refuses to write a format with no rounds, so an empty list
  /// here means the id itself is unknown rather than the game being empty.
  Future<List<ContentCard>> getMiniGameRounds(String formatId) async {
    _miniGameRounds ??= await _loadRounds();
    return _miniGameRounds![formatId] ?? const [];
  }

  Future<Map<String, List<ContentCard>>> _loadRounds() async {
    final raw = await rootBundle.loadString(
      'assets/content/generated/mini_game_content.json',
    );
    final items =
        (jsonDecode(raw) as Map<String, dynamic>)['items'] as List<dynamic>;
    return {
      for (final item in items.cast<Map<String, dynamic>>())
        item['id'] as String: [
          for (final round in (item['rounds'] as List<dynamic>))
            ContentCard.fromJson(round as Map<String, dynamic>),
        ],
    };
  }

  /// Returns the lesson with [id], or null if none exists.
  Future<LessonModel?> getLessonById(String id) async {
    final lessons = await getLessons();
    return lessons.where((l) => l.id == id).firstOrNull;
  }

  /// Reads a generated bank, whose items sit inside the extractor's envelope
  /// rather than at the top level the hand-written assets use.
  Future<List<T>> _loadBank<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final items =
        (jsonDecode(raw) as Map<String, dynamic>)['items'] as List<dynamic>;
    return [
      for (final item in items.cast<Map<String, dynamic>>()) fromJson(item),
    ];
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
