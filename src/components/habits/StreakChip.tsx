interface Props {
  count: number;
  color?: string;
}

export default function StreakChip({ count, color = '#FF6B2C' }: Props) {
  if (count < 2) return null;
  return (
    <span
      className="inline-flex items-center gap-0.5 text-[10px] px-1.5 py-0.5 rounded-[2px]"
      style={{ backgroundColor: color + '15', color }}
    >
      <span>🔥</span>
      <span>{count}</span>
    </span>
  );
}
