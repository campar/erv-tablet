enum LocalizationErrorMsg {
  alreadyCheckedIn(code: 'ALREADY_CHECKED_IN', message: 'Dolazak je već evidentiran.'),
  alreadyCheckedOut(code: 'ALREADY_CHECKED_OUT', message: 'Odlazak je već evidentiran.'),
  alreadyStartedPause(code: 'ALREADY_STARTED_PAUSE', message: 'Početak pauze je već evidentiran.'),
  alreadyEndedPause(code: 'ALREADY_ENDED_PAUSE', message: "Kraj pauze je već evidentiran."),
  businessStartedAlready(code: 'BUSINESS_STARTED_ALREADY', message: 'Poslovni izlazak je već evidentiran.'),
  businessEndedAlready(code: 'BUSINESS_ENDED_ALREADY', message: 'Završetak poslovnog izlaska je već evidentiran.'),
  noCheckIn(code: 'NO_CHECK_IN', message: "Dolazak nije prijavljen."),
  noPauseStart(code: 'NO_PAUSE_START', message: "Pauza nije započeta."),
  noBusinessStart(code: 'NO_BUSINESS_START', message: "Poslovni izlazak nije prijavljen."),
  invalidCard(code: 'INVALID_CARD', message: "Neispravna kartica."),
  noUserShiftActive(code: 'NO_USER_SHIFT_ASSIGNED', message: "Zaposleni nema dodeljenu smenu."),
  noDeviceIdentifier(code: 'NO_DEVICE_IDENTIFIER', message: 'Neispravan identifikator uređaja.'),
  inactiveDevice(code: 'INACTIVE_DEVICE', message: 'Uređaj nije aktivan.');

  final String code;
  final String message;

  const LocalizationErrorMsg({
    required this.message,
    required this.code,
  });

  static LocalizationErrorMsg? getLocalizationErrorMsg(String code) {
    for (LocalizationErrorMsg errorMsg in LocalizationErrorMsg.values) {
      if (errorMsg.code == code.toUpperCase()) return errorMsg;
    }
    return null;
  }
}