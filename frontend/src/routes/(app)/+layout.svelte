<script lang="ts">
  import Sidebar from '$lib/components/Sidebar.svelte';
  import Topbar from '$lib/components/Topbar.svelte';
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { env } from '$env/dynamic/public';
  import '../../app.css';

  let userRole = $state<string>('admin');
  let pageTitle = $state<string>('Dashboard');
  let loading = $state(true);
  let cacheBust = $state(Date.now()); // Force cache refresh
  let isMobileMenuOpen = $state(false);

  onMount(async () => {
    console.log('Layout onMount starting, env:', env);
    const { data: { session } } = await supabase.auth.getSession();
    console.log('Session data:', session);

    if (!session?.user) {
      console.log('No session, redirecting to login');
      goto('/login');
      return;
    }

    // Fetch actual role from backend API
    try {
      console.log('Fetching user profile, API base:', env.PUBLIC_API_BASE);
      const response = await fetch(`${env.PUBLIC_API_BASE}/api/user/profile`, {
        headers: {
          'Authorization': `Bearer ${session.access_token}`
        }
      });

      if (response.ok) {
        const profile = await response.json();
        userRole = profile.role;
      } else {
        console.error('Failed to fetch user profile:', response.status);
        userRole = 'billing'; // Fallback
      }
    } catch (error) {
      console.error('Failed to fetch user role:', error);
      userRole = 'billing'; // Fallback
    }

    loading = false;
  });

  // Update page title based on current route
  $effect(() => {
    if (typeof window !== 'undefined') {
      const path = window.location.pathname;
      if (path.includes('/dashboard')) pageTitle = 'Dashboard';
      else if (path.includes('/sessions')) pageTitle = 'Sessions';
      else if (path.includes('/import')) pageTitle = 'Import CSV';
      else if (path.includes('/queue')) pageTitle = 'Work Queue';
      else if (path.includes('/my-work')) pageTitle = 'My Work';
      else if (path.includes('/billing')) pageTitle = 'Billing';
      else if (path.includes('/reports')) pageTitle = 'Reports';
      else if (path.includes('/payers')) pageTitle = 'Payers';
      else if (path.includes('/payroll')) pageTitle = 'Payroll';
      else pageTitle = 'Dashboard';
    }
  });
</script>

{#if loading}
  <div class="flex min-h-screen items-center justify-center bg-slate-50">
    <div class="text-center space-y-4">
      <div class="spinner h-12 w-12 border-4 mx-auto"></div>
      <p class="text-slate-600 font-medium">Loading...</p>
    </div>
  </div>
{:else}
  <div class="flex h-screen overflow-hidden bg-slate-50">
    <!-- Mobile Overlay -->
    {#if isMobileMenuOpen}
      <div
        class="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
        onclick={() => isMobileMenuOpen = false}
      ></div>
    {/if}

    <!-- Sidebar -->
    <Sidebar {userRole} {isMobileMenuOpen} />

    <!-- Main Content Area -->
    <div class="flex flex-1 flex-col overflow-hidden">
      <!-- Topbar -->
      <Topbar title={pageTitle} {isMobileMenuOpen} />

      <!-- Page Content -->
      <main class="flex-1 overflow-y-auto p-6">
        <slot />
      </main>
    </div>
  </div>
{/if}
