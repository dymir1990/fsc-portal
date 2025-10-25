<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import StatCard from '$lib/components/StatCard.svelte';
  import StatusBadge from '$lib/components/StatusBadge.svelte';
  import { env } from '$env/dynamic/public';

  type Session = {
    id: string;
    session_date: string;
    note_submitted: boolean;
    clients?: { name: string };
    providers?: { name: string };
  };

  type ImportRun = {
    id: string;
    source: string;
    file_name: string;
    started_at: string;
    total_rows: number;
    inserted_rows: number;
    flagged_rows: number;
  };

  let stats = $state({
    total: 0,
    pending: 0,
    submitted: 0,
    flagged: 0
  });

  let recentSessions = $state<Session[]>([]);
  let recentImports = $state<ImportRun[]>([]);
  let loading = $state(true);

  $effect(() => {
    (async () => {
      loading = true;

      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session?.access_token) {
          loading = false;
          return;
        }

        // Fetch sessions from backend API
        const sessionsResponse = await fetch(`${env.PUBLIC_API_BASE}/api/sessions`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (sessionsResponse.ok) {
          const sessions = await sessionsResponse.json();
          stats.total = sessions.length;
          stats.pending = sessions.filter(s => !s.note_submitted).length;
          stats.submitted = sessions.filter(s => s.note_submitted).length;
          stats.flagged = sessions.filter(s => s.is_duplicate).length;
          
          // Get recent sessions (first 10)
          recentSessions = sessions.slice(0, 10);
        }

        // Fetch import history from backend API
        const importsResponse = await fetch(`${env.PUBLIC_API_BASE}/api/imports/history`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (importsResponse.ok) {
          recentImports = await importsResponse.json();
        }
      } catch (error) {
        console.error('Error loading dashboard data:', error);
      }

      loading = false;
    })();
  });

  const formatDate = (dateStr: string) => {
    try {
      return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    } catch {
      return dateStr;
    }
  };

  const formatStatus = (noteSubmitted: boolean) => noteSubmitted ? 'Submitted' : 'Pending';
</script>

<div class="space-y-8">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-3xl font-bold text-fsc-navy-900">Dashboard</h1>
      <p class="mt-1 text-slate-600">Welcome back! Here's what's happening today.</p>
    </div>
    <div class="flex gap-3">
      <a
        href="/case-manager/import"
        class="flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-2.5 text-sm font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
      >
        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
        </svg>
        Upload CSV
      </a>
    </div>
  </div>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20">
      <div class="spinner mb-4 h-8 w-8 border-4"></div>
      <p class="text-slate-600">Loading dashboard...</p>
    </div>
  {:else}
    <!-- Stats Cards -->
    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
      <StatCard
        label="Total Sessions"
        value={stats.total}
        icon="📊"
        color="blue"
      />
      <StatCard
        label="Pending Notes"
        value={stats.pending}
        icon="⏳"
        color="amber"
        trend={{ value: '+12', positive: true }}
      />
      <StatCard
        label="Submitted"
        value={stats.submitted}
        icon="✅"
        color="emerald"
      />
      <StatCard
        label="Flagged Issues"
        value={stats.flagged}
        icon="🚩"
        color="red"
      />
    </div>

    <!-- Quick Actions -->
    <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
      <a
        href="/sessions"
        class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-gradient-to-br from-blue-50 to-purple-50 p-6 shadow-sm transition-all hover:shadow-lg hover:scale-[1.02]"
      >
        <div class="relative z-10">
          <div class="mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-blue-500 text-white shadow-lg">
            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-fsc-navy-900">View All Sessions</h3>
          <p class="mt-1 text-sm text-slate-600">Manage and track billing sessions</p>
        </div>
        <div class="absolute right-4 top-4 text-slate-300 transition-transform group-hover:translate-x-1">
          <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </div>
      </a>

      <a
        href="/case-manager/import"
        class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-gradient-to-br from-emerald-50 to-teal-50 p-6 shadow-sm transition-all hover:shadow-lg hover:scale-[1.02]"
      >
        <div class="relative z-10">
          <div class="mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-500 text-white shadow-lg">
            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-fsc-navy-900">Import CSV Data</h3>
          <p class="mt-1 text-sm text-slate-600">Upload weekly SimplePractice files</p>
        </div>
        <div class="absolute right-4 top-4 text-slate-300 transition-transform group-hover:translate-x-1">
          <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </div>
      </a>
    </div>

    {#if recentImports.length > 0}
      <!-- Recent Imports -->
      <div class="rounded-2xl border border-slate-200 bg-white shadow-sm">
        <div class="border-b border-slate-200 p-6">
          <h2 class="text-lg font-semibold text-fsc-navy-900">Recent Imports</h2>
          <p class="mt-1 text-sm text-slate-600">Latest CSV uploads and processing status</p>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-sm">
            <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
              <tr>
                <th class="p-4 text-left font-semibold">File</th>
                <th class="p-4 text-left font-semibold">Date</th>
                <th class="p-4 text-right font-semibold">Total</th>
                <th class="p-4 text-right font-semibold">Inserted</th>
                <th class="p-4 text-right font-semibold">Flagged</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              {#each recentImports as imp}
                <tr class="transition-colors hover:bg-slate-50">
                  <td class="p-4 font-medium text-slate-900">{imp.file_name}</td>
                  <td class="p-4 text-slate-600">{formatDate(imp.started_at)}</td>
                  <td class="p-4 text-right font-semibold text-slate-900">{imp.total_rows}</td>
                  <td class="p-4 text-right text-emerald-600">{imp.inserted_rows}</td>
                  <td class="p-4 text-right">
                    <span class={imp.flagged_rows > 0 ? 'font-semibold text-red-600' : 'text-slate-400'}>
                      {imp.flagged_rows}
                    </span>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </div>
    {/if}

    <!-- Recent Sessions -->
    <div class="rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div class="border-b border-slate-200 p-6">
        <h2 class="text-lg font-semibold text-fsc-navy-900">Recent Sessions</h2>
        <p class="mt-1 text-sm text-slate-600">Latest billing sessions across all providers</p>
      </div>
      {#if recentSessions.length === 0}
        <div class="flex flex-col items-center justify-center py-12 text-center">
          <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
            <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
            </svg>
          </div>
          <p class="text-slate-600">No sessions yet</p>
          <p class="mt-1 text-sm text-slate-500">Import a CSV to get started</p>
          <a
            href="/case-manager/import"
            class="mt-4 rounded-lg bg-blue-600 px-6 py-2 text-sm font-semibold text-white hover:bg-blue-700"
          >
            Upload CSV
          </a>
        </div>
      {:else}
        <div class="overflow-x-auto">
          <table class="w-full text-sm">
            <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
              <tr>
                <th class="p-4 text-left font-semibold">Date</th>
                <th class="p-4 text-left font-semibold">Client</th>
                <th class="p-4 text-left font-semibold">Provider</th>
                <th class="p-4 text-center font-semibold">Status</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              {#each recentSessions as session}
                <tr class="transition-colors hover:bg-slate-50">
                  <td class="p-4 text-slate-600">{formatDate(session.session_date)}</td>
                  <td class="p-4 font-medium text-slate-900">{session.clients?.name ?? 'Unknown'}</td>
                  <td class="p-4 text-slate-700">{session.providers?.name ?? 'Unknown'}</td>
                  <td class="p-4 text-center">
                    <StatusBadge status={session.note_submitted ? 'submitted' : 'pending'} />
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {/if}
    </div>
  {/if}
</div>
