'use client';

import { useHabitStore } from '@/stores/habitStore';
import { useMemo } from 'react';
import { format, subDays } from 'date-fns';

export default function StatsGrid() {
  const { habits, completions } = useHabitStore();

  const stats = useMemo(() => {
    const today = new Date();
    const activeHabits = habits.filter(h => !h.archived);
    const totalHabits = activeHabits.length;

    // Current streak (days with at least 1 completion)
    let currentStreak = 0;
    for (let i = 0; i < 365; i++) {
      const date = format(subDays(today, i), 'yyyy-MM-dd');
      const dayCompletions = completions.filter(c => c.date === date && c.completed);
      if (dayCompletions.length > 0) currentStreak++;
      else break;
    }

    // Best streak
    let bestStreak = 0;
    let tempStreak = 0;
    for (let i = 0; i < 365; i++) {
      const date = format(subDays(today, i), 'yyyy-MM-dd');
      const dayCompletions = completions.filter(c => c.date === date && c.completed);
      if (dayCompletions.length > 0) {
        tempStreak++;
        bestStreak = Math.max(bestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }

    // 7-day completion rate
    let completed7 = 0;
    let total7 = 0;
    for (let i = 0; i < 7; i++) {
      const date = format(subDays(today, i), 'yyyy-MM-dd');
      const dayCompletions = completions.filter(c => c.date === date && c.completed);
      completed7 += dayCompletions.length;
      total7 += totalHabits;
    }

    // Perfect days (all habits done)
    let perfectDays = 0;
    for (let i = 0; i < 90; i++) {
      const date = format(subDays(today, i), 'yyyy-MM-dd');
      const dayCompletions = completions.filter(c => c.date === date && c.completed);
      if (dayCompletions.length >= totalHabits && totalHabits > 0) perfectDays++;
    }

    // Total completions
    const totalCompletions = completions.filter(c => c.completed).length;

    return [
      { label: 'current_streak', value: currentStreak, unit: 'days', color: '#00FF9F' },
      { label: 'best_streak', value: bestStreak, unit: 'days', color: '#FFB800' },
      { label: 'rate_7d', value: total7 > 0 ? Math.round((completed7 / total7) * 100) : 0, unit: '%', color: '#00B4FF' },
      { label: 'perfect_days', value: perfectDays, unit: '/90d', color: '#A855F7' },
      { label: 'total_done', value: totalCompletions, unit: '', color: '#22D3EE' },
      { label: 'active_habits', value: totalHabits, unit: '', color: '#FF6B2C' },
    ];
  }, [habits, completions]);

  return (
    <div className="px-4 py-3">
      <div className="text-[11px] text-text-secondary mb-3 flex items-center gap-1.5">
        <span className="text-accent-green">$</span> stats.summary()
      </div>
      <div className="grid grid-cols-2 gap-3">
        {stats.map((stat) => (
          <div key={stat.label} className="bg-bg-tertiary/50 px-3 py-2.5 rounded-[4px] border border-border-primary">
            <div className="text-[10px] text-text-tertiary">{stat.label}</div>
            <div className="flex items-baseline gap-1 mt-0.5">
              <span className="text-[20px] font-bold" style={{ color: stat.color }}>
                {stat.value}
              </span>
              <span className="text-[10px] text-text-tertiary">{stat.unit}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
