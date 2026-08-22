import 'package:brew_path/services/share/share_presenter.dart';
import 'package:brew_path/services/share/system_share_presenter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_provider.g.dart';

/// Provides the active [SharePresenter] — the platform share sheet.
@riverpod
SharePresenter sharePresenter(Ref ref) => const SystemSharePresenter();
