'use client';

import BottomNav from './BottomNav';
import AuthGuard from './AuthGuard';

export default function PageShell({ children }: { children: React.ReactNode }) {
  return (
    <AuthGuard>
      <main className="flex-1 overflow-y-auto pb-16">
        {children}
      </main>
      <BottomNav />
    </AuthGuard>
  );
}
