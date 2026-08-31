import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A typeface, with the weight the design pairs it with.
///
/// Face is a **separate axis from size**, because the design uses one step with
/// more than one face: `--t-label` drives both `.smallcaps` (IBM Plex Sans 500)
/// and `.smallcaps-mono` (IBM Plex Mono 500), and `--t-lead` appears in
/// Fraunces on a collectible card and in Plex Sans elsewhere. A ladder that
/// baked one face into each step could not express either.
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

/// How wide the letters are set, in `em` — the design's tracking vocabulary
/// for the two smallcaps rungs.
///
/// Tracking is a **separate axis from size**, for the same reason [AppFace] is:
/// the design letters one rung at more than one width. `.lesson-row .meta` and
/// `.challenge-kicker` are both uppercase label-family lines, and the design
/// sets them 0.06em apart. A ladder that baked one tracking into each step
/// could only ever letter them the same, which is how sixteen call sites came
/// to name their own spacing — fifteen in logical pixels, and the Cards count
/// through an `OffToken` (#410).
///
/// **Only values something in `lib/` actually renders are here.** The design's
/// app vocabulary at these two rungs runs one wider: 0.1em (`.cheer-points`,
/// `index.html:1092`) is an app component too, not page chrome. It is absent
/// because the app has no points burst and is not getting one — #212 deleted
/// the pose rather than renumber it, and ruled that a points-earned moment,
/// if ever wanted, is authored against a screen with room for it. A value
/// with no call site would be vocabulary nobody speaks.
///
/// The two app values wide enough to restyle a whole rung — the tab bar's
/// 0.18em and the tap cue's 0.24em — stay in `OffTokens` instead, where an
/// exception carries its reason.
///
/// Omitting this axis leaves a rung at its own tracking, which for [AppText]'s
/// label and micro steps is the design's 0.14em smallcaps rule — `.smallcaps`
/// (`index.html:229`) and `.challenge-kicker` (`:502`). **A component the
/// design does not letter specially takes that rule**, which is why most
/// kickers pass no tracking at all: the app's own eyebrows (`KEEP SHARP`, a
/// lesson card's label) have no counterpart in `prototype/` to letter them
/// differently, so they letter like every other kicker rather than at a
/// hand-rounded value that only ever came from the eye.
enum AppTracking {
  /// 0.02em — barely loosened, for a line meant to be **read as words** rather
  /// than scanned as a label: `.btn` (`index.html:255`), and the mono
  /// respelling that sits inline beside a dictionary term
  /// (`dictionary.jsx:235`).
  reading(0.02),

  /// 0.04em — mono given just enough air that a spelled-out run stays legible
  /// without becoming a kicker: a score read as digits (`rewards.jsx:60`), a
  /// terse spec chip (`.spec-chip`, `Design System.html:215`), and the
  /// pronunciation chip's respelling (`dictionary.jsx:46`).
  figure(0.04),

  /// 0.08em — a meta line or a figure, which wants to read as one run rather
  /// than as a kicker. At the rung's 0.14em a count's numerals drift apart and
  /// the line stops reading as a single quantity, which is the whole reason
  /// the design tracks these tighter than the smallcaps beside them:
  /// `.lesson-row .meta` (`index.html:427`), `.challenge-pill` (`:506`),
  /// `.bag-opt-s` (`:628`).
  meta(0.08),

  /// 0.12em — the sequence card's out-of-place hint, `.seq-hint`
  /// (`index.html:1061`, set on `lesson.jsx:980`).
  hint(0.12),

  /// 0.16em — a mono micro line marking what a thing *is*, or where it sits in
  /// a set, rather than heading the content under it. Wider than the smallcaps
  /// rule so a two-word label reads as discrete: the dictionary's status chip
  /// (`dictionary.jsx:124`) and the collectible tile's sub-line
  /// (`.collect-card .cc-sub`, `index.html:712`, still unbuilt — #434).
  marker(0.16);

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
  /// rule — `.smallcaps` (`index.html:229`), `.smallcaps-mono` (`:241`) and
  /// `.challenge-kicker` (`:502`) all set it. A call site letters differently
  /// only by naming an [AppTracking].
  final double tracking;

  /// This rung's letter spacing in logical pixels, lettered at [named] if the
  /// call site asked for a tracking and at the rung's own otherwise.
  double letterSpacingFor(AppTracking? named) => (named?.em ?? tracking) * size;

  /// The bounds of Fraunces' `opsz` axis.
  static const double _minOpticalSize = 9;
  static const double _maxOpticalSize = 144;

  /// The optical size this rung asks Fraunces to be drawn at.
  ///
  /// Its own size, which is what `font-optical-sizing: auto` means — the
  /// browser hands the axis the size the text is rendered at. Derived rather
  /// than tabled, so a rung cannot be given a size and an optical size that
  /// disagree. Clamped because a rung outside the axis would otherwise ask for
  /// a coordinate the font cannot answer.
  double get opticalSize => size.clamp(_minOpticalSize, _maxOpticalSize);
}

/// The nine-step type ladder — `hero · display · title · heading · lead · body
/// · support · label · micro` at 56 / 30 / 26 / 19 / 17 / 15 / 13 / 11 / 9.5.
///
/// **There is no `fontSize` parameter.** A size that is not a step cannot be
/// asked for: the sizes live in one private table, so going off-ladder means
/// editing the ladder — visible in a diff and in review — rather than passing a
/// number at a call site where nobody will see it. Sizes are transcribed from
/// the `--t-*` block of the design bundle (`prototype/index.html`).
///
/// Size, face and tracking are separate axes; see [AppFace] and [AppTracking].
/// Each step defaults to the face the design most often sets it in, and any
/// step accepts any face. Tracking defaults to the step's own, which the two
/// smallcaps steps set at the design's 0.14em; the label and micro steps take
/// a tracking for the handful of components the design letters differently.
///
/// Colour resolves in this order: an explicit `color`, then the step's role
/// colour from `mood`, then nothing — in which case the surrounding
/// `DefaultTextStyle` supplies it. Pass `mood` from `context.mood` at the call
/// site; a painter with no context can pass `color` instead.
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

  /// Card and row heading.
  static TextStyle heading({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.heading, face ?? AppFace.display, color ?? mood?.ink);

  /// Lead paragraph — the sentence under a title.
  static TextStyle lead({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.lead, face ?? AppFace.ui, color ?? mood?.ink);

  /// Body copy.
  static TextStyle body({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.body, face ?? AppFace.ui, color ?? mood?.ink);

  /// Support text under a heading or row — muted by default.
  static TextStyle support({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.support, face ?? AppFace.ui, color ?? mood?.inkMute);

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

  /// Material's own text slots, resolved onto the ladder so stock widgets — and
  /// the ~70 screen call sites still reading `Theme.of(context).textTheme` —
  /// are set in the app's type rather than Roboto.
  ///
  /// **All fifteen, with none left out.** `ThemeData` merges a supplied
  /// `TextTheme` onto the default typography, so a slot left null does not fall
  /// back to a neighbouring step — it keeps Roboto at Material's own size, off
  /// the ladder and outside the design's three faces. Seven slots did, which is
  /// how a class whose whole point is that going off-ladder must be a visible
  /// act let a large share of the app's text off it invisibly.
  ///
  /// **Role first, then the nearest size.** The role picks which rungs are
  /// eligible — a `label*` slot may only land on a tracked rung ([label],
  /// [micro]), because 0.14em is smallcaps spacing and would set body copy
  /// adrift; a `body*` slot may only land on an untracked one. Within those,
  /// the slot takes the rung nearest the Roboto size it used to resolve to —
  /// 57/45/36 · 32/28/24 · 22/16/14 · 16/14/12 · 14/12/11 — so mapping a slot
  /// does not restyle screens that were never touched. A tie goes downwards:
  /// `bodyLarge` 16 → [body], `bodyMedium` and `labelLarge` 14 → [support],
  /// `headlineMedium` 28 → [title], `labelMedium` 12 → [label].
  ///
  /// Role is why the two 12px slots part company: `bodySmall` takes [support]
  /// (13, untracked) and `labelMedium` takes [label] (11, tracked). Size alone
  /// would have tied them. It is also why the three `display*` slots ignore
  /// the nearest rung altogether — 57 and 45 are nearest [hero], but a screen
  /// title is a role and `hero` is reserved for celebration numerals.
  ///
  /// Two more things the nearest size cannot decide:
  ///
  /// - **Face.** A slot Material sets at weight 500 is a control, so it takes
  ///   [AppFace.control] where its rung defaults to the 400 body face —
  ///   `titleMedium`, `titleSmall`, `labelLarge`. `labelSmall` keeps mono: it
  ///   is the numeral smallcaps.
  /// - **Colour.** [support] and [label] are muted by role, which is right for
  ///   the support line under a heading and wrong for a title. `titleSmall`
  ///   therefore lands on the [support] rung in full-strength ink.
  ///
  /// Fifteen slots over nine rungs means slots Material distinguishes share
  /// one — `bodySmall` and `bodyMedium` both land on [support]. That is the
  /// ladder being shorter than Material's scale, which is the point of it.
  ///
  /// What this cannot fix is a call site reading the wrong slot: three read
  /// `labelMedium` for sentence-case text ("3 of 5 saved") and so inherit the
  /// smallcaps tracking the label rung owes its uppercase siblings. Those
  /// belong to the per-screen work, not here.
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
