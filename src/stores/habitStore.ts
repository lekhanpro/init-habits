import { create } from 'zustand';
import { format } from 'date-fns';
import { Habit, Completion, Mode } from '@/lib/types';
import { mockHabits, mockCompletions } from '@/data/mockHabits';
import { getModeConfig } from '@/lib/modes';

interface HabitState {
  habits: Habit[];
  completions: Completion[];
  selectedDate: string;
  activeMode: Mode;
  isDemo: boolean;
  hasBooted: boolean;

  setSelectedDate: (date: string) => void;
  toggleCompletion: (habitId: string, date: string) => void;
  getCompletionsForDate: (date: string) => Completion[];
  getCompletionForHabit: (habitId: string, date: string) => Completion | undefined;
  getStreakForHabit: (habitId: string) => number;
  addHabit: (habit: Habit) => void;
  deleteHabit: (id: string) => void;
  setMode: (mode: Mode) => void;
  freshStart: (mode: Mode) => void;
  resetToDemo: () => void;
}

function habitsFromMode(mode: Mode): Habit[] {
  const config = getModeConfig(mode);
  const now = new Date().toISOString();
  return config.presetHabits.map((h, i) => ({
    ...h,
    id: `${mode}-${i}-${Date.now()}`,
    createdAt: now,
    updatedAt: now,
  }));
}

export const useHabitStore = create<HabitState>((set, get) => ({
  habits: mockHabits,
  completions: mockCompletions,
  selectedDate: format(new Date(), 'yyyy-MM-dd'),
  activeMode: 'standard' as Mode,
  isDemo: true,
  hasBooted: true,

  setSelectedDate: (date) => set({ selectedDate: date }),

  toggleCompletion: (habitId, date) => {
    const { completions } = get();
    const existing = completions.find(c => c.habitId === habitId && c.date === date);
    if (existing) {
      set({ completions: completions.filter(c => c.id !== existing.id) });
    } else {
      set({
        completions: [...completions, {
          id: `c-${habitId}-${date}-${Date.now()}`,
          habitId,
          date,
          completed: true,
          createdAt: new Date().toISOString(),
        }],
      });
    }
  },

  getCompletionsForDate: (date) => get().completions.filter(c => c.date === date && c.completed),

  getCompletionForHabit: (habitId, date) =>
    get().completions.find(c => c.habitId === habitId && c.date === date && c.completed),

  getStreakForHabit: (habitId) => {
    const { completions } = get();
    let streak = 0;
    const today = new Date();
    for (let i = 0; i < 365; i++) {
      const date = format(new Date(today.getTime() - i * 86400000), 'yyyy-MM-dd');
      const found = completions.find(c => c.habitId === habitId && c.date === date && c.completed);
      if (found) streak++;
      else break;
    }
    return streak;
  },

  addHabit: (habit) => set(s => ({ habits: [...s.habits, habit] })),
  deleteHabit: (id) => set(s => ({ habits: s.habits.filter(h => h.id !== id) })),

  setMode: (mode) => set({ activeMode: mode }),

  freshStart: (mode) => {
    set({
      habits: habitsFromMode(mode),
      completions: [],
      activeMode: mode,
      isDemo: false,
      selectedDate: format(new Date(), 'yyyy-MM-dd'),
    });
  },

  resetToDemo: () => {
    set({
      habits: mockHabits,
      completions: mockCompletions,
      activeMode: 'standard' as Mode,
      isDemo: true,
      selectedDate: format(new Date(), 'yyyy-MM-dd'),
    });
  },
}));
