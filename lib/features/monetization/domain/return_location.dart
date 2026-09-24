/// The query parameter naming where a selling route returns to — the welcome's
/// *Back to learning*, and the paywall a lock handed off to, which passes it
/// on to the welcome.
///
/// Carried on the URL rather than in `extra`, because both are top-level
/// routes go_router rebuilds from the location alone.
const String returnParam = 'from';

/// The query returning to [location] once the selling route is left — empty
/// when there is no location to return to.
Map<String, String> returnQuery(String? location) =>
    location == null ? const {} : {returnParam: location};

/// The location the selling route at [route] returns to, or null when it
/// names none.
///
/// Only an in-app location is taken — a hand-written link naming anywhere else
/// returns to Learn, like a route that named nothing.
String? returnLocationIn(Uri route) {
  final from = route.queryParameters[returnParam];
  // `//host` is a URL without its scheme, not a path.
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  return from;
}
