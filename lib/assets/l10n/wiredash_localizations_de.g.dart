import 'wiredash_localizations.g.dart';

/// The translations for German (`de`).
class WiredashLocalizationsDe extends WiredashLocalizations {
  WiredashLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get feedbackStep1MessageTitle => 'Schick uns dein Feedback';

  @override
  String get feedbackStep1MessageBreadcrumbTitle => 'Nachricht verfassen';

  @override
  String get feedbackStep1MessageDescription =>
      'Kurze Beschreibung des Fehlers bzw. Änderungswunsches';

  @override
  String get feedbackStep1MessageHint =>
      'Wenn ich mein Avatar ändern möchte, wird ein unbekannter Fehler angezeigt...';

  @override
  String get feedbackStep1MessageErrorMissingMessage =>
      'Bitte füge eine Nachricht hinzu';

  @override
  String get feedbackStep2LabelsTitle =>
      'Kannst du deinem Feedback Labels zuordnen?';

  @override
  String get feedbackStep2LabelsBreadcrumbTitle => 'Labels';

  @override
  String get feedbackStep2LabelsDescription =>
      'Korrekt kategorisiertes Feedback kann einfacher zugeordnet und an den passenden Empfänger weitergeleitet werden';

  @override
  String get feedbackStep3ScreenshotOverviewTitle => 'Screenshot anhängen';

  @override
  String get feedbackStep3ScreenshotOverviewBreadcrumbTitle => 'Screenshots';

  @override
  String get feedbackStep3ScreenshotOverviewDescription =>
      'Du kannst die App normal bedienen, bevor du einen Screenshot erstellst';

  @override
  String get feedbackStep3ScreenshotOverviewSkipButton => 'Überspringen';

  @override
  String get feedbackStep3ScreenshotOverviewAddScreenshotButton => 'Screenshot';

  @override
  String get feedbackStep3ScreenshotBarNavigateTitle => 'Screenshot erstellen';

  @override
  String get feedbackStep3ScreenshotBottomBarTitle =>
      'Füge bei bedarf einen Screenshot hinzu';

  @override
  String get feedbackStep3ScreenshotBarDrawTitle =>
      'Füge Markierungen mit dem Zeichnen-Tool hinzu';

  @override
  String get feedbackStep3ScreenshotBarDrawUndoButton => 'Rückgängig';

  @override
  String get feedbackStep3ScreenshotBarCaptureButton => 'Aufnehmen';

  @override
  String get feedbackStep3ScreenshotBarSaveButton => 'Speichern';

  @override
  String get feedbackStep3ScreenshotBarOkButton => 'Ok';

  @override
  String get feedbackStep3GalleryTitle => 'Angehängte Screenshots';

  @override
  String get feedbackStep3GalleryBreadcrumbTitle => 'Screenshots';

  @override
  String get feedbackStep3GalleryDescription =>
      'Du kannst weitere Screenshots hinzufügen, um dein Problem noch besser zu beschreiben.';

  @override
  String get feedbackStep4EmailTitle =>
      'Werde bei Rückfragen via E-Mail benachrichtigt';

  @override
  String get feedbackStep4EmailBreadcrumbTitle => 'Kontakt';

  @override
  String get feedbackStep4EmailDescription =>
      'Füge deine E-Mail-Adresse hinzu oder lasse das Feld leer.';

  @override
  String get feedbackStep4EmailInvalidEmail =>
      'Kein korrektes E-Mail-Format. Du kannst dieses Feld auch leer lassen.';

  @override
  String get feedbackStep4EmailInputHint => 'mail@example.com';

  @override
  String get feedbackStep6SubmitTitle => 'Feedback absenden';

  @override
  String get feedbackStep6SubmitBreadcrumbTitle => 'Absenden';

  @override
  String get feedbackStep6SubmitDescription =>
      'Bitte kontrolliere dein Feedback vor dem Absenden.\nDu kannst jederzeit zurückgehen, um dein Feedback noch einmal anzupassen.';

  @override
  String get feedbackStep6SubmitSubmitButton => 'Absenden';

  @override
  String get feedbackStep6SubmitSubmitShowDetailsButton => 'Details anzeigen';

  @override
  String get feedbackStep6SubmitSubmitHideDetailsButton => 'Details ausblenden';

  @override
  String get feedbackStep6SubmitSubmitDetailsTitle => 'Feedback Details';

  @override
  String get feedbackStep7SubmissionInFlightMessage => 'Feedback wird gesendet';

  @override
  String get feedbackStep7SubmissionSuccessMessage =>
      'Danke für dein Feedback!';

  @override
  String get feedbackStep7SubmissionErrorMessage => 'Absenden fehlgeschlagen';

  @override
  String get feedbackStep7SubmissionOpenErrorButton =>
      'Klicke hier, um weitere Fehler-Details einzusehen.';

  @override
  String get feedbackStep7SubmissionRetryButton => 'Wiederholen';

  @override
  String feedbackStepXOfY(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get feedbackDiscardButton => 'Feedback verwerfen';

  @override
  String get feedbackDiscardConfirmButton => 'Sicher? Löschen!';

  @override
  String get feedbackNextButton => 'Weiter';

  @override
  String get feedbackBackButton => 'Zurück';

  @override
  String get feedbackCloseButton => 'Schließen';

  @override
  String get promoterScoreStep1Question =>
      'Mit welcher Wahrscheinlichkeit würdest Du uns weiterempfehlen?';

  @override
  String get promoterScoreStep1Description =>
      '0 = Nicht wahrscheinlich, 10 = Sehr wahrscheinlich';

  @override
  String get promoterScoreStep2MessageTitle =>
      'Mit welcher Wahrscheinlichkeit würdest Du uns Deinen Freunden und Deiner Familie weiterempfehlen?';

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return 'Könntest Du uns mehr über Deine Auswahl erzählen $rating? Dieser Schritt ist optional.';
  }

  @override
  String get promoterScoreStep2MessageHint =>
      'Es wäre super, wenn ihr folgendes verbessern könntet...';

  @override
  String get promoterScoreStep3ThanksMessagePromoters =>
      'Danke für Deine Bewertung!';

  @override
  String get promoterScoreStep3ThanksMessagePassives =>
      'Danke für Deine Bewertung!';

  @override
  String get promoterScoreStep3ThanksMessageDetractors =>
      'Danke für Deine Bewertung!';

  @override
  String get promoterScoreNextButton => 'Weiter';

  @override
  String get promoterScoreBackButton => 'Zurück';

  @override
  String get promoterScoreSubmitButton => 'Abschicken';

  @override
  String get backdropReturnToApp => 'Zurück zur App';
}
