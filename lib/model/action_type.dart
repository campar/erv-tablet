enum ActionType {
  checkIn(label: 'DOLAZAK', code: 'CHECK_IN'),
  checkOut(label: 'ODLAZAK', code: 'CHECK_OUT'),
  pauseStart(label: 'PAUZA POČETAK', code: 'PAUSE_START'),
  pauseEnd(label: 'PAUZA KRAJ', code: 'PAUSE_END'),
  businessOut(label: 'POSLOVNI IZLAZAK', code: 'BUSINESS_START'),
  businessOutEnd(label: 'KRAJ POSLOVNOG IZLASKA', code: 'BUSINESS_END');

  final String label;
  final String code;

  const ActionType({
    required this.label,
    required this.code,
  });

  static ActionType? getActionType(String code) {
    for (ActionType actionType in ActionType.values) {
      if (actionType.code == code.toUpperCase()) return actionType;
    }
    return null;
  }
}