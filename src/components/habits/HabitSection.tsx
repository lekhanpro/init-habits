'use client';

import { Habit, Section, SECTION_CONFIG } from '@/lib/types';
import { useHabitStore } from '@/stores/habitStore';
import HabitRow from './HabitRow';

interface Props {
  section: Section;
  habits: Habit[];
}

export default function HabitSection({ section, habits }: Props) {
  const { selectedDate, getCompletionForHabit } = useHabitStore();
  const config = SECTION_CONFIG[section];
  const completed = habits.filter(h => getCompletionForHabit(h.id, selectedDate)).length;

  return (
    <div>
      <div className="flex items-center justify-between px-4 pt-3 pb-2 border-t border-border-primary">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full" style={{ backgroundColor: config.color }} />
          <span className="text-[12px] font-medium" style={{ color: config.color }}>
            {config.label}
          </span>
          <span className="text-[10px] text-text-tertiary">
            {config.command}
          </span>
        </div>
        <span className="text-[11px] text-text-tertiary">
          {completed}/{habits.length}
        </span>
      </div>
      {/* Section progress bar */}
      <div className="mx-4 mb-2 h-[3px] bg-border-primary rounded-[2px] overflow-hidden">
        <div
          className="h-full rounded-[2px] transition-all duration-300"
          style={{
            width: `${habits.length > 0 ? (completed / habits.length) * 100 : 0}%`,
            backgroundColor: config.color,
          }}
        />
      </div>
      <div>
        {habits.map(habit => (
          <HabitRow key={habit.id} habit={habit} />
        ))}
      </div>
    </div>
  );
}
