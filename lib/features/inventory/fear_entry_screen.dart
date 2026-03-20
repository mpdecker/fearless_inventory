Future<void> save() async {
  final repo = ref.read(fearRepositoryProvider);
  final companion = FearsCompanion(
    subject: Value(subjectController.text.trim()),
    why: Value(whyController.text.trim()),
    myPart: Value(myPartController.text.trim()),
    createdAt: Value(DateTime.now()),
  );

  if (existing == null) {
    await repo.insertFear(companion);
  } else {
    // Ensure you are using the correct generated Fear class
    await repo.updateFear(existing!.copyWith(
      subject: subjectController.text.trim(),
      why: whyController.text.trim(),
      myPart: myPartController.text.trim(),
    ));
  }
  if (context.mounted) Navigator.pop(context);
}