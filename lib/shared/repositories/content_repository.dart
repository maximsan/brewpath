import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/models/content/collectible.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/grove_light.dart';
import 'package:brew_path/shared/models/content/grove_variety.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/bank_loader.dart';
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_repository.g.dart';

/// Loads Foundations — modules, lessons and collectibles — from the generated
/// banks the extractor writes out of the design.
///
/// Two joins live here and nowhere else: a lesson's owning **module**, and the
/// **card** a lesson awards. Both are reverse lookups the banks do not store
/// directly, and both would otherwise be open-coded at every call site with a
/// slightly different answer.
class ContentRepository {
  List<ModuleModel>? _modules;
  List<LessonModel>? _lessons;
  List<CoffeeCardModel>? _cards;
  List<MiniGameFormat>? _miniGames;
  Map<String, List<ContentCard>>? _miniGameRounds;
  List<GroveVariety>? _groveVarieties;
  List<GroveLight>? _groveLights;
  List<BrewChallenge>? _challenges;

  /// Loads and caches the five modules, in course order.
  Future<List<ModuleModel>> getModules() async {
    _modules ??= await loadBank(
      'assets/content/generated/modules.json',
      ModuleModel.fromJson,
    );
    return _modules!;
  }

  /// Loads and caches all thirty-two lessons, in course order, each carrying
  /// the id of the module that claims it.
  Future<List<LessonModel>> getLessons() async {
    _lessons ??= assembleLessons(
      await loadBankRecords('assets/content/generated/lessons.json'),
      await getModules(),
    );
    return _lessons!;
  }

  /// Loads and caches every collectible, joined to the words of the lesson or
  /// module that awards it.
  Future<List<CoffeeCardModel>> getCards() async {
    _cards ??= assembleCards(
      collectibles: await loadBank(
        'assets/content/generated/collectibles.json',
        Collectible.fromJson,
      ),
      lessons: await getLessons(),
      modules: await getModules(),
    );
    return _cards!;
  }

  /// The card [lessonId] awards, or null when no collectible names it.
  ///
  /// The collectibles bank points at its source rather than the other way
  /// round, so this walks the pointer back. Built once here because the
  /// alternative is every caller re-deriving it — the mistake the ticket that
  /// asked for it names explicitly.
  Future<CoffeeCardModel?> getCardForLesson(String lessonId) async {
    final cards = await getCards();
    return cards.where((card) => card.lessonId == lessonId).firstOrNull;
  }

  /// Loads and caches the twelve Coffee Challenges, in bank order.
  Future<List<BrewChallenge>> getBrewChallenges() async {
    _challenges ??= await loadBank(
      'assets/content/generated/brew_challenges.json',
      BrewChallenge.fromJson,
    );
    return _challenges!;
  }

  /// Loads and caches the mini-game catalog, in the order the bank lists it.
  Future<List<MiniGameFormat>> getMiniGameFormats() async {
    _miniGames ??= await loadBank(
      'assets/content/generated/mini_games.json',
      MiniGameFormat.fromJson,
    );
    return _miniGames!;
  }

  /// Loads and caches the grove's species, in the order the chooser lists them.
  Future<List<GroveVariety>> getGroveVarieties() async {
    _groveVarieties ??= await loadBank(
      'assets/content/generated/grove_varieties.json',
      GroveVariety.fromJson,
    );
    return _groveVarieties!;
  }

  /// Loads and caches the grove's lights, in picker order.
  Future<List<GroveLight>> getGroveLights() async {
    _groveLights ??= await loadBank(
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
    final items = await loadBankRecords(
      'assets/content/generated/mini_game_content.json',
    );
    return {
      for (final item in items)
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
}

/// Provides the singleton [ContentRepository].
@riverpod
ContentRepository contentRepository(Ref ref) => ContentRepository();
