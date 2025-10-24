// src/lib/roleHelper.js

/**
 * Get the effective role for the current user
 * If admin is impersonating, return impersonated role
 * Otherwise return actual user role
 */
export function getEffectiveRole(user, request) {
  // Only allow admins to impersonate
  if (user?.role !== 'admin') {
    return user?.role;
  }

  // Check for impersonation in session/cookies
  // You can adjust this based on how you store session data
  const impersonatedRole = request?.locals?.impersonatedRole;

  if (impersonatedRole) {
    return impersonatedRole;
  }

  return user?.role;
}

/**
 * Middleware to set impersonated role from sessionStorage
 * Add this to your hooks.server.js
 */
export function handleImpersonation({ event, resolve }) {
  // Get impersonated role from cookie or header
  const impersonatedRole = event.cookies.get('impersonatedRole');

  if (impersonatedRole && event.locals.user?.role === 'admin') {
    event.locals.impersonatedRole = impersonatedRole;
  }

  return resolve(event);
}

/**
 * Check if user has permission for an action
 * Respects impersonation for testing
 */
export function hasPermission(user, request, requiredRole) {
  const effectiveRole = getEffectiveRole(user, request);

  const roleHierarchy = {
    'admin': 3,
    'manager': 2,
    'billing': 1,
  };

  return roleHierarchy[effectiveRole] >= roleHierarchy[requiredRole];
}
