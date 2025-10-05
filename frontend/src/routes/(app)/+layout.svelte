<script lang="ts">
  import Sidebar from '$lib/components/Sidebar.svelte';
  import Topbar from '$lib/components/Topbar.svelte';
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import '../../app.css';

  let userRole = $state<string>('admin');
  let pageTitle = $state<string>('Dashboard');
  let loading = $state(true);

  onMount(async () => {
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      goto('/login');
      return;
    }

    // TODO: Fetch actual role from user metadata or database
    // For now, default to admin
    const role = user.user_metadata?.role || 'admin';
    userRole = role;
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
    <!-- Sidebar -->
    <Sidebar {userRole} />

    <!-- Main Content Area -->
    <div class="flex flex-1 flex-col overflow-hidden">
      <!-- Topbar -->
      <Topbar title={pageTitle} />

      <!-- Page Content -->
      <main class="flex-1 overflow-y-auto p-6">
        <slot />
      </main>
    </div>
  </div>
{/if}
