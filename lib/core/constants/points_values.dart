/// The one payout value not authored in content.
///
/// A lesson's payout is per-lesson data (`points`, ten for all thirty-two), so
/// it is read off the lesson rather than named here. A challenge's is not
/// authored anywhere, so it lives here — and that is the whole register,
/// because **two rules pay and nothing else does** (§5.1, #16).
///
/// The ceiling is stated as `lessons × 10 + challenges × 5` wherever it is
/// needed and never as a literal — written down once as 370, it went stale one
/// design pass later when a thirty-second lesson landed.
abstract final class PointsValues {
  /// Granted the first time a Coffee Challenge is logged. Replays pay nothing.
  static const int challengeCompletion = 5;
}
