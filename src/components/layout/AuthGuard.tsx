'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/AuthContext';

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, loading, authEnabled } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!authEnabled || loading) return;
    if (!user) router.replace('/login');
  }, [user, loading, authEnabled, router]);

  if (!authEnabled) return <>{children}</>;
  if (loading) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <div className="text-[11px] text-text-tertiary animate-pulse">$ authenticating...</div>
      </div>
    );
  }
  if (!user) return null;
  return <>{children}</>;
}
