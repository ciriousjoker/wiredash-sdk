/// A label/tag can be assigned to a [PersistedFeedbackItem].
///
/// Users can select multiple labels for each feedback.
///
/// Hidden labels are not shown in the UI. They are always sent to the console
class Label {
  const Label({
    required this.id,
    required this.title,
    this.hidden,
  });

  /// The unique identifier of the label, generated by the console
  ///
  /// Grab the label id from the console https://console.wiredash.io/ at
  /// Settings -> Labels
  final String id;

  /// The title of the label, displayed to the user. You might want to use a
  /// localized string here.
  final String title;

  /// A hidden label is not visible to the user. It will be sent directly to the
  /// console
  ///
  /// Defaults to `false`
  final bool? hidden;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          hidden == other.hidden);

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ hidden.hashCode;

  @override
  String toString() {
    return 'Label{'
        'id: $id, '
        'title: $title, '
        'hidden: $hidden'
        '}';
  }
}
