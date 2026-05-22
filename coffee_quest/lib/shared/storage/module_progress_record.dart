/// Mutable DTO for a module-progress row. A row exists only once a module's
/// completion XP has been granted, so its presence is the "awarded" ledger.
class ModuleProgressRecord {
  ModuleProgressRecord({
    this.id = 0,
    required this.moduleId,
    required this.moduleXpAwarded,
  });

  int id;
  String moduleId;
  bool moduleXpAwarded;
}
