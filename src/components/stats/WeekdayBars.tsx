'use client';

import { useHabitStore } from '@/stores/habitStore';
import { useMemo } from 'react';
import { getDay, parseISO } from 'date-fns';

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

export default function WeekdayBars() {
  const { completions, habits } = useHabitStore();

  const data = useMemo(() => {
    const counts = Array(7).fill(0);
    const totals = Array(7).fill(0);

    completions.forEach(c => {
      if (!c.completed) return;
      const d = getDay(parseISO(c.date));
      const idx = d === 0 ? 6 : d - 1; // Mon=0
      counts[idx]++;
    });

    // Simple: divide by ~13 weeks
    return DAYS.map((label, i) => ({
      label,
      value: Math.min(counts[i] / 13 / Math.max(habits.length, 1), 1),
    }));
  }, [completions, habits]);

  const maxVal = Math.max(...data.map(d => d.value), 0.01);

  return (
    <div className="px-4 py-3">
      <div className="text-[11px] text-text-secondary mb-3 flex items-center gap-1.5">
        <span className="text-accent-green">$</span> weekday.breakdown()
      </div>
      <div className="flex items-end justify-between gap-1.5 h-[80px]">
        {data.map((d, i) => (
          <div key={i} className="flex-1 flex flex-col items-center gap-1">
            <div className="w-full relative" style={{ height: 60 }}>
              <div className="absolute bottom-0 w-full bg-bg-tertiary rounded-[2px]" style={{ height: '100%' }} />
              <div
                className="absolute bottom-0 w-full rounded-[2px] transition-all duration-300"
                style={{
                  height: `${(d.value / maxVal) * 100}%`,
                  backgroundColor: '#00FF9F',
                  opacity: 0.8,
                }}
              />
            </div>
            <span className="text-[9px] text-text-tertiary">{d.label}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
