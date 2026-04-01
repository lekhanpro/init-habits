export type HabitType = 'boolean' | 'count' | 'timer' | 'negative';
export type Section = 'morning' | 'deep_work' | 'wind_down' | 'custom';
export type Mode = 'standard' | 'minimal' | 'focus' | 'deep_work' | 'study' | 'fitness' | 'monk' | 'detox' | 'recovery' | 'custom';

export interface Habit {
  id: string;
  name: string;
  type: HabitType;
  section: Section;
  color: string;
  icon?: string;
  targetCount?: number;
  targetMinutes?: number;
  schedule: number[];
  order: number;
  archived: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Completion {
  id: string;
  habitId: string;
  date: string;
  completed: boolean;
  value?: number;
  note?: string;
  createdAt: string;
}

export interface DayStats {
  date: string;
  total: number;
  completed: number;
  rate: number;
}

export interface ModeConfig {
  id: Mode;
  label: string;
  description: string;
  command: string;
  color: string;
  visibleSections: Section[];
  presetHabits: Omit<Habit, 'id' | 'createdAt' | 'updatedAt'>[];
}

export const SECTION_CONFIG: Record<Section, { label: string; command: string; color: string }> = {
  morning: { label: 'Morning Routine', command: 'morning.init()', color: '#FFB800' },
  deep_work: { label: 'Deep Work', command: 'deepwork.start()', color: '#00B4FF' },
  wind_down: { label: 'Wind Down', command: 'winddown.exec()', color: '#A855F7' },
  custom: { label: 'Custom', command: 'custom.run()', color: '#22D3EE' },
};
