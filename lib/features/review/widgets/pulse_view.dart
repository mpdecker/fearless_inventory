Widget _buildPulseSquare(DayReflection day) {
  // We use empathetic colors: Teal for 'Clear', Muted Gold/Clay for 'Busy'
  Color blockColor;
  if (day.intensity == 0) {
    blockColor = Colors.teal.shade100; // A peaceful, clear day
  } else if (day.intensity <= 2) {
    blockColor = Colors.orange.shade100; // A bit of a "human" day
  } else {
    blockColor = Colors.orange.shade300; // A day with several opportunities for growth
  }

  return Column(
    children: [
      Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: blockColor,
          borderRadius: BorderRadius.circular(6),
          border: day.hasNotes ? Border.all(color: Colors.teal.shade300, width: 2) : null,
        ),
      ),
      const SizedBox(height: 4),
      Text(DateFormat('E').format(day.date)[0], style: const TextStyle(fontSize: 10)),
    ],
  );
}