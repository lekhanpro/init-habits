import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';

class HabitTimerSheet extends StatefulWidget {
  final Habit habit;
  final String date;
  const HabitTimerSheet({super.key, required this.habit, required this.date});

  static Future<void> show(BuildContext context, Habit habit, String date) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      builder: (_) => HabitTimerSheet(habit: habit, date: date),
    );
  }

  @override
  State<HabitTimerSheet> createState() => _HabitTimerSheetState();
}

class _HabitTimerSheetState extends State<HabitTimerSheet> {
  late int _remaining; // seconds
  late int _total;
  Timer? _ticker;
  bool _running = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _total = (widget.habit.targetMinutes ?? 25) * 60;
    _remaining = _total;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startPause() {
    if (_finished) return;
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
    } else {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_remaining > 0) {
            _remaining--;
          } else {
            _ticker?.cancel();
            _running = false;
            _finished = true;
            // mark complete
            final store = context.read<HabitStore>();
            if (store.getCompletionForHabit(widget.habit.id, widget.date) == null) {
              store.toggleCompletion(widget.habit.id, widget.date);
            }
          }
        });
      });
      setState(() => _running = true);
    }
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _remaining = _total;
      _running = false;
      _finished = false;
    });
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.habit.colorValue);
    final pct = _total > 0 ? 1 - (_remaining / _total) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1))),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.habit.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
            ),
          ]),
          const SizedBox(height: 4),
          Text('// timer.run() — target ${widget.habit.targetMinutes ?? 25} min',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
          const SizedBox(height: 24),
          Center(
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 160, height: 160,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 4,
                  backgroundColor: AppColors.bgTertiary,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_fmt(_remaining),
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w600)),
                Text(_finished ? 'done.' : (_running ? 'running' : 'paused'),
                    style: TextStyle(color: _finished ? AppColors.accentGreen : AppColors.textTertiary, fontSize: 10)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: _reset,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderPrimary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('reset', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _startPause,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _finished ? r'$ done' : (_running ? r'$ pause' : r'$ start'),
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
