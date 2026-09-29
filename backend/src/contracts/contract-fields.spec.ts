import {
  buildContractContent,
  checkFieldValues,
  partiesOf,
} from './contract-fields';
import { findTemplate } from './contract-templates';

const employment = findTemplate('employment')!;

const complete = {
  partyA: ' Acme Co ',
  partyB: 'Sara Haddad',
  position: 'Engineer',
  employmentType: 'fullTime',
  salary: '1200.50',
  startDate: '2026-10-01T00:00:00.000',
  duration: '12',
};

describe('checkFieldValues', () => {
  it('accepts a complete, valid set and trims values', () => {
    const { values, errors } = checkFieldValues(employment, complete, {
      requireAll: true,
    });
    expect(errors).toEqual({});
    expect(values.partyA).toBe('Acme Co');
  });

  it('lets a draft leave required fields empty, but not generation', () => {
    const partial = { partyA: 'Acme Co', position: '' };
    expect(
      checkFieldValues(employment, partial, { requireAll: false }).errors,
    ).toEqual({});

    const { errors } = checkFieldValues(employment, partial, {
      requireAll: true,
    });
    expect(Object.keys(errors).sort()).toEqual(
      [
        'duration',
        'employmentType',
        'partyB',
        'position',
        'salary',
        'startDate',
      ].sort(),
    );
  });

  it('rejects unknown fields, non-text values and bad formats', () => {
    const { errors } = checkFieldValues(
      employment,
      {
        injected: 'x',
        partyA: 42,
        salary: '12,000',
        startDate: '2026-02-30',
        employmentType: 'دوام كامل',
        contactEmail: 'not-an-email',
        contactPhone: '12',
        position: 'x'.repeat(201),
      },
      { requireAll: false },
    );
    expect(Object.keys(errors).sort()).toEqual(
      [
        'contactEmail',
        'contactPhone',
        'employmentType',
        'injected',
        'partyA',
        'position',
        'salary',
        'startDate',
      ].sort(),
    );
  });
});

describe('buildContractContent', () => {
  it('writes labels and option labels in the requested language', () => {
    const { values } = checkFieldValues(employment, complete, {
      requireAll: true,
    });

    const ar = buildContractContent(employment, values, 'ar');
    expect(ar.split('\n')[0]).toBe('عقد عمل');
    expect(ar).toContain('نوع الدوام: دوام كامل');
    expect(ar).toContain('تاريخ بداية العمل: 2026-10-01');

    const en = buildContractContent(employment, values, 'en');
    expect(en).toContain('Employment Type: Full-time');
  });

  it('lists the two parties in order', () => {
    expect(partiesOf({ partyB: 'B', partyA: 'A' })).toEqual(['A', 'B']);
    expect(partiesOf({ partyA: 'A' })).toEqual(['A']);
  });
});
