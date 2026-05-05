import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

enum _PomoPhase { work, breakPhase }
enum _PomoStatus { stopped, running, paused }

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const List<int> _workOptions = [10, 15, 25];
  static const List<int> _breakOptions = [5, 10];

  int _workMinutes = 25;
  int _breakMinutes = 5;

  _PomoPhase _phase = _PomoPhase.work;
  _PomoStatus _status = _PomoStatus.stopped;
  int _remaining = 25 * 60;
  int _phaseTotal = 25 * 60;

  Timer? _ticker;
  Habit? _linkedHabit;
  // ensures we only check-in once per completed work session
  bool _checkedInThisWork = false;

  String get _todayDateStr =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  bool get _isRunning => _status == _PomoStatus.running;
  bool get _isStopped => _status == _PomoStatus.stopped;
  bool get _isPaused => _status == _PomoStatus.paused;

  void _cycleWork() {
    if (!_isStopped) return;
    final i = _workOptions.indexOf(_workMinutes);
    final next = _workOptions[(i + 1) % _workOptions.length];
    setState(() {
      _workMinutes = next;
      if (_phase == _PomoPhase.work) {
        _phaseTotal = _workMinutes * 60;
        _remaining = _phaseTotal;
      }
    });
  }

  void _cycleBreak() {
    if (!_isStopped) return;
    final i = _breakOptions.indexOf(_breakMinutes);
    final next = _breakOptions[(i + 1) % _breakOptions.length];
    setState(() {
      _breakMinutes = next;
      if (_phase == _PomoPhase.breakPhase) {
        _phaseTotal = _breakMinutes * 60;
        _remaining = _phaseTotal;
      }
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) {
          _remaining--;
        }
        if (_remaining <= 0) {
          _onPhaseComplete();
        }
      });
    });
  }

  void _start() {
    if (_isRunning) return;
    setState(() {
      if (_isStopped) {
        // Begin a fresh work session
        _phase = _PomoPhase.work;
        _phaseTotal = _workMinutes * 60;
        _remaining = _phaseTotal;
        _checkedInThisWork = false;
      }
      _status = _PomoStatus.running;
    });
    _startTicker();
  }

  void _pause() {
    if (!_isRunning) return;
    _ticker?.cancel();
    setState(() => _status = _PomoStatus.paused);
  }

  void _resume() {
    if (!_isPaused) return;
    setState(() => _status = _PomoStatus.running);
    _startTicker();
  }

  void _skip() {
    if (_isStopped) return;
    _ticker?.cancel();
    _onPhaseComplete(skipped: true);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _status = _PomoStatus.stopped;
      _phase = _PomoPhase.work;
      _phaseTotal = _workMinutes * 60;
      _remaining = _phaseTotal;
      _checkedInThisWork = false;
    });
  }

  void _onPhaseComplete({bool skipped = false}) {
    final wasWork = _phase == _PomoPhase.work;
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (wasWork) {
      // Try habit check-in once per completed work session.
      // Skip check-in on a manual skip to avoid rewarding non-work.
      if (!skipped && !_checkedInThisWork && _linkedHabit != null) {
        try {
          final store = context.read<HabitStore>();
          store.toggleCompletion(_linkedHabit!.id, _todayDateStr);
          _checkedInThisWork = true;
          messenger?.showSnackBar(SnackBar(
            content: Text(
              '[ok] checked in: ${_linkedHabit!.name}',
              style: GoogleFonts.jetBrainsMono(fontSize: 11),
            ),
            duration: const Duration(seconds: 2),
          ));
        } catch (_) {
          // user not signed-in, store missing, etc — silently ignore.
        }
      }

      messenger?.showSnackBar(SnackBar(
        content: Text(
          skipped
              ? '[ok] work skipped — break time'
              : '[ok] work session complete — break time',
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
        ),
        duration: const Duration(seconds: 2),
      ));

      // Auto-start break
      setState(() {
        _phase = _PomoPhase.breakPhase;
        _phaseTotal = _breakMinutes * 60;
        _remaining = _phaseTotal;
        _status = _PomoStatus.running;
        _checkedInThisWork = false;
      });
      _startTicker();
    } else {
      // break complete -> stop & reset to work defaults
      messenger?.showSnackBar(SnackBar(
        content: Text(
          skipped
              ? '[ok] break skipped — back to work'
              : '[ok] break over — back to work',
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
        ),
        duration: const Duration(seconds: 2),
      ));
      setState(() {
        _phase = _PomoPhase.work;
        _phaseTotal = _workMinutes * 60;
        _remaining = _phaseTotal;
        _status = _PomoStatus.stopped;
        _checkedInThisWork = false;
      });
    }
  }

  String _fmtMMSS(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  String _progressBar() {
    const width = 15;
    final pct = _phaseTotal > 0
        ? (1.0 - (_remaining / _phaseTotal)).clamp(0.0, 1.0)
        : 0.0;
    final filled = (pct * width).round().clamp(0, width);
    final empty = width - filled;
    return '[${'█' * filled}${'░' * empty}]';
  }

  Widget _chip({
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.textSecondary;
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border.all(
              color: disabled
                  ? AppColors.borderPrimary
                  : c.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: disabled ? AppColors.textTertiary : c,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _button({
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.bgSecondary
              : color.withValues(alpha: 0.15),
          border: Border.all(
              color: disabled
                  ? AppColors.borderPrimary
                  : color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: disabled ? AppColors.textTertiary : color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits =
        context.watch<HabitStore>().habits.where((h) => !h.archived).toList();

    final isWork = _phase == _PomoPhase.work;
    final phaseColor = isWork ? AppColors.accentGreen : AppColors.accentBlue;
    final phaseLabel = isWork ? 'work' : 'break';

    final actionButtons = <Widget>[];
    if (_isStopped) {
      actionButtons.add(_button(
        label: '[start]',
        onTap: _start,
        color: AppColors.accentGreen,
      ));
    } else if (_isRunning) {
      actionButtons.add(_button(
        label: '[pause]',
        onTap: _pause,
        color: AppColors.accentYellow,
      ));
    } else if (_isPaused) {
      actionButtons.add(_button(
        label: '[resume]',
        onTap: _resume,
        color: AppColors.accentGreen,
      ));
    }
    actionButtons.add(_button(
      label: '[skip]',
      onTap: _isStopped ? null : _skip,
      color: AppColors.textSecondary,
    ));
    actionButtons.add(_button(
      label: '[reset]',
      onTap: _reset,
      color: AppColors.accentRed,
    ));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(children: [
          const TerminalHeader(command: 'pomodoro.run()', showDate: false),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(children: [
                  Icon(Icons.arrow_back,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('back',
                      style: GoogleFonts.jetBrainsMono(
                          color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
              const Spacer(),
              Text(
                _isRunning
                    ? 'status: running'
                    : (_isPaused ? 'status: paused' : 'status: idle'),
                style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textTertiary, fontSize: 10),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pickers row
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        label: 'work [${_workMinutes}m]',
                        onTap: _isStopped ? _cycleWork : null,
                        color: AppColors.accentGreen,
                      ),
                      _chip(
                        label: 'break [${_breakMinutes.toString().padLeft(2, '0')}m]',
                        onTap: _isStopped ? _cycleBreak : null,
                        color: AppColors.accentBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Habit picker
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      border: Border.all(color: AppColors.borderPrimary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(children: [
                      Text('link → habit',
                          style: GoogleFonts.jetBrainsMono(
                              color: AppColors.textTertiary, fontSize: 10)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Habit?>(
                            isExpanded: true,
                            value: _linkedHabit,
                            dropdownColor: AppColors.bgSecondary,
                            iconEnabledColor: AppColors.textSecondary,
                            hint: Text(
                              '(none)',
                              style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.textTertiary, fontSize: 11),
                            ),
                            items: <DropdownMenuItem<Habit?>>[
                              DropdownMenuItem<Habit?>(
                                value: null,
                                child: Text(
                                  '(none)',
                                  style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.textTertiary,
                                      fontSize: 11),
                                ),
                              ),
                              ...habits.map((h) => DropdownMenuItem<Habit?>(
                                    value: h,
                                    child: Text(
                                      h.name,
                                      style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.textPrimary,
                                          fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ],
                            onChanged: _isStopped
                                ? (h) => setState(() => _linkedHabit = h)
                                : null,
                          ),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 32),

                  // Big timer display
                  Text(
                    '[$phaseLabel] [${_fmtMMSS(_remaining)} remaining]',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      color: phaseColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  Text(
                    _progressBar(),
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'phase ${isWork ? 'work' : 'break'} · '
                    '${_fmtMMSS(_phaseTotal - _remaining)} elapsed / '
                    '${_fmtMMSS(_phaseTotal)} total',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons row
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: actionButtons,
                  ),

                  const SizedBox(height: 24),
                  Text(
                    '// tip: link a habit to auto-checkin on work complete',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
