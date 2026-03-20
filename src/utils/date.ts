import {
  format,
  parseISO,
  startOfMonth,
  endOfMonth,
  addMonths,
  subMonths,
  isAfter,
  isBefore,
  differenceInDays,
} from 'date-fns';
import { ptBR } from 'date-fns/locale';

export function formatDate(date: string | Date, pattern = 'dd/MM/yyyy'): string {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, pattern, { locale: ptBR });
}

export function formatMonthYear(date: string | Date): string {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, 'MMMM yyyy', { locale: ptBR });
}

export function formatShortMonth(date: string | Date): string {
  const d = typeof date === 'string' ? parseISO(date) : date;
  return format(d, 'MMM', { locale: ptBR });
}

export function getMonthKey(date: Date = new Date()): string {
  return format(date, 'yyyy-MM');
}

export function getMonthRange(monthKey: string) {
  const date = parseISO(`${monthKey}-01`);
  return {
    start: startOfMonth(date),
    end: endOfMonth(date),
  };
}

export function getNextMonth(monthKey: string): string {
  const date = parseISO(`${monthKey}-01`);
  return format(addMonths(date, 1), 'yyyy-MM');
}

export function getPrevMonth(monthKey: string): string {
  const date = parseISO(`${monthKey}-01`);
  return format(subMonths(date, 1), 'yyyy-MM');
}

export function isOverdue(dateStr: string): boolean {
  return isBefore(parseISO(dateStr), new Date());
}

export function isUpcoming(dateStr: string, days = 7): boolean {
  const target = parseISO(dateStr);
  const now = new Date();
  return isAfter(target, now) && differenceInDays(target, now) <= days;
}

export function daysUntil(dateStr: string): number {
  return differenceInDays(parseISO(dateStr), new Date());
}

export function toISODate(date: Date): string {
  return format(date, 'yyyy-MM-dd');
}

export { parseISO, addMonths, subMonths, startOfMonth, endOfMonth };
