<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';

  type Profile = {
    id: string;
    email: string;
    full_name: string | null;
    role: 'admin' | 'director' | 'billing' | 'provider';
    created_at: string;
  };

  let profiles = $state<Profile[]>([]);
  let loading = $state(true);
  let error = $state('');
  let success = $state('');
  let currentUserRole = $state('');

  const roleDescriptions = {
    admin: 'Full access - can manage everything including roles and payroll',
    director: 'Management access - can view sessions, reports, and manage operations',
    billing: 'Limited access - can only view and process assigned billing tasks',
    provider: 'View only - can see their own sessions and submit notes'
  };

  onMount(async () => {
    await loadProfiles();
  });

  async function loadProfiles() {
    loading = true;
    error = '';

    // Check current user's role
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { data: currentProfile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();

    currentUserRole = currentProfile?.role || '';

    // Only admins can see this page
    if (currentUserRole !== 'admin') {
      error = 'You do not have permission to view this page';
      loading = false;
      return;
    }

    // Load all profiles
    const { data, error: fetchError } = await supabase
      .from('profiles')
      .select('id, email, full_name, role, created_at')
      .order('created_at', { ascending: false });

    if (fetchError) {
      error = 'Failed to load users: ' + fetchError.message;
    } else {
      profiles = data as Profile[];
    }

    loading = false;
  }

  async function updateRole(userId: string, newRole: string) {
    success = '';
    error = '';

    const { error: updateError } = await supabase
      .from('profiles')
      .update({ role: newRole })
      .eq('id', userId);

    if (updateError) {
      error = 'Failed to update role: ' + updateError.message;
    } else {
      success = 'Role updated successfully!';
      await loadProfiles();
      setTimeout(() => success = '', 3000);
    }
  }

  function formatDate(dateStr: string) {
    return new Date(dateStr).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  }

  function getRoleBadgeClass(role: string) {
    switch (role) {
      case 'admin': return 'bg-purple-100 text-purple-700 border-purple-200';
      case 'director': return 'bg-blue-100 text-blue-700 border-blue-200';
      case 'billing': return 'bg-emerald-100 text-emerald-700 border-emerald-200';
      case 'provider': return 'bg-amber-100 text-amber-700 border-amber-200';
      default: return 'bg-slate-100 text-slate-700 border-slate-200';
    }
  }
</script>

<div class="space-y-8">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-3xl font-bold text-fsc-navy-900">User Management</h1>
      <p class="mt-1 text-slate-600">Assign roles and manage user permissions</p>
    </div>
  </div>

  <!-- Status Messages -->
  {#if error}
    <div class="rounded-xl border-2 border-red-200 bg-red-50 p-4 text-red-700">
      <div class="flex items-start gap-3">
        <svg class="h-5 w-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-sm font-medium">{error}</p>
      </div>
    </div>
  {/if}

  {#if success}
    <div class="rounded-xl border-2 border-emerald-200 bg-emerald-50 p-4 text-emerald-700">
      <div class="flex items-start gap-3">
        <svg class="h-5 w-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-sm font-medium">{success}</p>
      </div>
    </div>
  {/if}

  <!-- Role Guide -->
  <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
    {#each Object.entries(roleDescriptions) as [role, description]}
      <div class="rounded-xl border border-slate-200 bg-white p-4">
        <div class="mb-2">
          <span class="inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-semibold {getRoleBadgeClass(role)}">
            {role.charAt(0).toUpperCase() + role.slice(1)}
          </span>
        </div>
        <p class="text-sm text-slate-600">{description}</p>
      </div>
    {/each}
  </div>

  <!-- Users Table -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    <div class="border-b border-slate-200 p-6">
      <h2 class="text-lg font-semibold text-fsc-navy-900">All Users</h2>
      <p class="mt-1 text-sm text-slate-600">Manage roles for {profiles.length} users</p>
    </div>

    {#if loading}
      <div class="flex flex-col items-center justify-center py-12">
        <div class="spinner mb-4 h-8 w-8 border-4"></div>
        <p class="text-slate-600">Loading users...</p>
      </div>
    {:else if currentUserRole !== 'admin'}
      <div class="flex flex-col items-center justify-center py-12 text-center">
        <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-red-100">
          <svg class="h-8 w-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        <p class="text-lg font-semibold text-slate-900">Access Denied</p>
        <p class="mt-1 text-sm text-slate-500">Only administrators can manage user roles</p>
      </div>
    {:else if profiles.length === 0}
      <div class="flex flex-col items-center justify-center py-12 text-center">
        <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
          <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
          </svg>
        </div>
        <p class="text-slate-600">No users found</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
            <tr>
              <th class="p-4 text-left font-semibold">User</th>
              <th class="p-4 text-left font-semibold">Email</th>
              <th class="p-4 text-left font-semibold">Current Role</th>
              <th class="p-4 text-left font-semibold">Joined</th>
              <th class="p-4 text-left font-semibold">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            {#each profiles as profile}
              <tr class="transition-colors hover:bg-slate-50">
                <td class="p-4">
                  <div class="font-medium text-slate-900">
                    {profile.full_name || 'No name'}
                  </div>
                </td>
                <td class="p-4 text-slate-600">{profile.email}</td>
                <td class="p-4">
                  <span class="inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-semibold {getRoleBadgeClass(profile.role)}">
                    {profile.role.charAt(0).toUpperCase() + profile.role.slice(1)}
                  </span>
                </td>
                <td class="p-4 text-slate-600">{formatDate(profile.created_at)}</td>
                <td class="p-4">
                  <select
                    class="rounded-lg border-2 border-slate-200 bg-white px-3 py-1.5 text-sm font-medium text-slate-700 transition-colors hover:border-slate-300 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100"
                    value={profile.role}
                    onchange={(e) => updateRole(profile.id, e.currentTarget.value)}
                  >
                    <option value="admin">Admin</option>
                    <option value="director">Director</option>
                    <option value="billing">Billing</option>
                    <option value="provider">Provider</option>
                  </select>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</div>
