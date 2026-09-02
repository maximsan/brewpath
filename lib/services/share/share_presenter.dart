import 'dart:typed_data';

/// Presents a rendered image through the platform's share UI.
///
/// The one seam in front of `share_plus` (#237): the streak screen hands
/// bytes to this interface, tests hand it a recorder, and no widget ever
/// touches the plugin directly — the no-op payments/ads precedent.
// One member by design: the seam exists to be faked and swapped (#237),
// which a bare function type cannot express as a provider contract.
// ignore: one_member_abstracts
abstract interface class SharePresenter {
  /// Offers [bytes] (a PNG) to the platform share sheet as [fileName],
  /// carrying [link] alongside it when the shared thing has an address.
  ///
  /// The link travels as share *text*: `share_plus` cannot combine its `uri`
  /// field with files, and an image with no address is the thing #34 ruled
  /// against — a card someone is sent with no way to reach the app.
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    String? link,
  });
}

/// A presenter that presents nothing — tests and inactive contexts.
class NoOpSharePresenter implements SharePresenter {
  /// Creates a [NoOpSharePresenter].
  const NoOpSharePresenter();

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    String? link,
  }) async {}
}
