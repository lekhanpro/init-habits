'use client';

import { Habit } from '@/lib/types';
import { useHabitStore } from '@/stores/habitStore';
import HabitCheckbox from './HabitCheckbox';
import StreakChip from './StreakChip';
import { Timer, Hash, ShieldOff } from 'lucide-react';

interface Props {
  habit: Habit;
}

export default function HabitRow({ habit }: Props) {
  const { selectedDate, toggleCompletion, getCompletionForHabit, getStreakForHabit } = useHabitStore();
  const completion = getCompletionForHabit(habit.id, selectedDate);
  const isCompleted = !!completion;
  const streak = getStreakForHabit(habit.id);

  const TypeIcon = habit.type === 'timer' ? Timer : habit.type === 'count' ? Hash : habit.type === 'negative' ? ShieldOff : null;

  return (
    <div
      className="flex items-center gap-3 px-4 py-2.5 border-b border-border-primary hover:bg-bg-tertiary/30 transition-colors duration-100 cursor-pointer"
    >
      <HabitCheckbox
        checked={isCompleted}
        color={habit.color}
        isNegative={habit.type === 'negative'}
        onToggle={() => toggleCompletion(habit.id, selectedDate)}
      />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span
            className={`text-[13px] truncate transition-all duration-150 ${
              isCompleted ? 'line-through text-text-tertiary' : 'text-text-primary'
            }`}
          >
            {habit.name}
          </span>
          <StreakChip count={streak} />
        </div>
      </div>
      <div className="flex items-center gap-1.5 text-text-tertiary">
        {TypeIcon && <TypeIcon size={12} strokeWidth={1.5} />}
        {habit.type === 'timer' && habit.targetMinutes && (
          <span className="text-[10px]">{habit.targetMinutes}m</span>
        )}
        {habit.type === 'count' && habit.targetCount && (
          <span className="text-[10px]">/{habit.targetCount}</span>
        )}
      </div>
    </div>
  );
}
