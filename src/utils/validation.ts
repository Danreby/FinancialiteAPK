export function validateEmail(email: string): string | null {
  const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!email) return 'E-mail é obrigatório';
  if (!pattern.test(email)) return 'E-mail inválido';
  return null;
}

export function validatePassword(password: string): string | null {
  if (!password) return 'Senha é obrigatória';
  if (password.length < 8) return 'Senha deve ter no mínimo 8 caracteres';
  return null;
}

export function validateRequired(value: unknown, fieldName: string): string | null {
  if (value === undefined || value === null || value === '') {
    return `${fieldName} é obrigatório`;
  }
  return null;
}

export function validatePositiveNumber(value: number, fieldName: string): string | null {
  if (isNaN(value) || value <= 0) {
    return `${fieldName} deve ser um valor positivo`;
  }
  return null;
}

export function validateDayOfMonth(value: number): string | null {
  if (!Number.isInteger(value) || value < 1 || value > 31) {
    return 'Dia deve ser entre 1 e 31';
  }
  return null;
}

export function validateName(name: string, min = 2, max = 100): string | null {
  if (!name) return 'Nome é obrigatório';
  if (name.length < min) return `Nome deve ter no mínimo ${min} caracteres`;
  if (name.length > max) return `Nome deve ter no máximo ${max} caracteres`;
  return null;
}

export type ValidationErrors = Record<string, string | null>;

export function hasErrors(errors: ValidationErrors): boolean {
  return Object.values(errors).some((e) => e !== null);
}

export function getFirstError(errors: ValidationErrors): string | null {
  return Object.values(errors).find((e) => e !== null) ?? null;
}
