import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late TextEditingController _controller;
  late String _date;
  String _lastLoadedDate = '';

  @override
  void initState() {
    super.initState();
    _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _saveIfDirty();
    _controller.dispose();
    super.dispose();
  }

  void _saveIfDirty() {
    final store = context.read<HabitStore>();
    store.setJournalEntry(_date, _controller.text);
  }

  void _hydrate(HabitStore store) {
    if (_lastLoadedDate == _date) return;
    final entry = store.getJournalForDate(_date);
    _controller.text = entry?.text ?? '';
    _lastLoadedDate = _date;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    _hydrate(store);

    final entries = [...store.journal]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const TerminalHeader(command: 'journal.today()', showDate: false),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(children: [
                    Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('back', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ]),
                ),
                const Spacer(),
                Text(DateFormat('EEE, MMM d').format(DateTime.parse(_date)),
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: '> note for today...',
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
                onChanged: (_) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  _saveIfDirty();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.bgSecondary,
                      content: Text('saved.',
                          style: TextStyle(color: AppColors.accentGreen, fontSize: 11)),
                      duration: const Duration(milliseconds: 1200),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(r'$ journal.save()',
                      style: TextStyle(color: AppColors.accentGreen, fontSize: 12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('// past_entries (${entries.length})',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    Divider(color: AppColors.borderPrimary, height: 16),
                itemBuilder: (_, i) {
                  final e = entries[i];
                  return GestureDetector(
                    onTap: () {
                      _saveIfDirty();
                      setState(() {
                        _date = e.date;
                        _lastLoadedDate = '';
                      });
                    },
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(DateFormat('EEE, MMM d').format(DateTime.parse(e.date)),
                          style: TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(e.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
