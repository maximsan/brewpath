import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/app_text_field.dart';
import 'package:brew_path/core/widgets/ghost_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/onboarding/presentation/intro_page.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_controller.dart';
import 'package:brew_path/features/onboarding/presentation/name/name_copy.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Room above the mascot — the design's `paddingTop: 40`, as on the beat
/// before it.
const double _mascotInset = 40;

/// How large the mascot is drawn here — the design's `size={148}`, smaller
/// than the 184 of his introduction one screen earlier.
const double _mascotSize = 148;

/// The design's `marginTop: 18` under the question and `marginBottom: 24`
/// above the field.
const double _supportTop = 18;
const double _supportBottom = 24;

/// `marginTop: 16` on Continue, and `marginTop: 10` on the skip beneath it.
const double _actionGap = 16;
const double _skipGap = 10;

/// Screen 01c of the intro: what the learner would like to be called.
///
/// The last step and the only question v1 asks, since ADR-0010 moved the goal
/// and brewer questions to v2. It carries no step counter — the design numbers
/// none of the intro screens, and the three-step flow its eyebrow used to
/// count is gone.
///
/// The same [IntroPage] shell as the beat before it, because the design draws
/// it as the same shell: mascot above, copy and actions pinned to the foot.
///
/// Skipping costs the learner nothing: Profile greets by name where there is
/// one and greets plainly where there is not.
class NameScreen extends ConsumerStatefulWidget {
  /// Creates a [NameScreen].
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final NameController _controller;

  /// Longer than any name worth greeting, and the design's own cap.
  static const int _maxNameLength = 24;

  @override
  void initState() {
    super.initState();
    _controller = NameController(
      onSubmit: (name) async {
        final draft = ref.read(onboardingDraftProvider.notifier)..setName(name);
        await draft.complete();
      },
      onFinished: () {
        if (mounted) context.goNamed(AppRoutes.learn.name);
      },
    )..addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return IntroPage(
      children: [
        // The design's `space-between`: the mascot holds the upper half, the
        // question and its actions sit at the foot. Flexible rather than fixed
        // so a short viewport shrinks the drawing instead of clipping the
        // field the screen exists to show.
        const Flexible(
          child: Padding(
            padding: EdgeInsets.only(top: _mascotInset),
            child: Center(
              // Labelled by the question below it; the drawing itself says
              // nothing a reader can act on.
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Roasty(state: RoastyState.awake, size: _mascotSize),
                ),
              ),
            ),
          ),
        ),
        Text(NameCopy.title, style: AppText.display(mood: mood)),
        const SizedBox(height: _supportTop),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: introCopyMaxWidth),
          child: Text(
            NameCopy.support,
            style: AppText.body(mood: mood, color: mood.inkMute),
          ),
        ),
        const SizedBox(height: _supportBottom),
        AppTextField(
          autofocus: true,
          enabled: !_controller.submitting,
          maxLength: _maxNameLength,
          placeholder: NameCopy.placeholder,
          onChanged: _controller.type,
          onSubmitted: _controller.submit,
        ),
        const SizedBox(height: _actionGap),
        PrimaryButton(
          label: NameCopy.continueLabel,
          onPressed: _controller.canContinue ? _controller.submit : null,
        ),
        const SizedBox(height: _skipGap),
        GhostButton(
          label: NameCopy.skip,
          onPressed: _controller.submitting ? null : _controller.skip,
        ),
      ],
    );
  }
}
