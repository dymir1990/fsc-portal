<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';

  let { title = 'Dashboard', isMobileMenuOpen = false } = $props<{ title?: string; isMobileMenuOpen?: boolean }>();

  let user = $state<any>(null);
  let showUserMenu = $state(false);

  onMount(async () => {
    const { data } = await supabase.auth.getUser();
    user = data.user;
  });

  async function handleLogout() {
    await supabase.auth.signOut();
    window.location.href = '/login';
  }

  const getInitials = (email: string) => {
    return email?.substring(0, 2).toUpperCase() || 'U';
  };
</script>

<header class="sticky top-0 z-10 flex h-16 items-center justify-between border-b border-slate-200 bg-white px-6 shadow-sm">
  <!-- Left Side - Mobile Menu Button + Page Title -->
  <div class="flex items-center gap-4">
    <!-- Mobile Menu Button -->
    <button
      onclick={() => isMobileMenuOpen = !isMobileMenuOpen}
      class="lg:hidden rounded-lg p-2 text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900"
      title="Toggle Menu"
    >
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>
    
    <!-- Page Title -->
    <div>
      <h1 class="text-xl font-semibold text-fsc-navy-900">{title}</h1>
    </div>
  </div>

  <!-- Right Side Actions -->
  <div class="flex items-center gap-4">
    <!-- Notifications -->
    <button
      class="relative rounded-lg p-2 text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900"
      title="Notifications"
    >
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
      </svg>
      <!-- Notification Badge -->
      <span class="absolute right-1.5 top-1.5 flex h-2 w-2">
        <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-red-400 opacity-75"></span>
        <span class="relative inline-flex h-2 w-2 rounded-full bg-red-500"></span>
      </span>
    </button>

    <!-- User Menu -->
    <div class="relative">
      <button
        onclick={() => showUserMenu = !showUserMenu}
        class="flex items-center gap-3 rounded-lg px-3 py-2 transition-colors hover:bg-slate-100"
      >
        <div class="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-blue-500 to-purple-500 text-sm font-semibold text-white shadow-sm">
          {user?.email ? getInitials(user.email) : 'U'}
        </div>
        <div class="hidden text-left sm:block">
          <div class="text-sm font-medium text-slate-900">
            {user?.email?.split('@')[0] || 'User'}
          </div>
          <div class="text-xs text-slate-500">{user?.email || 'user@fscnj.com'}</div>
        </div>
        <svg class="h-4 w-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </button>

      <!-- Dropdown Menu -->
      {#if showUserMenu}
        <div class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl border border-slate-200 bg-white shadow-lg">
          <div class="border-b border-slate-200 p-4">
            <div class="text-sm font-medium text-slate-900">{user?.email?.split('@')[0] || 'User'}</div>
            <div class="text-xs text-slate-500">{user?.email || 'user@fscnj.com'}</div>
          </div>
          <div class="p-2">
            <a
              href="/settings/profile"
              class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-slate-700 transition-colors hover:bg-slate-100"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              Profile Settings
            </a>
            <a
              href="/settings/preferences"
              class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-slate-700 transition-colors hover:bg-slate-100"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              Preferences
            </a>
          </div>
          <div class="border-t border-slate-200 p-2">
            <button
              onclick={handleLogout}
              class="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm text-red-700 transition-colors hover:bg-red-50"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
              </svg>
              Sign Out
            </button>
          </div>
        </div>
      {/if}
    </div>
  </div>
</header>

<!-- Click outside to close menu -->
{#if showUserMenu}
  <div
    class="fixed inset-0 z-0"
    onclick={() => showUserMenu = false}
  ></div>
{/if}
