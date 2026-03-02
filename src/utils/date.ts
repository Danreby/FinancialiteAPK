import { format, parseISO, isToday, isYesterday, differenceInDays, startOfMonth, endOfMonth } from 'date-fns';
import { ptBR } from 'date-fns/locale';

export function formatDate(date: string | Date, pattern = 'dd/MM/yyyy'): string {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, pattern, { locale: ptBR });
}

export function formatDateTime(date: string | Date): string {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR });
}

export function formatRelativeDate(date: string | Date): string {
  const d = typeof date === 'string' ? parseISO(date) : date;
  if (isToday(d)) return 'Hoje';
  if (isYesterday(d)) return 'Ontem';
  const days = differenceInDays(new Date(), d);
  if (days < 7) return `${days} dias atrás`;
  return formatDate(d);
}

export function formatMonthYear(monthKey: string | Date): string {
  if (monthKey instanceof Date) {
    return format(monthKey, 'MMMM yyyy', { locale: ptBR });
  }
  const [year, month] = monthKey.split('-');
  const date = new Date(parseInt(year), parseInt(month) - 1, 1);
  return format(date, 'MMMM yyyy', { locale: ptBR });
}

export function getCurrentMonthKey(): string {
  return format(new Date(), 'yyyy-MM');
}

export function getMonthRange(monthKey: string): { start: Date; end: Date } {
  const [year, month] = monthKey.split('-');
  const date = new Date(parseInt(year), parseInt(month) - 1, 1);
  return {
    start: startOfMonth(date),
    end: endOfMonth(date),
  };
}

export function getDaysUntil(day: number): number {
  const today = new Date();
  const targetDate = new Date(today.getFullYear(), today.getMonth(), day);
  if (targetDate < today) {
    targetDate.setMonth(targetDate.getMonth() + 1);
  }
  return differenceInDays(targetDate, today);
}
