import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class AddHabitScreen extends StatefulWidget {
  /// If [existing] is non-null we are in edit mode.
  final Habit? existing;
  const AddHabitScreen({super.key, this.existing});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  late final TextEditingController _nameController;
  late HabitType _type;
  late HabitSection _section;
  late int _colorValue;
  int? _targetCount;
  int? _targetMinutes;
  List<int> _schedule = [];
  TimeOfDay? _reminder;

  static const _colorChoices = <int>[
    0xFF00FF9F,
    0xFFFFB800,
    0xFF00B4FF,
    0xFFA855F7,
    0xFFFF4444,
    0xFF22D3EE,
    0xFFFF6B2C,
    0xFFE8E8ED,
  ];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    _nameController = TextEditingController(text: h?.name ?? '');
    _type = h?.type ?? HabitType.boolean;
    _section = h?.section ?? HabitSection.morning;
    _colorValue = h?.colorValue ?? SectionConfig.configs[_section]!.colorValue;
    _targetCount = h?.targetCount;
    _targetMinutes = h?.targetMinutes;
    _schedule = List<int>.from(h?.schedule ?? []);
    if (h?.reminderMinutes != null) {
      _reminder = TimeOfDay(hour: h!.reminderMinutes! ~/ 60, minute: h.reminderMinutes! % 60);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final reminderMinutes = _reminder == null ? null : _reminder!.hour * 60 + _reminder!.minute;
    final store = context.read<HabitStore>();

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name: name,
        type: _type,
        section: _section,
        colorValue: _colorValue,
        targetCount: _type == HabitType.count ? _targetCount : null,
        targetMinutes: _type == HabitType.timer ? _targetMinutes : null,
        schedule: _schedule,
        reminderMinutes: reminderMinutes,
        clearReminder: reminderMinutes == null,
      );
      store.updateHabit(updated);
    } else {
      final habit = Habit(
        id: const Uuid().v4(),
        name: name,
        type: _type,
        section: _section,
        colorValue: _colorValue,
        targetCount: _type == HabitType.count ? _targetCount : null,
        targetMinutes: _type == HabitType.timer ? _targetMinutes : null,
        schedule: _schedule,
        reminderMinutes: reminderMinutes,
      );
      store.addHabit(habit);
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    if (!_isEdit) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "${widget.existing!.name}"?',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            const SizedBox(height: 6),
            Text('This removes the habit and its completions.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.borderPrimary)),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed.withValues(alpha: 0.15),
                    foregroundColor: AppColors.accentRed,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<HabitStore>().deleteHabit(widget.existing!.id);
                    Navigator.pop(context);
                  },
                  child: const Text('delete'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminder() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _reminder ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (ctx, child) =>
          Theme(data: Theme.of(ctx).copyWith(useMaterial3: true), child: child!),
    );
    if (t != null) setState(() => _reminder = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            TerminalHeader(
              command: _isEdit ? 'habits.edit()' : 'habits.new()',
              showDate: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('back', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_isEdit ? '// edit habit' : '// create new habit',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 12),
                  Text('--name', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    decoration: const InputDecoration(hintText: 'Habit name'),
                  ),
                  const SizedBox(height: 16),
                  Text('--type', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: HabitType.values
                        .map((t) => _chip(t.name, _type == t, () => setState(() => _type = t)))
                        .toList(),
                  ),
                  if (_type == HabitType.count) ...[
                    const SizedBox(height: 12),
                    Text('--target_count',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    const SizedBox(height: 4),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                      decoration: const InputDecoration(hintText: 'e.g. 8'),
                      controller: TextEditingController(text: _targetCount?.toString() ?? '')
                        ..selection = TextSelection.collapsed(
                            offset: (_targetCount?.toString() ?? '').length),
                      onChanged: (v) => _targetCount = int.tryParse(v),
                    ),
                  ],
                  if (_type == HabitType.timer) ...[
                    const SizedBox(height: 12),
                    Text('--target_minutes',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    const SizedBox(height: 4),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                      decoration: const InputDecoration(hintText: 'e.g. 25'),
                      controller: TextEditingController(text: _targetMinutes?.toString() ?? '')
                        ..selection = TextSelection.collapsed(
                            offset: (_targetMinutes?.toString() ?? '').length),
                      onChanged: (v) => _targetMinutes = int.tryParse(v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('--section', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: HabitSection.values.map((s) {
                      final label = SectionConfig.configs[s]!.label;
                      return _chip(label, _section == s, () {
                        setState(() {
                          _section = s;
                          if (!_colorChoices.contains(_colorValue)) {
                            _colorValue = SectionConfig.configs[s]!.colorValue;
                          }
                        });
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('--color', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorChoices.map((c) {
                      final selected = _colorValue == c;
                      final color = Color(c);
                      return GestureDetector(
                        onTap: () => setState(() => _colorValue = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: selected ? 0.6 : 0.25),
                            border: Border.all(
                                color: selected ? color : AppColors.borderPrimary,
                                width: selected ? 2 : 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('--schedule', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final selected = _schedule.isEmpty || _schedule.contains(day);
                      return _chip(labels[i], selected, () {
                        setState(() {
                          if (_schedule.isEmpty) {
                            _schedule = [1, 2, 3, 4, 5, 6, 7];
                          }
                          if (_schedule.contains(day)) {
                            _schedule.remove(day);
                          } else {
                            _schedule.add(day);
                            _schedule.sort();
                          }
                          if (_schedule.length == 7) {
                            _schedule = [];
                          }
                        });
                      });
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _schedule.isEmpty ? 'runs every day' : 'runs ${_schedule.length} day(s) per week',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 9),
                  ),
                  const SizedBox(height: 16),
                  Text('--reminder', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 4),
                  Row(children: [
                    GestureDetector(
                      onTap: _pickReminder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bgTertiary,
                          border: Border.all(color: AppColors.borderPrimary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(children: [
                          Icon(Icons.alarm, size: 14, color: AppColors.accentGreen),
                          const SizedBox(width: 6),
                          Text(
                            _reminder == null
                                ? 'no reminder'
                                : _reminder!.format(context),
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 11),
                          ),
                        ]),
                      ),
                    ),
                    if (_reminder != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _reminder = null),
                        child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 24),
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
                      child: Text(_isEdit ? r'$ habit.save()' : r'$ add_habit --save',
                          style: TextStyle(color: AppColors.accentGreen, fontSize: 12)),
                    ),
                  ),
                  if (_isEdit) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _delete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(r'$ habit.delete()',
                            style: TextStyle(color: AppColors.accentRed, fontSize: 12)),
                      ),
                    ),
                  ],
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
          border: Border.all(
              color: selected
                  ? AppColors.accentGreen.withValues(alpha: 0.3)
                  : AppColors.borderPrimary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.accentGreen : AppColors.textSecondary, fontSize: 11)),
      ),
    );
  }
}
