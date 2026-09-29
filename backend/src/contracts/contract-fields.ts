import {
  PARTY_FIELD_IDS,
  type ContractFieldDefinition,
  type ContractFieldType,
  type ContractLocale,
  type ContractTemplateDefinition,
} from './contract-templates';

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
const PHONE_RE = /^\+?[0-9]{8,15}$/;
const NUMBER_RE = /^[0-9]{1,12}(\.[0-9]{1,4})?$/;
const CURRENCY_RE = /^[0-9]{1,12}(\.[0-9]{1,2})?$/;
/** A calendar date, optionally with a time (what the app's date picker sends). */
const DATE_RE =
  /^(\d{4})-(\d{2})-(\d{2})(T\d{2}:\d{2}(:\d{2}(\.\d{1,6})?)?(Z|[+-]\d{2}:\d{2})?)?$/;

const MAX_LENGTH: Record<ContractFieldType, number> = {
  text: 200,
  multiline: 2000,
  number: 17,
  currency: 15,
  date: 40,
  dropdown: 50,
  phone: 16,
  email: 254,
};

export type FieldValues = Record<string, string>;
export type FieldErrors = Record<string, string[]>;

export interface CheckedFieldValues {
  /** Trimmed values, empty ones dropped. */
  values: FieldValues;
  errors: FieldErrors;
}

/**
 * Checks submitted values against [template]: only its fields, strings
 * only, within length, and in each field's format. With [requireAll]
 * (generating, not saving a draft) every required field must be filled.
 */
export function checkFieldValues(
  template: ContractTemplateDefinition,
  submitted: Record<string, unknown>,
  { requireAll }: { requireAll: boolean },
): CheckedFieldValues {
  const values: FieldValues = {};
  const errors: FieldErrors = {};
  const fields = new Map(template.fields.map((field) => [field.id, field]));

  for (const [id, raw] of Object.entries(submitted)) {
    const field = fields.get(id);
    if (!field) {
      errors[id] = ['Unknown field.'];
      continue;
    }
    if (typeof raw !== 'string') {
      errors[id] = ['Must be text.'];
      continue;
    }
    const value = raw.trim();
    if (value.length === 0) continue;

    const problem = formatProblem(field, value);
    if (problem) {
      errors[id] = [problem];
    } else {
      values[id] = value;
    }
  }

  if (requireAll) {
    for (const field of template.fields) {
      if (field.isRequired && !(field.id in values) && !(field.id in errors)) {
        errors[field.id] = ['This field is required.'];
      }
    }
  }
  return { values, errors };
}

function formatProblem(
  field: ContractFieldDefinition,
  value: string,
): string | null {
  if (value.length > MAX_LENGTH[field.type]) return 'Too long.';
  switch (field.type) {
    case 'email':
      return EMAIL_RE.test(value) ? null : 'Enter a valid email address.';
    case 'phone':
      return PHONE_RE.test(value) ? null : 'Enter a valid phone number.';
    case 'number':
      return NUMBER_RE.test(value) ? null : 'Enter a number.';
    case 'currency':
      return CURRENCY_RE.test(value) ? null : 'Enter an amount.';
    case 'date':
      return isCalendarDate(value) ? null : 'Enter a valid date.';
    case 'dropdown':
      return field.options?.some((option) => option.value === value)
        ? null
        : 'Choose one of the options.';
    case 'text':
    case 'multiline':
      return null;
  }
}

function isCalendarDate(value: string): boolean {
  const match = DATE_RE.exec(value);
  if (!match) return false;
  const [year, month, day] = [match[1], match[2], match[3]].map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

/** The parties' names, in template order, for list views. */
export function partiesOf(values: FieldValues): string[] {
  return PARTY_FIELD_IDS.map((id) => values[id]).filter(
    (name): name is string => !!name,
  );
}

/**
 * The contract text: the title, then one "label: value" line per filled
 * field in template order. Built on the server from the template, so a
 * client cannot put text into a contract that the fields don't hold.
 */
export function buildContractContent(
  template: ContractTemplateDefinition,
  values: FieldValues,
  locale: ContractLocale,
): string {
  const lines = [template.title[locale], ''];
  for (const field of template.fields) {
    const value = values[field.id];
    if (!value) continue;
    lines.push(`${field.label[locale]}: ${displayValue(field, value, locale)}`);
  }
  return lines.join('\n').trim();
}

function displayValue(
  field: ContractFieldDefinition,
  value: string,
  locale: ContractLocale,
): string {
  if (field.type === 'dropdown') {
    const option = field.options?.find((o) => o.value === value);
    return option ? option.label[locale] : value;
  }
  if (field.type === 'date') return value.slice(0, 10);
  return value;
}
