<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import StatusBadge from '$lib/components/StatusBadge.svelte';
  import { env } from '$env/dynamic/public';

  type Session = {
    id: string;
    session_date: string;
    client_id: string;
    provider_id: string;
    minutes: number | null;
    note_submitted: boolean;
    assigned_to: string | null;
    case_status: 'received' | 'in_progress' | 'submitted' | 'paid' | 'flagged';
    clients?: { name: string };
    providers?: { name: string };
    payers?: { name: string };
  };

  let rows = $state<Session[]>([]);
  let loading = $state(true);
  let searchQuery = $state('');
  let statusFilter = $state<string>('all');
  let selectedSession = $state<Session | null>(null);

  $effect(() => {
    (async () => {
      loading = true;
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session?.access_token) {
          loading = false;
          return;
        }

        const response = await fetch(`${env.PUBLIC_API_BASE}/api/sessions`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (response.ok) {
          rows = await response.json();
        }
      } catch (error) {
        console.error('Error loading sessions:', error);
      }
      loading = false;
    })();
  });

  const filtered = () => {
    let result = rows;

    if (statusFilter !== 'all') {
      result = result.filter(r => r.case_status === statusFilter);
    }

    if (searchQuery) {
      const search = searchQuery.toLowerCase();
      result = result.filter(r => {
        const clientName = r.clients?.name ?? '';
        const providerName = r.providers?.name ?? '';
        const payerName = r.payers?.name ?? '';
        return [clientName, providerName, payerName].join(' ').toLowerCase().includes(search);
      });
    }

    return result;
  };

  const statusCounts = $derived({
    received: rows.filter(r => r.case_status === 'received').length,
    in_progress: rows.filter(r => r.case_status === 'in_progress').length,
    submitted: rows.filter(r => r.case_status === 'submitted').length,
    paid: rows.filter(r => r.case_status === 'paid').length,
    flagged: rows.filter(r => r.case_status === 'flagged').length
  });

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  const openDrawer = (session: Session) => {
    selectedSession = session;
  };

  const closeDrawer = () => {
    selectedSession = null;
  };
</script>

<div class="space-y-6">
  <!-- Stats Summary -->
  <div class="grid grid-cols-2 gap-4 sm:grid-cols-5">
    <button
      class="rounded-xl border-2 bg-white p-4 text-left transition-all hover:shadow-md {statusFilter === 'all' ? 'border-blue-500' : 'border-slate-200'}"
      onclick={() => statusFilter = 'all'}
    >
      <div class="text-2xl font-bold text-slate-900">{rows.length}</div>
      <div class="text-sm text-slate-600">All Cases</div>
    </button>
    <button
      class="rounded-xl border-2 bg-white p-4 text-left transition-all hover:shadow-md {statusFilter === 'received' ? 'border-blue-500' : 'border-slate-200'}"
      onclick={() => statusFilter = 'received'}
    >
      <div class="text-2xl font-bold text-blue-600">{statusCounts.received}</div>
      <div class="text-sm text-slate-600">Received</div>
    </button>
    <button
      class="rounded-xl border-2 bg-white p-4 text-left transition-all hover:shadow-md {statusFilter === 'in_progress' ? 'border-purple-500' : 'border-slate-200'}"
      onclick={() => statusFilter = 'in_progress'}
    >
      <div class="text-2xl font-bold text-purple-600">{statusCounts.in_progress}</div>
      <div class="text-sm text-slate-600">In Progress</div>
    </button>
    <button
      class="rounded-xl border-2 bg-white p-4 text-left transition-all hover:shadow-md {statusFilter === 'submitted' ? 'border-teal-500' : 'border-slate-200'}"
      onclick={() => statusFilter = 'submitted'}
    >
      <div class="text-2xl font-bold text-teal-600">{statusCounts.submitted}</div>
      <div class="text-sm text-slate-600">Submitted</div>
    </button>
    <button
      class="rounded-xl border-2 bg-white p-4 text-left transition-all hover:shadow-md {statusFilter === 'flagged' ? 'border-red-500' : 'border-slate-200'}"
      onclick={() => statusFilter = 'flagged'}
    >
      <div class="text-2xl font-bold text-red-600">{statusCounts.flagged}</div>
      <div class="text-sm text-slate-600">Flagged</div>
    </button>
  </div>

  <!-- Filters & Actions -->
  <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
    <div class="relative flex-1 sm:max-w-md">
      <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
        <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
      <input
        type="text"
        class="w-full rounded-xl border-2 border-slate-200 bg-white py-3 pl-11 pr-4 text-slate-900 placeholder-slate-400 transition-all focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
        placeholder="Search by client, provider, or payer..."
        bind:value={searchQuery}
      />
    </div>

    <button
      class="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
    >
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
      Assign Selected
    </button>
  </div>

  <!-- Data Table -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    {#if loading}
      <div class="flex flex-col items-center justify-center py-16">
        <div class="spinner mb-4 h-8 w-8 border-4"></div>
        <p class="text-slate-600">Loading work queue...</p>
      </div>
    {:else if filtered().length === 0}
      <div class="flex flex-col items-center justify-center py-16 text-center">
        <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
          <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
          </svg>
        </div>
        <p class="text-slate-600">No cases found</p>
        <p class="mt-1 text-sm text-slate-500">Try adjusting your filters</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
            <tr>
              <th class="p-4 text-left">
                <input type="checkbox" class="rounded border-slate-300" />
              </th>
              <th class="p-4 text-left font-semibold">Date</th>
              <th class="p-4 text-left font-semibold">Client</th>
              <th class="p-4 text-left font-semibold">Provider</th>
              <th class="p-4 text-left font-semibold">Payer</th>
              <th class="p-4 text-center font-semibold">Status</th>
              <th class="p-4 text-center font-semibold">Assigned</th>
              <th class="p-4"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            {#each filtered() as session}
              <tr class="transition-colors hover:bg-slate-50">
                <td class="p-4">
                  <input type="checkbox" class="rounded border-slate-300" />
                </td>
                <td class="p-4 text-slate-600">{formatDate(session.session_date)}</td>
                <td class="p-4 font-medium text-slate-900">{session.clients?.name ?? 'Unknown'}</td>
                <td class="p-4 text-slate-700">{session.providers?.name ?? 'Unknown'}</td>
                <td class="p-4 text-slate-700">{session.payers?.name ?? 'Unknown'}</td>
                <td class="p-4 text-center">
                  <StatusBadge status={session.case_status || 'received'} />
                </td>
                <td class="p-4 text-center">
                  {#if session.assigned_to}
                    <span class="text-xs text-slate-600">{session.assigned_to}</span>
                  {:else}
                    <span class="text-xs text-slate-400">Unassigned</span>
                  {/if}
                </td>
                <td class="p-4">
                  <button
                    onclick={() => openDrawer(session)}
                    class="rounded-lg p-2 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-600"
                  >
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                    </svg>
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</div>

<!-- Drawer (Coming Soon) -->
{#if selectedSession}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onclick={closeDrawer}>
    <div class="rounded-2xl bg-white p-8 shadow-2xl" onclick={(e) => e.stopPropagation()}>
      <h3 class="text-xl font-bold text-slate-900">Session Details</h3>
      <p class="mt-4 text-slate-600">Drawer component coming soon!</p>
      <button
        onclick={closeDrawer}
        class="mt-6 rounded-lg bg-blue-600 px-6 py-2 text-white hover:bg-blue-700"
      >
        Close
      </button>
    </div>
  </div>
{/if}
