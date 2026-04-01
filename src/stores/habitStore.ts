import { create } from 'zustand';
import { format } from 'date-fns';
import { Habit, Completion } from '@/lib/types';
import { mockHabits, mockCompletions } from '@/data/mockHabits';

interface HabitState {
  habits: Habit[];
  completions: Completion[];
  selectedDate: string;
  setSelectedDate: (date: string) => void;
  toggleCompletion: (habitId: string, date: string) => void;
  getCompletionsForDate: (date: string) => Completion[];
  getCompletionForHabit: (habitId: string, date: string) => Completion | undefined;
  getStreakForHabit: (habitId: string) => number;
  addHabit: (habit: Habit) => void;
  deleteHabit: (id: string) => void;
}

export const useHabitStore = create<HabitState>((set, get) => ({
  habits: mockHabits,
  completions: mockCompletions,
  selectedDate: format(new Date(), 'yyyy-MM-dd'),

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
}));
