<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import StatusBadge from '$lib/components/StatusBadge.svelte';
  import BillingStatusBadge from '$lib/components/BillingStatusBadge.svelte';
  import { env } from '$env/dynamic/public';

  type Session = {
    id: string;
    session_date: string;
    client_id: string;
    provider_id: string;
    minutes: number | null;
    note_submitted: boolean;
    billing_status?: string;
    amount_billed?: number;
    amount_paid?: number;
    date_submitted?: string;
    date_paid?: string;
    clients?: { name: string };
    providers?: { name: string };
  };

  let rows = $state<Session[]>([]);
  let q = $state('');
  let loading = $state(true);
  let statusFilter = $state<'all' | 'pending' | 'submitted' | 'billing'>('all');

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

    // Apply status filter
    if (statusFilter !== 'all') {
      result = result.filter(r => {
        if (statusFilter === 'pending') return !r.note_submitted;
        if (statusFilter === 'submitted') return r.note_submitted;
        if (statusFilter === 'billing') return r.billing_status && r.billing_status !== 'completed';
        return true;
      });
    }

    // Apply search
    if (q) {
      const search = q.toLowerCase();
      result = result.filter(r => {
        const clientName = r.clients?.name ?? '';
        const providerName = r.providers?.name ?? '';
        const date = r.session_date ?? '';
        return [clientName, providerName, date].join(' ').toLowerCase().includes(search);
      });
    }

    return result;
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };
</script>

<div class="space-y-6">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-3xl font-bold text-fsc-navy-900">Sessions</h1>
      <p class="mt-1 text-slate-600">Manage and track all billing sessions</p>
    </div>
    <a
      href="/import"
      class="flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-2.5 text-sm font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
    >
      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
      Import Sessions
    </a>
  </div>

  <!-- Stats Summary -->
  <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
    <div class="rounded-xl border border-slate-200 bg-white p-4">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-slate-600">Total Sessions</p>
          <p class="text-2xl font-bold text-fsc-navy-900">{rows.length}</p>
        </div>
        <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100">
          <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
        </div>
      </div>
    </div>
    <div class="rounded-xl border border-slate-200 bg-white p-4">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-slate-600">Pending Notes</p>
          <p class="text-2xl font-bold text-amber-600">{rows.filter(r => !r.note_submitted).length}</p>
        </div>
        <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-100">
          <svg class="h-6 w-6 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
      </div>
    </div>
    <div class="rounded-xl border border-slate-200 bg-white p-4">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-slate-600">Submitted</p>
          <p class="text-2xl font-bold text-emerald-600">{rows.filter(r => r.note_submitted).length}</p>
        </div>
        <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100">
          <svg class="h-6 w-6 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
      </div>
    </div>
  </div>

  <!-- Filters -->
  <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
    <div class="relative flex-1 sm:max-w-md">
      <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
        <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
      <input
        class="w-full rounded-xl border-2 border-slate-200 bg-white py-3 pl-11 pr-4 text-slate-900 placeholder-slate-400 transition-all focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
        placeholder="Search by client, provider, or date..."
        bind:value={q}
      />
    </div>

    <div class="flex gap-2">
      <button
        class="rounded-lg px-4 py-2 text-sm font-semibold transition-all {statusFilter === 'all' ? 'bg-fsc-navy-600 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}"
        onclick={() => statusFilter = 'all'}
      >
        All
      </button>
      <button
        class="rounded-lg px-4 py-2 text-sm font-semibold transition-all {statusFilter === 'pending' ? 'bg-amber-600 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}"
        onclick={() => statusFilter = 'pending'}
      >
        Pending
      </button>
      <button
        class="rounded-lg px-4 py-2 text-sm font-semibold transition-all {statusFilter === 'submitted' ? 'bg-emerald-600 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}"
        onclick={() => statusFilter = 'submitted'}
      >
        Submitted
      </button>
      <button
        class="rounded-lg px-4 py-2 text-sm font-semibold transition-all {statusFilter === 'billing' ? 'bg-purple-600 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}"
        onclick={() => statusFilter = 'billing'}
      >
        Billing
      </button>
    </div>
  </div>

  <!-- Sessions Table -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    {#if loading}
      <div class="flex flex-col items-center justify-center py-16">
        <div class="spinner mb-4 h-8 w-8 border-4"></div>
        <p class="text-slate-600">Loading sessions...</p>
      </div>
    {:else if filtered().length === 0}
      <div class="flex flex-col items-center justify-center py-16 text-center">
        <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
          <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <p class="text-slate-600">No sessions found</p>
        <p class="mt-1 text-sm text-slate-500">Try adjusting your filters or search</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
            <tr>
              <th class="p-4 text-left font-semibold">Date</th>
              <th class="p-4 text-left font-semibold">Client</th>
              <th class="p-4 text-left font-semibold">Provider</th>
              <th class="p-4 text-left font-semibold">Duration</th>
              <th class="p-4 text-center font-semibold">Note Status</th>
              <th class="p-4 text-center font-semibold">Billing Status</th>
              <th class="p-4 text-right font-semibold">Amount</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            {#each filtered() as r}
              <tr class="transition-colors hover:bg-slate-50">
                <td class="p-4 text-slate-600">{formatDate(r.session_date)}</td>
                <td class="p-4 font-medium text-slate-900">{r.clients?.name ?? 'Unknown'}</td>
                <td class="p-4 text-slate-700">{r.providers?.name ?? 'Unknown'}</td>
                <td class="p-4 text-slate-600">
                  {#if r.minutes}
                    <span class="inline-flex items-center gap-1">
                      <svg class="h-4 w-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      {r.minutes} min
                    </span>
                  {:else}
                    <span class="text-slate-400">-</span>
                  {/if}
                </td>
                <td class="p-4 text-center">
                  <StatusBadge status={r.note_submitted ? 'submitted' : 'pending'} />
                </td>
                <td class="p-4 text-center">
                  <BillingStatusBadge status={r.billing_status || 'completed'} size="sm" />
                </td>
                <td class="p-4 text-right text-slate-600">
                  {#if r.amount_paid}
                    <span class="text-emerald-600 font-semibold">${r.amount_paid.toFixed(2)}</span>
                  {:else if r.amount_billed}
                    <span class="text-amber-600">${r.amount_billed.toFixed(2)}</span>
                  {:else}
                    <span class="text-slate-400">-</span>
                  {/if}
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>

  {#if filtered().length > 0}
    <div class="flex items-center justify-between text-sm text-slate-600">
      <p>Showing {filtered().length} of {rows.length} sessions</p>
      <p class="text-xs text-slate-500">Limited to 50 most recent</p>
    </div>
  {/if}
</div>
