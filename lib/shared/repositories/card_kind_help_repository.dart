import 'package:brew_path/shared/models/content/card_kind_help.dart';
import 'package:brew_path/shared/repositories/bank_loader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_kind_help_repository.g.dart';

/// The ten how-to-play entries, loaded off the bundled bank and cached.
///
/// Its own repository rather than another method on `ContentRepository`, which
/// sits at the method budget the metrics gate enforces — the same reason the
/// dictionary and the visual guides have one.
class CardKindHelpRepository {
  Map<String, CardKindHelp>? _byKind;

  /// Every entry, keyed by the card kind it explains.
  Future<Map<String, CardKindHelp>> getByKind() async {
    _byKind ??= {
      for (final help in await loadBank(
        'assets/content/generated/card_kind_help.json',
        CardKindHelp.fromJson,
      ))
        help.kind: help,
    };
    return _byKind!;
  }

  /// How [kind] is played, or null when the bank carries no entry for it.
  Future<CardKindHelp?> getForKind(String kind) async =>
      (await getByKind())[kind];
}

/// The app-wide [CardKindHelpRepository].
@riverpod
CardKindHelpRepository cardKindHelpRepository(Ref ref) =>
    CardKindHelpRepository();
