'use client';

import { format } from 'date-fns';

interface Props {
  command?: string;
  showDate?: boolean;
}

export default function TerminalHeader({ command = 'habits.today()', showDate = true }: Props) {
  const now = new Date();
  return (
    <div className="px-4 py-3 bg-bg-secondary border-b border-border-primary">
      <div className="flex items-center gap-1.5 text-[11px]">
        <span className="text-accent-green">user</span>
        <span className="text-text-tertiary">@</span>
        <span className="text-accent-cyan">init.habits</span>
        <span className="text-text-tertiary">:~$</span>
        <span className="text-text-secondary ml-1">{command}</span>
      </div>
      {showDate && (
        <div className="text-[10px] text-text-tertiary mt-1">
          {format(now, 'EEEE, MMMM d, yyyy')} — {format(now, 'HH:mm')}
        </div>
      )}
    </div>
  );
}
