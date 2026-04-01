'use client';

import BottomNav from './BottomNav';

export default function PageShell({ children }: { children: React.ReactNode }) {
  return (
    <>
      <main className="flex-1 overflow-y-auto pb-16">
        {children}
      </main>
      <BottomNav />
    </>
  );
}
