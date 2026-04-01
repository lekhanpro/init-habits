'use client';

import { useHabitStore } from '@/stores/habitStore';
import { format, addDays, subDays, isToday, parseISO } from 'date-fns';
import { ChevronLeft, ChevronRight } from 'lucide-react';

export default function DateNav() {
  const { selectedDate, setSelectedDate } = useHabitStore();
  const date = parseISO(selectedDate);
  const today = isToday(date);

  return (
    <div className="flex items-center justify-between px-4 py-2 bg-bg-secondary border-b border-border-primary">
      <button
        onClick={() => setSelectedDate(format(subDays(date, 1), 'yyyy-MM-dd'))}
        className="p-1 text-text-tertiary hover:text-text-secondary transition-colors"
      >
        <ChevronLeft size={16} />
      </button>
      <div className="flex items-center gap-2">
        <span className="text-[12px] text-text-primary font-medium">
          {format(date, 'EEE, MMM d')}
        </span>
        {today && (
          <span className="text-[9px] text-accent-green bg-accent-green/10 px-1.5 py-0.5 rounded-[2px]">
            TODAY
          </span>
        )}
      </div>
      <button
        onClick={() => setSelectedDate(format(addDays(date, 1), 'yyyy-MM-dd'))}
        className="p-1 text-text-tertiary hover:text-text-secondary transition-colors"
      >
        <ChevronRight size={16} />
      </button>
    </div>
  );
}
