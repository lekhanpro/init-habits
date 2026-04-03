import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  HabitType _type = HabitType.boolean;
  HabitSection _section = HabitSection.morning;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final cfg = SectionConfig.configs[_section]!;
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      type: _type,
      section: _section,
      colorValue: cfg.colorValue,
    );

    context.read<HabitStore>().addHabit(habit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const TerminalHeader(command: 'habits.new()', showDate: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text('back', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('// create new habit', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 12),
                  // Name
                  const Text('--name', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    decoration: const InputDecoration(hintText: 'Habit name'),
                  ),
                  const SizedBox(height: 16),
                  // Type
                  const Text('--type', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: HabitType.values.map((t) => _chip(t.name, _type == t, () => setState(() => _type = t))).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Section
                  const Text('--section', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: HabitSection.values.map((s) {
                      final label = SectionConfig.configs[s]!.label;
                      return _chip(label, _section == s, () => setState(() => _section = s));
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Submit
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: const Text('\$ add_habit --save', style: TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentGreen.withValues(alpha: 0.15) : AppColors.bgTertiary,
          border: Border.all(color: selected ? AppColors.accentGreen.withValues(alpha: 0.3) : AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(color: selected ? AppColors.accentGreen : AppColors.textSecondary, fontSize: 11)),
      ),
    );
  }
}
