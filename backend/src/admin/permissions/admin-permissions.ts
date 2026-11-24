/**
 * What an admin may do. Every admin API belongs to one module; an admin
 * either has full access, or a list of `<module>.view` / `<module>.manage`.
 * `manage` includes `view`. Reading (GET) needs view, anything that
 * changes data needs manage. Managing other admins is for full-access
 * admins only, and is not a grantable permission.
 */
export const ADMIN_MODULES = [
  'dashboard',
  'users',
  'lawyers',
  'companies',
  'consultations',
  'contracts',
  'contractTemplates',
  'govProcedures',
  'notifications',
  'audit',
] as const;
/** Metadata key the admin guard reads to find a route's module. */
export const ADMIN_MODULE_KEY = 'admin:module';

export type AdminModule = (typeof ADMIN_MODULES)[number];

export type AdminLevel = 'view' | 'manage';

/** Modules with nothing to change: only `view` makes sense. */
export const VIEW_ONLY_MODULES: readonly AdminModule[] = ['dashboard', 'audit'];

export const ALL_PERMISSIONS: readonly string[] = ADMIN_MODULES.flatMap(
  (module) =>
    VIEW_ONLY_MODULES.includes(module)
      ? [`${module}.view`]
      : [`${module}.view`, `${module}.manage`],
);

export interface AdminAccess {
  fullAccess: boolean;
  permissions: readonly string[];
}

/** GET / HEAD / OPTIONS read; everything else changes data. */
export function levelFor(method: string): AdminLevel {
  return ['GET', 'HEAD', 'OPTIONS'].includes(method.toUpperCase())
    ? 'view'
    : 'manage';
}

export function hasPermission(
  access: AdminAccess,
  module: AdminModule,
  level: AdminLevel,
): boolean {
  if (access.fullAccess) return true;
  if (access.permissions.includes(`${module}.manage`)) return true;
  return level === 'view' && access.permissions.includes(`${module}.view`);
}

/**
 * Cleans a submitted permission list: only known values, no repeats, and
 * `manage` always comes with `view`.
 */
export function normalizePermissions(input: readonly string[]): string[] {
  const wanted = new Set(input.filter((p) => ALL_PERMISSIONS.includes(p)));
  for (const p of [...wanted]) {
    if (p.endsWith('.manage')) wanted.add(p.replace('.manage', '.view'));
  }
  return ALL_PERMISSIONS.filter((p) => wanted.has(p));
}
