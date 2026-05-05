import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/chain.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';

class ChainsScreen extends StatefulWidget {
  const ChainsScreen({super.key});
  @override
  State<ChainsScreen> createState() => _ChainsScreenState();
}

class _ChainsScreenState extends State<ChainsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final today = DateTime.now().toString().substring(0, 10);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                Text('> chains.list()',
                    style: TextStyle(
                        color: AppColors.accentGreen, fontSize: 11, letterSpacing: 1.2)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showCreateChainDialog(context, store),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('+ new chain',
                        style: TextStyle(color: AppColors.accentGreen, fontSize: 10)),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: store.chains.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: store.chains.length,
                      itemBuilder: (_, i) => _chainCard(store, store.chains[i], today),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('> chains.empty()', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
        const SizedBox(height: 8),
        Text('Chain habits that you always do together',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        Text('e.g. meditate → journal → cold shower',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
      ]),
    );
  }

  Widget _chainCard(HabitStore store, HabitChain chain, String today) {
    final (done, total) = store.chainProgressForDate(chain.id, today);
    final pct = total > 0 ? done / total : 0.0;
    final habits = chain.habitIds
        .map((id) => store.habits.firstWhere((h) => h.id == id,
            orElse: () =>
                Habit(id: id, name: '?', type: HabitType.boolean, section: HabitSection.custom, colorValue: 0xFF888888)))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border.all(color: AppColors.borderPrimary),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(chain.name,
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('$done/$total',
                style: TextStyle(color: AppColors.accentCyan, fontSize: 11)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => store.removeChain(chain.id),
              child: Icon(Icons.close, size: 14, color: AppColors.textTertiary),
            ),
          ]),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.bgTertiary,
              valueColor: AlwaysStoppedAnimation(
                pct >= 1.0 ? AppColors.accentGreen : AppColors.accentBlue,
              ),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 8),
          // Habit chain flow
          Row(
            children: [
              for (int i = 0; i < habits.length; i++) ...[
                _habitChip(store, habits[i], today),
                if (i < habits.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward, size: 10, color: AppColors.textTertiary),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _habitChip(HabitStore store, Habit habit, String today) {
    final done = store.getCompletionForHabit(habit.id, today) != null;
    final color = Color(habit.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: done ? color.withValues(alpha: 0.2) : AppColors.bgTertiary,
        border: Border.all(color: done ? color.withValues(alpha: 0.5) : AppColors.borderPrimary),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (done) Icon(Icons.check, size: 8, color: color),
        if (done) const SizedBox(width: 3),
        Text(habit.name,
            style: TextStyle(
                color: done ? color : AppColors.textSecondary,
                fontSize: 9,
                fontWeight: done ? FontWeight.w600 : FontWeight.normal),
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  void _showCreateChainDialog(BuildContext context, HabitStore store) {
    final nameCtrl = TextEditingController();
    final selected = <String>[];
    final activeHabits = store.habits.where((h) => !h.archived && h.chainId == null).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('> chain.new()',
                  style: TextStyle(color: AppColors.accentGreen, fontSize: 11)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'chain name',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgTertiary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: AppColors.borderPrimary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: AppColors.borderPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('select habits (in order):',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: activeHabits.map((h) {
                  final idx = selected.indexOf(h.id);
                  final isSelected = idx >= 0;
                  return GestureDetector(
                    onTap: () => setModalState(() {
                      if (isSelected) selected.remove(h.id);
                      else selected.add(h.id);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentCyan.withValues(alpha: 0.15)
                            : AppColors.bgTertiary,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentCyan.withValues(alpha: 0.4)
                              : AppColors.borderPrimary,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        isSelected ? '${idx + 1}. ${h.name}' : h.name,
                        style: TextStyle(
                          color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty || selected.length < 2) return;
                  store.addChain(HabitChain(
                    id: const Uuid().v4(),
                    name: name,
                    habitIds: List.from(selected),
                  ));
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('create chain',
                      style: TextStyle(color: AppColors.accentGreen, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
