'use client';

import { useHabitStore } from '@/stores/habitStore';
import { format, subDays, startOfWeek, differenceInWeeks } from 'date-fns';
import { useMemo } from 'react';

const COLORS = ['#1A1A25', '#0D3320', '#166534', '#22C55E', '#00FF9F'];
const CELL_SIZE = 10;
const GAP = 2;
const WEEKS = 20;

export default function ContributionHeatmap() {
  const { habits, completions } = useHabitStore();
  const totalHabits = habits.filter(h => !h.archived).length;

  const data = useMemo(() => {
    const today = new Date();
    const cells: { date: string; level: number; x: number; y: number }[] = [];
    const startDate = startOfWeek(subDays(today, WEEKS * 7), { weekStartsOn: 1 });

    for (let w = 0; w < WEEKS; w++) {
      for (let d = 0; d < 7; d++) {
        const cellDate = new Date(startDate.getTime() + (w * 7 + d) * 86400000);
        const dateStr = format(cellDate, 'yyyy-MM-dd');
        const count = completions.filter(c => c.date === dateStr && c.completed).length;
        const ratio = totalHabits > 0 ? count / totalHabits : 0;
        const level = ratio === 0 ? 0 : ratio < 0.25 ? 1 : ratio < 0.5 ? 2 : ratio < 0.75 ? 3 : 4;
        cells.push({ date: dateStr, level, x: w, y: d });
      }
    }
    return cells;
  }, [completions, totalHabits]);

  const width = WEEKS * (CELL_SIZE + GAP);
  const height = 7 * (CELL_SIZE + GAP);

  return (
    <div className="px-4 py-3">
      <div className="text-[11px] text-text-secondary mb-2 flex items-center gap-1.5">
        <span className="text-accent-green">$</span> contribution.heatmap()
      </div>
      <div className="overflow-x-auto">
        <svg width={width} height={height} className="block">
          {data.map((cell, i) => (
            <rect
              key={i}
              x={cell.x * (CELL_SIZE + GAP)}
              y={cell.y * (CELL_SIZE + GAP)}
              width={CELL_SIZE}
              height={CELL_SIZE}
              rx={2}
              fill={COLORS[cell.level]}
            />
          ))}
        </svg>
      </div>
      <div className="flex items-center justify-end gap-1 mt-2">
        <span className="text-[9px] text-text-tertiary mr-1">less</span>
        {COLORS.map((c, i) => (
          <div key={i} className="w-[8px] h-[8px] rounded-[1px]" style={{ backgroundColor: c }} />
        ))}
        <span className="text-[9px] text-text-tertiary ml-1">more</span>
      </div>
    </div>
  );
}
