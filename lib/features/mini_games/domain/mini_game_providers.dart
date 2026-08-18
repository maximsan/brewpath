import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/models/content/mini_game_format.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mini_game_providers.g.dart';

/// The mini-game catalog, in the order the extracted bank lists it.
@riverpod
Future<List<MiniGameFormat>> miniGameFormats(Ref ref) =>
    ref.watch(contentRepositoryProvider).getMiniGameFormats();

/// One format by id, or null when the catalog has no such entry.
@riverpod
Future<MiniGameFormat?> miniGameFormat(Ref ref, String formatId) async {
  final formats = await ref.watch(miniGameFormatsProvider.future);
  return formats.where((format) => format.id == formatId).firstOrNull;
}

/// The rounds authored for one format.
@riverpod
Future<List<ContentCard>> miniGameRounds(Ref ref, String formatId) =>
    ref.watch(contentRepositoryProvider).getMiniGameRounds(formatId);
