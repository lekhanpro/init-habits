import { Habit, Completion } from '@/lib/types';
import { format, subDays } from 'date-fns';

export const mockHabits: Habit[] = [
  // Morning
  { id: '1', name: 'Wake up at 6:00 AM', type: 'boolean', section: 'morning', color: '#FFB800', order: 0, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '2', name: 'Cold shower', type: 'boolean', section: 'morning', color: '#FFB800', order: 1, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '3', name: 'Meditate', type: 'timer', section: 'morning', color: '#FFB800', targetMinutes: 15, order: 2, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '4', name: 'Journal', type: 'boolean', section: 'morning', color: '#FFB800', order: 3, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '5', name: 'Read 20 pages', type: 'count', section: 'morning', color: '#FFB800', targetCount: 20, order: 4, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  // Deep Work
  { id: '6', name: 'Code 2 hours', type: 'timer', section: 'deep_work', color: '#00B4FF', targetMinutes: 120, order: 0, schedule: [1,2,3,4,5], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '7', name: 'Ship 1 feature', type: 'boolean', section: 'deep_work', color: '#00B4FF', order: 1, schedule: [1,2,3,4,5], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '8', name: 'Review PRs', type: 'boolean', section: 'deep_work', color: '#00B4FF', order: 2, schedule: [1,2,3,4,5], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '9', name: 'Learn something new', type: 'boolean', section: 'deep_work', color: '#00B4FF', order: 3, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  // Wind Down
  { id: '10', name: 'No screens after 10 PM', type: 'negative', section: 'wind_down', color: '#A855F7', order: 0, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '11', name: 'Stretch / Yoga', type: 'boolean', section: 'wind_down', color: '#A855F7', order: 1, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '12', name: 'Plan tomorrow', type: 'boolean', section: 'wind_down', color: '#A855F7', order: 2, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
  { id: '13', name: 'Gratitude log', type: 'boolean', section: 'wind_down', color: '#A855F7', order: 3, schedule: [], archived: false, createdAt: '2025-01-01', updatedAt: '2025-01-01' },
];

function generateCompletions(): Completion[] {
  const completions: Completion[] = [];
  const today = new Date();
  for (let d = 0; d < 90; d++) {
    const date = format(subDays(today, d), 'yyyy-MM-dd');
    for (const habit of mockHabits) {
      const rand = Math.random();
      const threshold = d < 7 ? 0.75 : d < 30 ? 0.65 : 0.5;
      if (rand < threshold) {
        completions.push({
          id: `c-${habit.id}-${date}`,
          habitId: habit.id,
          date,
          completed: true,
          value: habit.type === 'count' ? Math.floor(Math.random() * (habit.targetCount || 10)) + 1 : undefined,
          createdAt: date,
        });
      }
    }
  }
  return completions;
}

export const mockCompletions = generateCompletions();
