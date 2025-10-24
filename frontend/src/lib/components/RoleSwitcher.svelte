<script>
  import { writable } from 'svelte/store';
  import { browser } from '$app/environment';

  // Props
  export let currentUser = null; // Your actual logged-in user

  // Available roles for testing
  const roles = [
    { id: 'admin', name: 'Admin (You)', color: 'bg-purple-600' },
    { id: 'billing', name: 'Billing (Mackenzie)', color: 'bg-blue-600' },
    { id: 'manager', name: 'Manager', color: 'bg-green-600' }
  ];

  // Get impersonated role from sessionStorage or use actual role
  let impersonatedRole = null;
  if (browser) {
    impersonatedRole = sessionStorage.getItem('impersonatedRole');
  }

  let isOpen = false;
  let activeRole = impersonatedRole || currentUser?.role || 'admin';

  // Switch to a different role
  function switchRole(roleId) {
    activeRole = roleId;
    if (browser) {
      if (roleId === currentUser?.role) {
        // Remove impersonation - back to real role
        sessionStorage.removeItem('impersonatedRole');
      } else {
        // Store impersonated role
        sessionStorage.setItem('impersonatedRole', roleId);
      }
    }
    isOpen = false;
    // Reload page to apply new role
    if (browser) {
      window.location.reload();
    }
  }

  // Get current role display info
  $: currentRoleInfo = roles.find(r => r.id === activeRole) || roles[0];

  // Only show if user is actually an admin
  $: showSwitcher = currentUser?.role === 'admin';
</script>

{#if showSwitcher}
  <div class="fixed top-4 right-4 z-50">
    <!-- Role Switcher Badge -->
    <button
      on:click={() => isOpen = !isOpen}
      class="flex items-center gap-2 px-4 py-2 rounded-lg shadow-lg text-white font-medium hover:opacity-90 transition-opacity {currentRoleInfo.color}"
    >
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
      </svg>
      <span>Testing as: {currentRoleInfo.name}</span>
      <svg
        class="w-4 h-4 transition-transform {isOpen ? 'rotate-180' : ''}"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    <!-- Dropdown Menu -->
    {#if isOpen}
      <div class="absolute right-0 mt-2 w-64 bg-white rounded-lg shadow-xl border border-gray-200 overflow-hidden">
        <div class="p-3 bg-gray-50 border-b border-gray-200">
          <p class="text-xs font-semibold text-gray-600 uppercase">Switch Role (Test Mode)</p>
        </div>

        <div class="p-2">
          {#each roles as role}
            <button
              on:click={() => switchRole(role.id)}
              class="w-full flex items-center gap-3 px-3 py-2 rounded-md hover:bg-gray-100 transition-colors text-left {activeRole === role.id ? 'bg-gray-100' : ''}"
            >
              <div class="w-3 h-3 rounded-full {role.color}"></div>
              <span class="text-sm font-medium text-gray-700">{role.name}</span>
              {#if activeRole === role.id}
                <svg class="w-4 h-4 ml-auto text-green-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                </svg>
              {/if}
            </button>
          {/each}
        </div>

        <div class="p-3 bg-yellow-50 border-t border-yellow-200">
          <p class="text-xs text-yellow-800">
            ⚠️ Testing mode only. Page will reload when switching roles.
          </p>
        </div>
      </div>
    {/if}
  </div>
{/if}

<style>
  /* Optional: Add backdrop when dropdown is open */
  :global(body:has(.role-switcher-open)) {
    /* Could add backdrop blur or dim effect */
  }
</style>
