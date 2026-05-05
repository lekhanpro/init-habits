import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/habit.dart';
import '../models/chain.dart';
import '../models/settings.dart';

class ExportService {
  static Future<String> buildJsonExport({
    required List<Habit> habits,
    required List<Completion> completions,
    required List<JournalEntry> journal,
    required List<HabitChain> chains,
    required Set<String> unlockedAchievements,
    required Set<String> shownMilestones,
    required AppSettings settings,
  }) async {
    final payload = <String, dynamic>{
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'completions': completions.map((c) => c.toJson()).toList(),
      'journal': journal.map((j) => j.toJson()).toList(),
      'chains': chains.map((c) => c.toJson()).toList(),
      'unlockedAchievements': unlockedAchievements.toList(),
      'shownMilestones': shownMilestones.toList(),
      'settings': settings.toJson(),
    };
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  static String buildCsvExport({
    required List<Habit> habits,
    required List<Completion> completions,
    required List<JournalEntry> journal,
  }) {
    final habitNameById = <String, String>{
      for (final h in habits) h.id: h.name,
    };

    // Index journal by date for note lookup. JournalEntry has no habitId,
    // so we key by date and pick the latest by updatedAt when duplicates exist.
    final journalByDate = <String, JournalEntry>{};
    for (final j in journal) {
      final existing = journalByDate[j.date];
      if (existing == null || j.updatedAt.isAfter(existing.updatedAt)) {
        journalByDate[j.date] = j;
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('date,habit_id,habit_name,completed,mood,energy,note');

    for (final c in completions) {
      final habitName = habitNameById[c.habitId] ?? '';
      final mood = c.mood?.toString() ?? '';
      final energy = c.energyLevel?.toString() ?? '';
      // Prefer per-completion note; fall back to a journal entry on the same date.
      String note = c.note ?? '';
      if (note.isEmpty) {
        final j = journalByDate[c.date];
        if (j != null) note = j.text;
      }

      final row = <String>[
        c.date,
        c.habitId,
        habitName,
        c.completed ? 'true' : 'false',
        mood,
        energy,
        note,
      ].map(_csvEscape).join(',');
      buffer.writeln(row);
    }

    return buffer.toString();
  }

  static String _csvEscape(String field) {
    if (field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r')) {
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return field;
  }

  static Future<File> writeExportFile(String content, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$filename');
    await file.writeAsString(content, encoding: utf8, flush: true);
    return file;
  }
}
