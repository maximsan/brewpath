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
  /// Fraunces at 400 — the display face, every headline step.
  display('Fraunces', FontWeight.w400),

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

  const AppFace(this.family, this.weight);

  /// The `fonts:` family name from `pubspec.yaml`, or null to inherit.
  final String? family;

  /// The weight the design pairs with this face, or null to inherit.
  final FontWeight? weight;
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
  final double tracking;

  double get letterSpacing => tracking * size;
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
/// Size and face are separate axes; see [AppFace]. Each step defaults to the
/// face the design most often sets it in, and any step accepts any face.
///
/// Colour resolves in this order: an explicit `color`, then the step's role
/// colour from `mood`, then nothing — in which case the surrounding
/// `DefaultTextStyle` supplies it. Pass `mood` from `context.mood` at the call
/// site; a painter with no context can pass `color` instead.
abstract final class AppText {
  /// Celebration numerals — a streak count, a score. Mono by default, because
  /// the design sets every figure in tabular mono.
  static TextStyle hero({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.hero, face ?? AppFace.mono, mood?.ink, color);

  /// Screen title.
  static TextStyle display({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.display, face ?? AppFace.display, mood?.ink, color);

  /// Card or section title.
  static TextStyle title({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.title, face ?? AppFace.display, mood?.ink, color);

  /// Card and row heading.
  static TextStyle heading({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.heading, face ?? AppFace.display, mood?.ink, color);

  /// Lead paragraph — the sentence under a title.
  static TextStyle lead({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.lead, face ?? AppFace.ui, mood?.ink, color);

  /// Body copy.
  static TextStyle body({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.body, face ?? AppFace.ui, mood?.ink, color);

  /// Support text under a heading or row — muted by default.
  static TextStyle support({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.support, face ?? AppFace.ui, mood?.inkMute, color);

  /// Labels and smallcaps — muted by default.
  static TextStyle label({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.label, face ?? AppFace.control, mood?.inkMute, color);

  /// The smallest step: kickers and captions — muted by default.
  static TextStyle micro({MoodColors? mood, Color? color, AppFace? face}) =>
      _style(_Rung.micro, face ?? AppFace.mono, mood?.inkMute, color);

  /// Italic Fraunces at the [heading] step, for the loading caption. Italic is
  /// a face treatment rather than a rung, so it does not add a step.
  static TextStyle headingItalic({MoodColors? mood, Color? color}) => _style(
    _Rung.heading,
    AppFace.display,
    mood?.ink,
    color,
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
  /// What this cannot fix is a call site reading the wrong slot: a few read
  /// `labelMedium` for sentence-case text ("Step 3 of 8"), which now carries
  /// the smallcaps tracking the label rung owes its uppercase siblings. Those
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

  static TextStyle _style(
    _Rung rung,
    AppFace face,
    Color? roleColour,
    Color? override, {
    bool italic = false,
  }) => TextStyle(
    fontFamily: face.family,
    fontWeight: face.weight,
    fontSize: rung.size,
    height: rung.height,
    letterSpacing: rung.letterSpacing,
    fontStyle: italic ? FontStyle.italic : null,
    color: override ?? roleColour,
  );
}
