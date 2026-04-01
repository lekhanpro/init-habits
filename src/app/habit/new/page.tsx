'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import PageShell from '@/components/layout/PageShell';
import TerminalHeader from '@/components/layout/TerminalHeader';
import { useHabitStore } from '@/stores/habitStore';
import { Section, HabitType, SECTION_CONFIG } from '@/lib/types';
import { ArrowLeft } from 'lucide-react';

export default function NewHabitPage() {
  const router = useRouter();
  const { addHabit, habits } = useHabitStore();
  const [name, setName] = useState('');
  const [type, setType] = useState<HabitType>('boolean');
  const [section, setSection] = useState<Section>('morning');

  const handleSubmit = () => {
    if (!name.trim()) return;
    addHabit({
      id: `h-${Date.now()}`,
      name: name.trim(),
      type,
      section,
      color: SECTION_CONFIG[section].color,
      order: habits.filter(h => h.section === section).length,
      schedule: [],
      archived: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });
    router.push('/');
  };

  return (
    <PageShell>
      <TerminalHeader command="habit.create()" showDate={false} />

      <div className="px-4 py-3 border-b border-border-primary flex items-center gap-3">
        <button onClick={() => router.back()} className="text-text-tertiary hover:text-text-secondary">
          <ArrowLeft size={16} />
        </button>
        <span className="text-[12px] text-text-secondary">new habit</span>
      </div>

      <div className="px-4 py-4 space-y-4">
        {/* Name */}
        <div>
          <label className="text-[10px] text-text-tertiary block mb-1">name</label>
          <input
            type="text"
            value={name}
            onChange={e => setName(e.target.value)}
            placeholder="e.g., Meditate 10 minutes"
            className="w-full bg-bg-input border border-border-primary rounded-[4px] px-3 py-2 text-[13px] text-text-primary placeholder:text-text-tertiary focus:border-accent-green/50 focus:outline-none transition-colors"
          />
        </div>

        {/* Type */}
        <div>
          <label className="text-[10px] text-text-tertiary block mb-1.5">type</label>
          <div className="grid grid-cols-4 gap-1.5">
            {(['boolean', 'count', 'timer', 'negative'] as HabitType[]).map(t => (
              <button
                key={t}
                onClick={() => setType(t)}
                className="py-2 text-[10px] rounded-[4px] border transition-colors"
                style={{
                  borderColor: type === t ? '#00FF9F40' : '#1E1E2E',
                  backgroundColor: type === t ? '#00FF9F08' : 'transparent',
                  color: type === t ? '#00FF9F' : '#4A4A5A',
                }}
              >
                {t}
              </button>
            ))}
          </div>
        </div>

        {/* Section */}
        <div>
          <label className="text-[10px] text-text-tertiary block mb-1.5">section</label>
          <div className="grid grid-cols-2 gap-1.5">
            {(Object.keys(SECTION_CONFIG) as Section[]).map(s => {
              const config = SECTION_CONFIG[s];
              return (
                <button
                  key={s}
                  onClick={() => setSection(s)}
                  className="flex items-center gap-2 py-2 px-3 text-[11px] rounded-[4px] border transition-colors"
                  style={{
                    borderColor: section === s ? config.color + '40' : '#1E1E2E',
                    backgroundColor: section === s ? config.color + '08' : 'transparent',
                    color: section === s ? config.color : '#4A4A5A',
                  }}
                >
                  <div className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: config.color }} />
                  {config.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Submit */}
        <button
          onClick={handleSubmit}
          disabled={!name.trim()}
          className="w-full py-2.5 text-[12px] font-medium rounded-[4px] bg-accent-green/10 text-accent-green border border-accent-green/20 hover:bg-accent-green/15 transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
        >
          $ create --habit &quot;{name || '...'}&quot;
        </button>
      </div>
    </PageShell>
  );
}
