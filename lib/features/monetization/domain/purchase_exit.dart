import 'package:brew_path/features/monetization/domain/plus_purchase_controller.dart';
import 'package:flutter/foundation.dart';

/// Which door an arriving entitlement leaves by.
///
/// [PlusPurchase] reports only that Plus is owned, so the press that asked for
/// it is remembered here: a buy is a sale to celebrate, a restore is a learner
/// getting back what they already paid for. Every surface that sells shares
/// this, so the sheet and the paywall can never draw the line differently.
class PurchaseExit {
  /// Creates an exit that runs [onPurchased] after a buy and [onRestored]
  /// after a Restore.
  PurchaseExit({required this.onPurchased, required this.onRestored});

  /// Run once the store says the learner has just bought Plus.
  final VoidCallback onPurchased;

  /// Run once Restore recovers a purchase made earlier.
  final VoidCallback onRestored;

  bool _restoring = false;
  bool _left = false;

  /// Runs [controller]'s restore, marking what it recovers as a recovery.
  Future<void> restore(PlusPurchase controller) async {
    _restoring = true;
    await controller.restore();
    // Cleared once the restore has settled, whatever it found: a sale made
    // after a restore that recovered nothing is still a sale.
    _restoring = false;
  }

  /// Takes the exit [state] calls for, at most once — a celebration that
  /// opened twice would leave the learner one back stack deeper than they came.
  void settle(PlusPurchaseState state) {
    if (state != PlusPurchaseState.owned || _left) return;
    _left = true;
    _restoring ? onRestored() : onPurchased();
  }
}
