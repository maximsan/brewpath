import 'package:brew_path/services/links/link_opener.dart';
import 'package:url_launcher/url_launcher.dart';

/// The shipping opener: hands the address to the platform.
class SystemLinkOpener implements LinkOpener {
  /// Creates a [SystemLinkOpener].
  const SystemLinkOpener();

  @override
  Future<bool> open(Uri target) async {
    // `canLaunchUrl` is not asked first: on iOS it answers for a *scheme*, so
    // it reports true for `mailto:` on a device with no mail account and the
    // launch fails anyway. The launch's own answer is the only true one.
    try {
      return await launchUrl(target, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
