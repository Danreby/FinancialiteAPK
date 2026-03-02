export function formatCurrency(value: number | string): string {
  const num = typeof value === 'string' ? parseFloat(value) : value;
  if (isNaN(num)) return 'R$ 0,00';
  return num.toLocaleString('pt-BR', {
    style: 'currency',
    currency: 'BRL',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

export function formatNumber(value: number): string {
  return value.toLocaleString('pt-BR');
}

export function formatPercentage(value: number, decimals = 1): string {
  return `${value.toFixed(decimals)}%`;
}

export function parseCurrency(text: string): number {
  const cleaned = text
    .replace(/[R$\s]/g, '')
    .replace(/\./g, '')
    .replace(',', '.');
  const num = parseFloat(cleaned);
  return isNaN(num) ? 0 : num;
}

export function abbreviateNumber(value: number): string {
  if (value >= 1_000_000) return `${(value / 1_000_000).toFixed(1)}M`;
  if (value >= 1_000) return `${(value / 1_000).toFixed(1)}K`;
  return formatCurrency(value);
}

export function getTransactionTypeLabel(type: string): string {
  return type === 'credit' ? 'Receita' : 'Despesa';
}

export function getStatusLabel(status: string): string {
  switch (status) {
    case 'paid': return 'Pago';
    case 'unpaid': return 'Pendente';
    case 'overdue': return 'Atrasado';
    case 'active': return 'Ativa';
    case 'inactive': return 'Inativa';
    case 'completed': return 'Concluída';
    default: return status;
  }
}

export function getIncomeTypeLabel(type: string): string {
  const labels: Record<string, string> = {
    salary: 'Salário',
    freelance: 'Freelance',
    investment: 'Investimento',
    rental: 'Aluguel',
    benefit: 'Benefício',
    other: 'Outro',
    pix: 'Pix',
  };
  return labels[type] ?? type;
}

export function getRecurrenceLabel(type: string): string {
  const labels: Record<string, string> = {
    monthly: 'Mensal',
    yearly: 'Anual',
    none: 'Única',
  };
  return labels[type] ?? type;
}
