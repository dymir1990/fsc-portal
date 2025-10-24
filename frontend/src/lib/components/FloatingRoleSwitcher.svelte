<script lang="ts">
  import { onMount } from 'svelte';
  import { browser } from '$app/environment';

  let isOpen = $state(false);
  let isDragging = $state(false);
  let dragOffset = $state({ x: 0, y: 0 });
  let position = $state({ x: 20, y: 20 }); // Bottom-right corner offset
  let currentRole = $state('admin');
  let currentUser = $state('You');

  // Role options
  const roles = [
    { id: 'admin', name: 'Admin', user: 'You' },
    { id: 'billing', name: 'Billing Staff', user: 'Mackenzie' },
    { id: 'manager', name: 'Manager', user: 'Samina' },
    { id: 'provider', name: 'Provider', user: 'Test Provider' }
  ];

  onMount(() => {
    if (browser) {
      // Load saved position from localStorage
      const savedPosition = localStorage.getItem('floatingRoleSwitcherPosition');
      if (savedPosition) {
        position = JSON.parse(savedPosition);
      }

      // Load current role from sessionStorage
      const savedRole = sessionStorage.getItem('impersonatedRole');
      if (savedRole) {
        currentRole = savedRole;
        const roleData = roles.find(r => r.id === savedRole);
        if (roleData) {
          currentUser = roleData.user;
        }
      }
    }
  });

  function toggleDropdown() {
    isOpen = !isOpen;
  }

  function selectRole(role: typeof roles[0]) {
    currentRole = role.id;
    currentUser = role.user;
    isOpen = false;

    // Save to sessionStorage
    if (browser) {
      sessionStorage.setItem('impersonatedRole', role.id);

      // Set cookie for backend
      document.cookie = `impersonatedRole=${role.id}; path=/; max-age=86400`;

      // Reload page to apply role changes
      window.location.reload();
    }
  }

  function startDrag(event: MouseEvent) {
    isDragging = true;
    dragOffset.x = event.clientX - position.x;
    dragOffset.y = event.clientY - position.y;

    document.addEventListener('mousemove', handleDrag);
    document.addEventListener('mouseup', stopDrag);
    event.preventDefault();
  }

  function handleDrag(event: MouseEvent) {
    if (!isDragging) return;

    position.x = event.clientX - dragOffset.x;
    position.y = event.clientY - dragOffset.y;

    // Keep within viewport bounds
    const maxX = window.innerWidth - 60; // Button width
    const maxY = window.innerHeight - 60; // Button height

    position.x = Math.max(0, Math.min(position.x, maxX));
    position.y = Math.max(0, Math.min(position.y, maxY));
  }

  function stopDrag() {
    isDragging = false;
    document.removeEventListener('mousemove', handleDrag);
    document.removeEventListener('mouseup', stopDrag);

    // Save position to localStorage
    if (browser) {
      localStorage.setItem('floatingRoleSwitcherPosition', JSON.stringify(position));
    }
  }

  function getRoleColor(roleId: string) {
    switch (roleId) {
      case 'admin': return 'bg-purple-500';
      case 'billing': return 'bg-blue-500';
      case 'manager': return 'bg-green-500';
      case 'provider': return 'bg-amber-500';
      default: return 'bg-slate-500';
    }
  }

  function getRoleIcon(roleId: string) {
    switch (roleId) {
      case 'admin': return '👑';
      case 'billing': return '💰';
      case 'manager': return '📊';
      case 'provider': return '👤';
      default: return '👤';
    }
  }
</script>

<!-- Floating Role Switcher -->
<div
  class="fixed z-50 transition-all duration-200 {isDragging ? 'scale-105' : 'hover:scale-105'}"
  style="right: {position.x}px; bottom: {position.y}px;"
>
  <!-- Main Button -->
  <button
    class="flex items-center gap-2 rounded-full bg-white shadow-lg border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:shadow-xl transition-all duration-200 cursor-move"
    onmousedown={startDrag}
    onclick={toggleDropdown}
    aria-label="Role Switcher"
  >
    <div class="flex items-center gap-2">
      <div class="w-6 h-6 rounded-full {getRoleColor(currentRole)} flex items-center justify-center text-white text-xs">
        {getRoleIcon(currentRole)}
      </div>
      <span class="hidden sm:inline">Testing as: {roles.find(r => r.id === currentRole)?.name}</span>
      <span class="sm:hidden">{roles.find(r => r.id === currentRole)?.name}</span>
    </div>
    <svg
      class="w-4 h-4 transition-transform duration-200 {isOpen ? 'rotate-180' : ''}"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
  </button>

  <!-- Dropdown Menu -->
  {#if isOpen}
    <div class="absolute bottom-full right-0 mb-2 w-64 bg-white rounded-xl shadow-xl border border-slate-200 overflow-hidden">
      <div class="p-3 bg-slate-50 border-b border-slate-200">
        <h3 class="text-sm font-semibold text-slate-700">Switch Role</h3>
        <p class="text-xs text-slate-500 mt-1">Test different user permissions</p>
      </div>

      <div class="py-2">
        {#each roles as role}
          <button
            class="w-full flex items-center gap-3 px-3 py-2 text-left hover:bg-slate-50 transition-colors {currentRole === role.id ? 'bg-purple-50 border-r-2 border-purple-500' : ''}"
            onclick={() => selectRole(role)}
          >
            <div class="w-8 h-8 rounded-full {getRoleColor(role.id)} flex items-center justify-center text-white text-sm">
              {getRoleIcon(role.id)}
            </div>
            <div class="flex-1">
              <div class="text-sm font-medium text-slate-700">{role.name}</div>
              <div class="text-xs text-slate-500">{role.user}</div>
            </div>
            {#if currentRole === role.id}
              <svg class="w-4 h-4 text-purple-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
              </svg>
            {/if}
          </button>
        {/each}
      </div>

      <div class="p-3 bg-slate-50 border-t border-slate-200">
        <p class="text-xs text-slate-500">
          💡 Drag this button to move it around the screen
        </p>
      </div>
    </div>
  {/if}
</div>

<!-- Click outside to close -->
{#if isOpen}
  <button
    class="fixed inset-0 z-40"
    onclick={() => isOpen = false}
    onkeydown={(e) => e.key === 'Escape' && (isOpen = false)}
    tabindex="-1"
    aria-label="Close role switcher"
  ></button>
{/if}

<style>
  /* Ensure the floating element stays above everything */
  .fixed {
    z-index: 9999;
  }
</style>
