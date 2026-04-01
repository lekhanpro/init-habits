'use client';

import PageShell from '@/components/layout/PageShell';
import TerminalHeader from '@/components/layout/TerminalHeader';
import { useHabitStore } from '@/stores/habitStore';
import { Settings, Download, Upload, Moon, Zap, BookOpen, Dumbbell, Coffee, Shield, Minimize2, Target } from 'lucide-react';

const modes = [
  { id: 'standard', label: 'Standard', icon: Target, color: '#00FF9F', active: true },
  { id: 'minimal', label: 'Minimal', icon: Minimize2, color: '#6B6B80' },
  { id: 'focus', label: 'Focus', icon: Zap, color: '#FFB800' },
  { id: 'deep_work', label: 'Deep Work', icon: Coffee, color: '#00B4FF' },
  { id: 'study', label: 'Study', icon: BookOpen, color: '#A855F7' },
  { id: 'fitness', label: 'Fitness', icon: Dumbbell, color: '#FF6B2C' },
  { id: 'monk', label: 'Monk', icon: Shield, color: '#22D3EE' },
  { id: 'detox', label: 'Detox', icon: Moon, color: '#FF4444' },
];

export default function ProfilePage() {
  const { habits, completions } = useHabitStore();
  const totalCompletions = completions.filter(c => c.completed).length;

  return (
    <PageShell>
      <TerminalHeader command="user.profile()" showDate={false} />

      {/* User info */}
      <div className="px-4 py-4 border-b border-border-primary">
        <div className="text-[10px] text-text-tertiary mb-1">// user session</div>
        <div className="text-[14px] text-accent-green font-medium">user@init.habits</div>
        <div className="text-[11px] text-text-secondary mt-1">
          {habits.filter(h => !h.archived).length} active habits · {totalCompletions} total completions
        </div>
      </div>

      {/* Mode selector */}
      <div className="px-4 py-3 border-b border-border-primary">
        <div className="text-[11px] text-text-secondary mb-3 flex items-center gap-1.5">
          <span className="text-accent-green">$</span> mode.select()
        </div>
        <div className="grid grid-cols-4 gap-2">
          {modes.map(mode => {
            const Icon = mode.icon;
            return (
              <button
                key={mode.id}
                className="flex flex-col items-center gap-1.5 py-2.5 px-1 rounded-[4px] border transition-colors"
                style={{
                  borderColor: mode.active ? mode.color + '40' : '#1E1E2E',
                  backgroundColor: mode.active ? mode.color + '08' : 'transparent',
                }}
              >
                <Icon size={16} strokeWidth={1.5} style={{ color: mode.active ? mode.color : '#4A4A5A' }} />
                <span className="text-[9px]" style={{ color: mode.active ? mode.color : '#4A4A5A' }}>
                  {mode.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Settings links */}
      <div className="px-4 py-3">
        <div className="text-[11px] text-text-secondary mb-3 flex items-center gap-1.5">
          <span className="text-accent-green">$</span> config.options()
        </div>
        {[
          { icon: Settings, label: 'Settings', desc: 'app preferences' },
          { icon: Download, label: 'Export Data', desc: 'download as JSON' },
          { icon: Upload, label: 'Import Data', desc: 'restore from backup' },
        ].map(item => (
          <button
            key={item.label}
            className="flex items-center gap-3 w-full py-2.5 border-b border-border-primary hover:bg-bg-tertiary/30 transition-colors"
          >
            <item.icon size={14} strokeWidth={1.5} className="text-text-tertiary" />
            <div className="text-left">
              <div className="text-[12px] text-text-primary">{item.label}</div>
              <div className="text-[10px] text-text-tertiary">{item.desc}</div>
            </div>
          </button>
        ))}
      </div>

      {/* Version info */}
      <div className="px-4 py-4 text-center">
        <div className="text-[10px] text-text-tertiary">init.habits v1.0.0</div>
        <div className="text-[9px] text-text-tertiary mt-0.5">built with discipline</div>
      </div>
    </PageShell>
  );
}
