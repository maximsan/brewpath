import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A typeface, with the weight the design pairs it with.
///
/// A **separate axis from size**: the design sets one step in more than one
/// face — `--t-label` drives both `.smallcaps` (Plex Sans 500) and
/// `.smallcaps-mono`, and `--t-lead` is Fraunces on a collectible card and
/// Plex Sans elsewhere. A face baked into each step could express neither.
enum AppFace {
  /// Fraunces at 400 — the display face, every headline step. The one face
  /// that carries an optical size; see [isOpticallySized].
  display('Fraunces', FontWeight.w400, isOpticallySized: true),

  /// IBM Plex Sans at 400 — body copy.
  ui('IBM Plex Sans', FontWeight.w400),

  /// IBM Plex Sans at 500 — controls. The design's own split is "Plex Sans 400
  /// body / 500 controls", so the weight belongs to the face rather than being
  /// a number a call site passes.
  control('IBM Plex Sans', FontWeight.w500),

  /// IBM Plex Mono at 500 — numerals, labels, smallcaps.
  mono('IBM Plex Mono', FontWeight.w500),

  /// No face of its own: the style inherits the surrounding typeface.
  ///
  /// For a slot that sits inline inside display type — the fill-in-the-blank
  /// slot inside a Fraunces sentence — asserting a face would break the
  /// sentence. Leaving `fontFamily` unset lets the ambient `DefaultTextStyle`
  /// supply it.
  inherit(null, null);

  const AppFace(this.family, this.weight, {this.isOpticallySized = false});

  /// The `fonts:` family name from `pubspec.yaml`, or null to inherit.
  final String? family;

  /// The weight the design pairs with this face, or null to inherit.
  final FontWeight? weight;

  /// Whether the bundled file carries an `opsz` axis to set.
  ///
  /// Only Fraunces does. The Plex faces ship as static cuts, and handing a
  /// static font a variation it cannot answer puts noise on every span it
  /// sets, so [AppText] asks only where there is something to ask.
  final bool isOpticallySized;
}

/// How wide the letters are set, in `em` — a **separate axis from size**, for
/// the reason [AppFace] is: the design letters one rung at more than one width.
///
/// Naming none is itself the rule, and leaves a rung at its own tracking. Which
/// width goes here, which belongs in `OffTokens`, and where the design sets
/// each: `docs/design/03-design-system.md`, Typography → Tracking.
enum AppTracking {
  /// 0.02em — barely loosened, for a line meant to be **read as words** rather
  /// than scanned as a label: `.btn`, and the mono respelling that sits inline
  /// beside a dictionary term.
  reading(0.02),

  /// 0.04em — mono given just enough air that a spelled-out run stays legible
  /// without becoming a kicker: a score read as digits, a terse spec chip
  /// (`.spec-chip`), and the pronunciation chip's respelling.
  figure(0.04),

  /// 0.06em — a count standing on its own as the subject of its line: the
  /// points a run paid, Profile's lessons-and-points line, `N / N DONE`.
  count(0.06),

  /// 0.08em — a meta line or a figure, which wants to read as one run rather
  /// than as a kicker. At the rung's 0.14em a count's numerals drift apart and
  /// the line stops reading as a single quantity, which is the whole reason the
  /// design tracks these tighter than the smallcaps beside them:
  /// `.lesson-row .meta`, `.challenge-pill`, `.bag-opt-s`.
  meta(0.08),

  /// 0.10em — a word set as a pill naming a state: the tastefix card's symptom
  /// chips and the Balanced state that replaces them, and `.cheer-points`.
  tag(0.10),

  /// 0.12em — the sequence card's out-of-place hint, `.seq-hint`, and the meta
  /// line and count on the practice shelf, which the design letters at 0.12em
  /// too.
  hint(0.12),

  /// 0.16em — a mono micro line marking what a thing *is*, or where it sits in
  /// a set, rather than heading the content under it. Wider than the smallcaps
  /// rule so a two-word label reads as discrete: the dictionary's status chip
  /// and the collectible tile's sub-line (`.collect-card .cc-sub`, still
  /// unbuilt — #434).
  marker(0.16),

  /// 0.18em — the app's own chrome, lettered a step wider than the pages it
  /// frames. The design sets `letter-spacing: 0.18em` on the two things that
  /// frame every screen: the tab bar's label, and the eyebrow in the sticky
  /// header's compact title. It was the tab bar's registered exception until
  /// the header's compact title turned out to be set at it too.
  chrome(0.18);

  const AppTracking(this.em);

  /// The tracking in `em`, as the design writes it. Resolved against a rung's
  /// size on the way out, because Flutter wants logical pixels.
  final double em;
}

/// One rung of the ladder: a size, and how text is set at that size.
///
/// Private on purpose — this is the only place a font size exists, so going
/// off-ladder means editing this table, which is a visible act rather than a
/// quiet one at a call site.
enum _Rung {
  hero(56, height: 0.95, tracking: -0.02),
  display(30, height: 1.05, tracking: -0.02),
  title(26, height: 1.1, tracking: -0.01),
  subtitle(22, height: 1.15, tracking: -0.01),
  heading(19, height: 1.14, tracking: -0.01),
  lead(17, height: 1.15),
  body(15, height: 1.5),
  support(13, height: 1.4),
  label(11, height: 1.2, tracking: 0.14),
  micro(9.5, height: 1.2, tracking: 0.14);

  const _Rung(this.size, {required this.height, this.tracking = 0});

  final double size;
  final double height;

  /// Letter spacing in `em`, as the design writes it. Flutter wants logical
  /// pixels, so it is multiplied by [size] on the way out.
  ///
  /// The 0.14em the two smallcaps steps carry is the design's own smallcaps
  /// rule — `.smallcaps`, `.smallcaps-mono` and `.challenge-kicker` all set
  /// it. A call site letters differently only by naming an [AppTracking].
  final double tracking;

  /// This rung's letter spacing in logical pixels, lettered at [named] if the
  /// call site asked for a tracking and at the rung's own otherwise.
  double letterSpacingFor(AppTracking? named) => (named?.em ?? tracking) * size;

  /// The bounds of Fraunces' `opsz` axis.
  static const double _minOpticalSize = 9;
  static const double _maxOpticalSize = 144;

  /// The optical size this rung asks Fraunces to be drawn at.
  ///
  /// Its own size, which is what `font-optical-sizing: auto` means. Derived
  /// rather than tabled, so a rung cannot carry a size and an optical size that
  /// disagree; clamped because a rung outside the axis would ask the font for a
  /// coordinate it cannot answer.
  double get opticalSize => size.clamp(_minOpticalSize, _maxOpticalSize);
}

/// The ten-step type ladder — `hero · display · title · subtitle · heading ·
/// lead · body · support · label · micro`.
///
/// **There is no `fontSize` parameter**: going off-ladder means editing the
/// private rung table, which is visible in a diff. The steps, the three axes
/// and how colour resolves: `docs/02-architecture.md`, The type ladder.
abstract final class AppText {
  /// Celebration numerals — a streak count, a score. Mono by default, because
  /// the design sets every figure in tabular mono.
  static TextStyle hero({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.hero, face ?? AppFace.mono, color ?? mood?.ink);

  /// Screen title.
  static TextStyle display({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.display, face ?? AppFace.display, color ?? mood?.ink);

  /// Card or section title.
  static TextStyle title({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.title, face ?? AppFace.display, color ?? mood?.ink);

  /// A title one step below a lesson's — the design gives it to the Coffee
  /// Challenge card, because the challenge is optional. Set at line-height
  /// 1.15 and -0.01em, as the design's `h2` for that card is.
  static TextStyle subtitle({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.subtitle, face ?? AppFace.display, color ?? mood?.ink);

  /// Card and row heading.
  static TextStyle heading({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.heading, face ?? AppFace.display, color ?? mood?.ink);

  /// Lead paragraph — the sentence under a title.
  static TextStyle lead({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.lead, face ?? AppFace.ui, color ?? mood?.ink);

  /// Body copy. Takes a [tracking] because the design letters this rung on
  /// its mono cut — the lesson ending's score is read as digits, not words.
  static TextStyle body({
    MoodColors? mood,
    Color? color,
    AppFace? face,
    AppTracking? tracking,
  }) => _style(
    _Rung.body,
    face ?? AppFace.ui,
    color ?? mood?.ink,
    tracking: tracking,
  );

  /// Support text under a heading or row — muted by default. Takes a
  /// [tracking] for the same reason [body] does: the points a run paid are
  /// set on this rung, and the design letters them.
  static TextStyle support({
    MoodColors? mood,
    Color? color,
    AppFace? face,
    AppTracking? tracking,
  }) => _style(
    _Rung.support,
    face ?? AppFace.ui,
    color ?? mood?.inkMute,
    tracking: tracking,
  );

  /// Labels and smallcaps — muted by default, lettered at the design's 0.14em
  /// smallcaps rule unless the component is one the design tracks differently
  /// (see [AppTracking]).
  static TextStyle label({
    MoodColors? mood,
    Color? color,
    AppFace? face,
    AppTracking? tracking,
  }) => _style(
    _Rung.label,
    face ?? AppFace.control,
    color ?? mood?.inkMute,
    tracking: tracking,
  );

  /// The smallest step: kickers and captions — muted by default, and tracked
  /// like [label].
  static TextStyle micro({
    MoodColors? mood,
    Color? color,
    AppFace? face,
    AppTracking? tracking,
  }) => _style(
    _Rung.micro,
    face ?? AppFace.mono,
    color ?? mood?.inkMute,
    tracking: tracking,
  );

  /// Italic Fraunces at the [heading] step, for the loading caption. Italic is
  /// a face treatment rather than a rung, so it does not add a step.
  static TextStyle headingItalic({MoodColors? mood, Color? color}) => _style(
    _Rung.heading,
    AppFace.display,
    color ?? mood?.ink,
    italic: true,
  );

  /// Material's own text slots, resolved onto the ladder so stock widgets and
  /// the call sites still reading `Theme.of(context).textTheme` are set in the
  /// app's type rather than Roboto.
  ///
  /// **All fifteen, none left out** — a null slot keeps Roboto. Which rung each
  /// takes: `docs/02-architecture.md`, Material's slots.
  static TextTheme textTheme(MoodColors mood) => TextTheme(
    displayLarge: display(mood: mood),
    displayMedium: display(mood: mood),
    displaySmall: display(mood: mood),
    headlineLarge: display(mood: mood),
    headlineMedium: title(mood: mood),
    headlineSmall: title(mood: mood),
    titleLarge: heading(mood: mood),
    titleMedium: body(mood: mood, face: AppFace.control),
    titleSmall: support(color: mood.ink, face: AppFace.control),
    bodyLarge: body(mood: mood),
    bodyMedium: support(mood: mood),
    bodySmall: support(mood: mood),
    labelLarge: support(mood: mood, face: AppFace.control),
    labelMedium: label(mood: mood),
    labelSmall: label(mood: mood, face: AppFace.mono),
  );

  /// [colour] arrives resolved. Each rung names its own role colour either
  /// way — they differ, `ink` against `inkMute` — so folding the `??` into
  /// that one line costs no repetition and spares every rung a second
  /// parameter to thread through.
  static TextStyle _style(
    _Rung rung,
    AppFace face,
    Color? colour, {
    bool italic = false,
    AppTracking? tracking,
  }) => TextStyle(
    fontFamily: face.family,
    fontWeight: face.weight,
    fontSize: rung.size,
    height: rung.height,
    letterSpacing: rung.letterSpacingFor(tracking),
    fontStyle: italic ? FontStyle.italic : null,
    // The design's `font-optical-sizing: auto`, which only Fraunces can
    // answer. A step's optical size is its own size, so the axis cannot drift
    // from the ladder it is drawn at.
    fontVariations: face.isOpticallySized
        ? [FontVariation('opsz', rung.opticalSize)]
        : null,
    color: colour,
  );
}
