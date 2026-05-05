import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(JournalEntry e, Habit? habit, String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase();
    if ((e.note ?? '').toLowerCase().contains(lower)) return true;
    if (habit != null && habit.name.toLowerCase().contains(lower)) return true;
    if ((e.mood ?? '').toLowerCase().contains(lower)) return true;
    if (e.energy != null && e.energy.toString() == q.trim()) return true;
    return false;
  }

  Habit? _findHabit(HabitStore store, String habitId) {
    for (final h in store.habits) {
      if (h.id == habitId) return h;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final journal = store.journal;

    final entries = [...journal]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final filtered = entries.where((e) {
      final h = _findHabit(store, e.habitId);
      return _matches(e, h, _query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const TerminalHeader(command: 'cat journal.log', showDate: false),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(children: [
                      Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'back',
                        style: GoogleFonts.jetBrainsMono(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  border: Border.all(color: AppColors.borderPrimary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      r'$ grep "',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.accentGreen,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        cursorColor: AppColors.accentGreen,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: 'keyword...',
                          hintStyle: GoogleFonts.jetBrainsMono(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '" journal.log',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.accentGreen,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filtered.length} entries match',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'no entries match.',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: AppColors.borderPrimary, height: 16),
                      itemBuilder: (_, i) {
                        final e = filtered[i];
                        final h = _findHabit(store, e.habitId);
                        return _EntryRow(entry: e, habit: h);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final JournalEntry entry;
  final Habit? habit;

  const _EntryRow({required this.entry, required this.habit});

  static const Map<String, String> _moodEmoji = {
    'happy': '😄',
    'neutral': '😐',
    'sad': '😔',
    'frustrated': '😤',
    'sick': '🤒',
  };

  @override
  Widget build(BuildContext context) {
    final dateTime = DateFormat('yyyy-MM-dd HH:mm').format(entry.createdAt);
    final habitName = habit?.name ?? entry.habitId;
    final habitColor =
        habit != null ? Color(habit!.colorValue) : AppColors.textSecondary;

    final mood = entry.mood;
    final energy = entry.energy;
    final hasMoodOrEnergy = mood != null || energy != null;
    final note = entry.note ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: date+time + habit name
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$dateTime  ',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              TextSpan(
                text: habitName,
                style: GoogleFonts.jetBrainsMono(
                  color: habitColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (hasMoodOrEnergy) ...[
          const SizedBox(height: 4),
          Text(
            _moodEnergyLine(mood, energy),
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            note,
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  String _moodEnergyLine(String? mood, int? energy) {
    final parts = <String>[];
    if (mood != null) {
      parts.add(_moodEmoji[mood] ?? mood);
    }
    if (energy != null) {
      final clamped = energy.clamp(0, 5);
      final filled = '▮' * clamped;
      final empty = '▯' * (5 - clamped);
      parts.add('energy: [$filled$empty]');
    }
    return parts.join('  ');
  }
}
