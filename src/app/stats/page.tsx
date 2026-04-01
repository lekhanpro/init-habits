'use client';

import { useMemo } from 'react';
import PageShell from '@/components/layout/PageShell';
import TerminalHeader from '@/components/layout/TerminalHeader';
import StatsGrid from '@/components/stats/StatsGrid';
import ContributionHeatmap from '@/components/stats/ContributionHeatmap';
import WeekdayBars from '@/components/stats/WeekdayBars';
import { useHabitStore } from '@/stores/habitStore';
import { SECTION_CONFIG, Section } from '@/lib/types';
import { format, subDays } from 'date-fns';

export default function StatsPage() {
  const { habits, completions } = useHabitStore();

  const categoryBreakdown = useMemo(() => {
    const today = new Date();
    const sections = Object.keys(SECTION_CONFIG) as Section[];
    return sections.map(section => {
      const sectionHabits = habits.filter(h => h.section === section && !h.archived);
      if (sectionHabits.length === 0) return null;
      let completed = 0;
      let total = 0;
      for (let d = 0; d < 30; d++) {
        const date = format(subDays(today, d), 'yyyy-MM-dd');
        for (const h of sectionHabits) {
          total++;
          if (completions.find(c => c.habitId === h.id && c.date === date && c.completed)) {
            completed++;
          }
        }
      }
      return {
        label: section,
        color: SECTION_CONFIG[section].color,
        pct: total > 0 ? Math.round((completed / total) * 100) : 0,
      };
    }).filter(Boolean) as { label: string; color: string; pct: number }[];
  }, [habits, completions]);

  return (
    <PageShell>
      <TerminalHeader command="analytics.render()" showDate={false} />

      <div className="px-4 py-2 border-b border-border-primary">
        <span className="text-[11px] text-text-tertiary">
          // displaying analytics for last 90 days
        </span>
      </div>

      <StatsGrid />

      <div className="border-t border-border-primary">
        <ContributionHeatmap />
      </div>

      <div className="border-t border-border-primary">
        <WeekdayBars />
      </div>

      {/* Category breakdown — computed from real data */}
      <div className="border-t border-border-primary px-4 py-3">
        <div className="text-[11px] text-text-secondary mb-3 flex items-center gap-1.5">
          <span className="text-accent-green">$</span> category.breakdown()
        </div>
        {categoryBreakdown.length === 0 && (
          <div className="text-[11px] text-text-tertiary">no data yet</div>
        )}
        {categoryBreakdown.map(cat => (
          <div key={cat.label} className="flex items-center gap-3 mb-2">
            <span className="text-[11px] text-text-tertiary w-20">{cat.label}</span>
            <div className="flex-1 h-[4px] bg-border-primary rounded-[2px] overflow-hidden">
              <div
                className="h-full rounded-[2px] transition-all duration-300"
                style={{ width: `${cat.pct}%`, backgroundColor: cat.color }}
              />
            </div>
            <span className="text-[11px]" style={{ color: cat.color }}>{cat.pct}%</span>
          </div>
        ))}
      </div>
    </PageShell>
  );
}
