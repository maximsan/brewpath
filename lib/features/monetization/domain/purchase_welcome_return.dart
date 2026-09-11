/// The welcome's query parameter naming where *Back to learning* returns to.
///
/// Carried on the URL rather than in `extra`, because the celebration is a
/// top-level route go_router rebuilds from the location alone.
const String welcomeReturnParam = 'from';

/// The welcome's query, returning to [location] once the celebration is left.
Map<String, String> welcomeReturnTo(String location) => {
  welcomeReturnParam: location,
};

/// The location the welcome at [welcome] returns to, or null when it names
/// none.
///
/// Only an in-app location is taken — a hand-written link naming anywhere else
/// returns to Learn, like a welcome that named nothing.
String? welcomeReturnIn(Uri welcome) {
  final from = welcome.queryParameters[welcomeReturnParam];
  // `//host` is a URL without its scheme, not a path.
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  return from;
}
