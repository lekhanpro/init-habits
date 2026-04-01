'use client';

import { motion } from 'framer-motion';
import { Check, X } from 'lucide-react';

interface Props {
  checked: boolean;
  color: string;
  isNegative?: boolean;
  onToggle: () => void;
}

export default function HabitCheckbox({ checked, color, isNegative, onToggle }: Props) {
  return (
    <button
      onClick={onToggle}
      className="relative flex-shrink-0 w-[18px] h-[18px] rounded-[2px] border transition-colors duration-150"
      style={{
        borderColor: checked ? color : '#2A2A3A',
        backgroundColor: checked ? color + '15' : 'transparent',
      }}
    >
      {checked && (
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.15 }}
          className="absolute inset-0 flex items-center justify-center"
        >
          {isNegative ? (
            <X size={12} strokeWidth={2.5} style={{ color }} />
          ) : (
            <Check size={12} strokeWidth={2.5} style={{ color }} />
          )}
        </motion.div>
      )}
    </button>
  );
}
