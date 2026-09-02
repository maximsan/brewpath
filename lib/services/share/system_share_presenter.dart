import 'dart:typed_data';

import 'package:brew_path/services/share/share_presenter.dart';
import 'package:share_plus/share_plus.dart';

/// The shipping presenter: the platform share sheet via `share_plus`
/// (SPM-compatible, verified at source in #26 — no CocoaPods reintroduced).
class SystemSharePresenter implements SharePresenter {
  /// Creates a [SystemSharePresenter].
  const SystemSharePresenter();

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    String? link,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'image/png', name: fileName)],
        // `text`, not `uri`: the package forbids `uri` beside files, and
        // pairs `text` with them.
        text: link,
      ),
    );
  }
}
