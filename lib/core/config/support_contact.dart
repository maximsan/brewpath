/// Where a learner is sent to reach a human or read the fine print.
///
/// Every value is null until the thing it names exists, and a row pointing at
/// one is **absent while it is null** — never drawn live and inert. Filling
/// them in is the owner's step: create the mailbox (#531), host the two
/// pages (#448).
library;

/// The mailbox a learner writes to, or null while none exists.
///
/// Read by Help's *Email support* and *Report a problem*, and by About's
/// *Say hello* (#532).
const String? supportEmail = null;

/// The hosted Terms of use, or null while the page does not exist (#448).
const String? termsUrl = null;

/// The hosted Privacy policy, or null while the page does not exist (#448).
const String? privacyUrl = null;
