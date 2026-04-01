'use client';

import { useState } from 'react';
import PageShell from '@/components/layout/PageShell';
import TerminalHeader from '@/components/layout/TerminalHeader';
import { useHabitStore } from '@/stores/habitStore';
import { MODE_CONFIGS } from '@/lib/modes';
import { Mode } from '@/lib/types';
import { Settings, Download, Upload, Moon, Zap, BookOpen, Dumbbell, Coffee, Shield, Minimize2, Target, Heart, RotateCcw, Trash2, Palette } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const MODE_ICONS: Record<string, React.ElementType> = {
  standard: Target,
  minimal: Minimize2,
  focus: Zap,
  deep_work: Coffee,
  study: BookOpen,
  fitness: Dumbbell,
  monk: Shield,
  detox: Moon,
  recovery: Heart,
  custom: Palette,
};

export default function ProfilePage() {
  const { habits, completions, activeMode, freshStart, resetToDemo, isDemo } = useHabitStore();
  const [showConfirm, setShowConfirm] = useState<Mode | null>(null);
  const [showResetConfirm, setShowResetConfirm] = useState(false);
  const totalCompletions = completions.filter(c => c.completed).length;

  const handleModeSelect = (mode: Mode) => {
    if (mode === activeMode && !isDemo) return;
    setShowConfirm(mode);
  };

  const confirmFreshStart = () => {
    if (!showConfirm) return;
    freshStart(showConfirm);
    setShowConfirm(null);
  };

  const handleExport = () => {
    const data = JSON.stringify({ habits, completions, activeMode, exportedAt: new Date().toISOString() }, null, 2);
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `init-habits-backup-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleImport = () => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (ev) => {
        try {
          const data = JSON.parse(ev.target?.result as string);
          if (data.habits && data.completions) {
            useHabitStore.setState({
              habits: data.habits,
              completions: data.completions,
              activeMode: data.activeMode || 'standard',
              isDemo: false,
            });
          }
        } catch { /* ignore invalid JSON */ }
      };
      reader.readAsText(file);
    };
    input.click();
  };

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
        <div className="flex items-center gap-2 mt-1.5">
          <span className="text-[10px] px-1.5 py-0.5 rounded-[2px]"
            style={{ backgroundColor: MODE_CONFIGS.find(m => m.id === activeMode)?.color + '15', color: MODE_CONFIGS.find(m => m.id === activeMode)?.color }}>
            {activeMode} mode
          </span>
          {isDemo && (
            <span className="text-[10px] px-1.5 py-0.5 rounded-[2px] bg-accent-orange/15 text-accent-orange">
              demo data
            </span>
          )}
        </div>
      </div>

      {/* Mode selector */}
      <div className="px-4 py-3 border-b border-border-primary">
        <div className="text-[11px] text-text-secondary mb-1 flex items-center gap-1.5">
          <span className="text-accent-green">$</span> mode.select()
        </div>
        <div className="text-[10px] text-text-tertiary mb-3">
          select a mode to fresh start with preset habits
        </div>
        <div className="grid grid-cols-2 gap-2">
          {MODE_CONFIGS.map(mode => {
            const Icon = MODE_ICONS[mode.id] || Target;
            const isActive = mode.id === activeMode && !isDemo;
            return (
              <button
                key={mode.id}
                onClick={() => handleModeSelect(mode.id as Mode)}
                className="flex items-start gap-2.5 py-2.5 px-3 rounded-[4px] border transition-all duration-150 text-left"
                style={{
                  borderColor: isActive ? mode.color + '40' : '#1E1E2E',
                  backgroundColor: isActive ? mode.color + '08' : 'transparent',
                }}
              >
                <Icon size={14} strokeWidth={1.5} className="mt-0.5 flex-shrink-0" style={{ color: isActive ? mode.color : '#4A4A5A' }} />
                <div className="min-w-0">
                  <div className="text-[11px] font-medium" style={{ color: isActive ? mode.color : '#6B6B80' }}>
                    {mode.label}
                  </div>
                  <div className="text-[9px] text-text-tertiary mt-0.5 leading-tight">
                    {mode.description}
                  </div>
                  <div className="text-[9px] mt-1" style={{ color: mode.color + '80' }}>
                    {mode.presetHabits.length} habits
                  </div>
                </div>
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

        <button onClick={handleExport}
          className="flex items-center gap-3 w-full py-2.5 border-b border-border-primary hover:bg-bg-tertiary/30 transition-colors">
          <Download size={14} strokeWidth={1.5} className="text-text-tertiary" />
          <div className="text-left">
            <div className="text-[12px] text-text-primary">Export Data</div>
            <div className="text-[10px] text-text-tertiary">download habits + completions as JSON</div>
          </div>
        </button>

        <button onClick={handleImport}
          className="flex items-center gap-3 w-full py-2.5 border-b border-border-primary hover:bg-bg-tertiary/30 transition-colors">
          <Upload size={14} strokeWidth={1.5} className="text-text-tertiary" />
          <div className="text-left">
            <div className="text-[12px] text-text-primary">Import Data</div>
            <div className="text-[10px] text-text-tertiary">restore from JSON backup</div>
          </div>
        </button>

        {isDemo && (
          <button onClick={() => setShowConfirm('standard')}
            className="flex items-center gap-3 w-full py-2.5 border-b border-border-primary hover:bg-bg-tertiary/30 transition-colors">
            <RotateCcw size={14} strokeWidth={1.5} className="text-accent-green" />
            <div className="text-left">
              <div className="text-[12px] text-accent-green">Fresh Start</div>
              <div className="text-[10px] text-text-tertiary">clear demo data & start for real</div>
            </div>
          </button>
        )}

        {!isDemo && (
          <button onClick={() => setShowResetConfirm(true)}
            className="flex items-center gap-3 w-full py-2.5 border-b border-border-primary hover:bg-bg-tertiary/30 transition-colors">
            <Trash2 size={14} strokeWidth={1.5} className="text-accent-red" />
            <div className="text-left">
              <div className="text-[12px] text-accent-red">Reset All Data</div>
              <div className="text-[10px] text-text-tertiary">delete everything and reload demo</div>
            </div>
          </button>
        )}
      </div>

      {/* Version info */}
      <div className="px-4 py-4 text-center">
        <div className="text-[10px] text-text-tertiary">init.habits v1.1.0</div>
        <div className="text-[9px] text-text-tertiary mt-0.5">built with discipline</div>
      </div>

      {/* Fresh Start Confirmation Modal */}
      <AnimatePresence>
        {showConfirm && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.15 }}
            className="fixed inset-0 z-[100] flex items-end justify-center bg-black/60"
            onClick={() => setShowConfirm(null)}
          >
            <motion.div
              initial={{ y: 100 }}
              animate={{ y: 0 }}
              exit={{ y: 100 }}
              transition={{ duration: 0.2 }}
              onClick={e => e.stopPropagation()}
              className="w-full max-w-[480px] bg-bg-secondary border-t border-border-primary p-4 pb-8"
            >
              <div className="text-[11px] text-text-tertiary mb-1">// confirm fresh start</div>
              <div className="text-[14px] text-text-primary font-medium mb-1">
                Switch to <span style={{ color: MODE_CONFIGS.find(m => m.id === showConfirm)?.color }}>
                  {MODE_CONFIGS.find(m => m.id === showConfirm)?.label}
                </span> mode?
              </div>
              <div className="text-[11px] text-text-secondary mb-4">
                This will <span className="text-accent-red">clear all current habits and completions</span> and load {MODE_CONFIGS.find(m => m.id === showConfirm)?.presetHabits.length || 0} preset habits for this mode.
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setShowConfirm(null)}
                  className="flex-1 py-2.5 text-[12px] rounded-[4px] border border-border-primary text-text-secondary hover:bg-bg-tertiary/30 transition-colors"
                >
                  cancel
                </button>
                <button
                  onClick={confirmFreshStart}
                  className="flex-1 py-2.5 text-[12px] rounded-[4px] font-medium transition-colors"
                  style={{
                    backgroundColor: MODE_CONFIGS.find(m => m.id === showConfirm)?.color + '15',
                    color: MODE_CONFIGS.find(m => m.id === showConfirm)?.color,
                    border: `1px solid ${MODE_CONFIGS.find(m => m.id === showConfirm)?.color}30`,
                  }}
                >
                  $ mode.switch --confirm
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Reset Confirmation Modal */}
      <AnimatePresence>
        {showResetConfirm && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.15 }}
            className="fixed inset-0 z-[100] flex items-end justify-center bg-black/60"
            onClick={() => setShowResetConfirm(false)}
          >
            <motion.div
              initial={{ y: 100 }}
              animate={{ y: 0 }}
              exit={{ y: 100 }}
              transition={{ duration: 0.2 }}
              onClick={e => e.stopPropagation()}
              className="w-full max-w-[480px] bg-bg-secondary border-t border-border-primary p-4 pb-8"
            >
              <div className="text-[11px] text-text-tertiary mb-1">// confirm reset</div>
              <div className="text-[14px] text-accent-red font-medium mb-1">Reset all data?</div>
              <div className="text-[11px] text-text-secondary mb-4">
                This will delete all habits and completions and reload the demo data.
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setShowResetConfirm(false)}
                  className="flex-1 py-2.5 text-[12px] rounded-[4px] border border-border-primary text-text-secondary hover:bg-bg-tertiary/30 transition-colors"
                >
                  cancel
                </button>
                <button
                  onClick={() => { resetToDemo(); setShowResetConfirm(false); }}
                  className="flex-1 py-2.5 text-[12px] rounded-[4px] bg-accent-red/15 text-accent-red border border-accent-red/30 font-medium transition-colors"
                >
                  $ reset --hard
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </PageShell>
  );
}
