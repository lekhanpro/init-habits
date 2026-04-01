'use client';

import PageShell from '@/components/layout/PageShell';
import TerminalHeader from '@/components/layout/TerminalHeader';
import StatsGrid from '@/components/stats/StatsGrid';
import ContributionHeatmap from '@/components/stats/ContributionHeatmap';
import WeekdayBars from '@/components/stats/WeekdayBars';

export default function StatsPage() {
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

      {/* Category breakdown */}
      <div className="border-t border-border-primary px-4 py-3">
        <div className="text-[11px] text-text-secondary mb-3 flex items-center gap-1.5">
          <span className="text-accent-green">$</span> category.breakdown()
        </div>
        {[
          { label: 'morning', color: '#FFB800', pct: 72 },
          { label: 'deep_work', color: '#00B4FF', pct: 65 },
          { label: 'wind_down', color: '#A855F7', pct: 58 },
        ].map(cat => (
          <div key={cat.label} className="flex items-center gap-3 mb-2">
            <span className="text-[11px] text-text-tertiary w-20">{cat.label}</span>
            <div className="flex-1 h-[4px] bg-border-primary rounded-[2px] overflow-hidden">
              <div
                className="h-full rounded-[2px]"
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
