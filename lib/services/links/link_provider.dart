import 'package:brew_path/services/links/link_opener.dart';
import 'package:brew_path/services/links/system_link_opener.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_provider.g.dart';

/// Provides the active [LinkOpener] — the platform's browser or mail app.
@riverpod
LinkOpener linkOpener(Ref ref) => const SystemLinkOpener();
