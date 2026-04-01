'use client';

import PageShell from '@/components/layout/PageShell';
import TerminalHeader from '@/components/layout/TerminalHeader';
import DateNav from '@/components/habits/DateNav';
import HabitSection from '@/components/habits/HabitSection';
import { useHabitStore } from '@/stores/habitStore';
import { Section, SECTION_CONFIG } from '@/lib/types';

export default function HabitsPage() {
  const { habits, selectedDate, completions } = useHabitStore();
  const activeHabits = habits.filter(h => !h.archived);
  const sections = Object.keys(SECTION_CONFIG) as Section[];

  const todayCompletions = completions.filter(c => c.date === selectedDate && c.completed).length;
  const totalToday = activeHabits.length;

  return (
    <PageShell>
      <TerminalHeader command="habits.today()" />
      <DateNav />

      {/* Overall progress */}
      <div className="px-4 py-2 flex items-center justify-between border-b border-border-primary">
        <span className="text-[11px] text-text-secondary">
          progress: {todayCompletions}/{totalToday}
        </span>
        <div className="flex-1 mx-3 h-[3px] bg-border-primary rounded-[2px] overflow-hidden">
          <div
            className="h-full bg-accent-green rounded-[2px] transition-all duration-300"
            style={{ width: `${totalToday > 0 ? (todayCompletions / totalToday) * 100 : 0}%` }}
          />
        </div>
        <span className="text-[11px] text-accent-green">
          {totalToday > 0 ? Math.round((todayCompletions / totalToday) * 100) : 0}%
        </span>
      </div>

      {/* Habit sections */}
      {sections.map(section => {
        const sectionHabits = activeHabits.filter(h => h.section === section);
        if (sectionHabits.length === 0) return null;
        return <HabitSection key={section} section={section} habits={sectionHabits} />;
      })}

      {activeHabits.length === 0 && (
        <div className="px-4 py-12 text-center">
          <p className="text-[12px] text-text-tertiary">
            no habits found. run <span className="text-accent-green">`add --habit`</span> to begin.
          </p>
        </div>
      )}
    </PageShell>
  );
}
