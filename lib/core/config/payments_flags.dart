/// What decides whether this build can take money.
library;

/// The RevenueCat public SDK key, passed at build time.
///
/// `--dart-define=REVENUECAT_KEY=appl_…`, catalogued in the README's run-time
/// flags table. Empty is the default, so a build that was not given a key
/// cannot reach a store at all.
const String kRevenueCatKey = String.fromEnvironment('REVENUECAT_KEY');

/// Whether this build talks to RevenueCat.
///
/// Compiled in rather than switched on at run time: with no key the app is
/// free by construction, which is what ships until the store is live (#421).
const bool kUseRevenueCat = kRevenueCatKey != '';
