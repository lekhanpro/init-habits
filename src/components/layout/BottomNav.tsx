'use client';

import { usePathname, useRouter } from 'next/navigation';
import { LayoutGrid, BarChart3, User, Plus } from 'lucide-react';
import { motion } from 'framer-motion';

const tabs = [
  { path: '/', icon: LayoutGrid, label: 'habits' },
  { path: '/stats', icon: BarChart3, label: 'stats' },
  { path: '/habit/new', icon: Plus, label: 'add' },
  { path: '/profile', icon: User, label: 'profile' },
];

export default function BottomNav() {
  const pathname = usePathname();
  const router = useRouter();

  return (
    <nav className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[480px] bg-bg-secondary/95 backdrop-blur-sm border-t border-border-primary z-50">
      <div className="flex items-center justify-around h-14">
        {tabs.map((tab) => {
          const isActive = tab.path === '/' ? pathname === '/' : pathname.startsWith(tab.path);
          const Icon = tab.icon;
          return (
            <button
              key={tab.path}
              onClick={() => router.push(tab.path)}
              className="flex flex-col items-center gap-0.5 px-4 py-1.5 relative"
            >
              {isActive && (
                <motion.div
                  layoutId="nav-indicator"
                  className="absolute -top-px left-2 right-2 h-[2px] bg-accent-green"
                  transition={{ duration: 0.15 }}
                />
              )}
              <Icon
                size={18}
                strokeWidth={1.5}
                className={isActive ? 'text-accent-green' : 'text-text-tertiary'}
              />
              <span className={`text-[10px] ${isActive ? 'text-accent-green' : 'text-text-tertiary'}`}>
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
