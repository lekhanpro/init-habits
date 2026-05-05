import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/habit_templates.dart';
import '../models/habit.dart';
import '../stores/habit_store.dart';
import '../theme/app_theme.dart';
import '../widgets/terminal_header.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  String _difficultyLabel(HabitDifficulty d) {
    switch (d) {
      case HabitDifficulty.easy:
        return 'easy';
      case HabitDifficulty.normal:
        return 'normal';
      case HabitDifficulty.hard:
        return 'hard';
      case HabitDifficulty.extreme:
        return 'extreme';
    }
  }

  void _install(BuildContext context, HabitTemplate template) {
    context.read<HabitStore>().installTemplate(template.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '[ok] installed: ${template.name}',
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.accentGreen,
            fontSize: 11,
          ),
        ),
        backgroundColor: AppColors.bgSecondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(children: [
          const TerminalHeader(command: 'templates.list()', showDate: false),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(children: [
                  Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('back',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
              const Spacer(),
              Text('${habitTemplates.length} available',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: habitTemplates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final template = habitTemplates[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    border: Border.all(color: AppColors.borderPrimary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...template.habits.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '→ ${h.name} (${_difficultyLabel(h.difficulty)})',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _install(context, template),
                          child: Text(
                            '[install]',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
