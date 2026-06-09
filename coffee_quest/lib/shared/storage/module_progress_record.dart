// Self-describing tokens / DTOs / storage infra; no per-member docs.
// ignore_for_file: public_member_api_docs

/// Mutable DTO for a module-progress row. A row exists only once a module's
/// completion XP has been granted, so its presence is the "awarded" ledger.
class ModuleProgressRecord {
  ModuleProgressRecord({
    required this.moduleId, required this.moduleXpAwarded, this.id = 0,
  });

  int id;
  String moduleId;
  bool moduleXpAwarded;
}
