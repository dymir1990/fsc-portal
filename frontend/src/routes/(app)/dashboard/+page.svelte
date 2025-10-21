<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import StatCard from '$lib/components/StatCard.svelte';
  import StatusBadge from '$lib/components/StatusBadge.svelte';
  import RevenueChart from '$lib/components/RevenueChart.svelte';
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

  type DashboardMetrics = {
    total_sessions: number;
    completed_sessions: number;
    ready_to_bill: number;
    submitted_claims: number;
    paid_sessions: number;
    denied_claims: number;
    total_billed: number;
    total_paid: number;
    outstanding_amount: number;
    month_collected: number;
    avg_days_to_payment: number;
  };

  type TrendData = {
    month: string;
    month_key: string;
    sessions: number;
    billed: number;
    collected: number;
  };

  let metrics = $state<DashboardMetrics>({
    total_sessions: 0,
    completed_sessions: 0,
    ready_to_bill: 0,
    submitted_claims: 0,
    paid_sessions: 0,
    denied_claims: 0,
    total_billed: 0,
    total_paid: 0,
    outstanding_amount: 0,
    month_collected: 0,
    avg_days_to_payment: 0
  });

  let revenueTrends = $state<TrendData[]>([]);
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

        // Fetch dashboard metrics from backend API
        const metricsResponse = await fetch(`${env.PUBLIC_API_BASE}/api/metrics/dashboard`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (metricsResponse.ok) {
          metrics = await metricsResponse.json();
        }

        // Fetch revenue trends
        const trendsResponse = await fetch(`${env.PUBLIC_API_BASE}/api/metrics/revenue-trends`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (trendsResponse.ok) {
          const trendsData = await trendsResponse.json();
          revenueTrends = trendsData.trends || [];
        }

        // Fetch sessions from backend API for recent sessions display
        const sessionsResponse = await fetch(`${env.PUBLIC_API_BASE}/api/sessions`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (sessionsResponse.ok) {
          const sessions = await sessionsResponse.json();
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
        href="/import"
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
    <!-- Revenue Metrics -->
    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
      <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-slate-600">Outstanding Claims</p>
            <p class="mt-2 text-3xl font-bold text-amber-600">${metrics.outstanding_amount.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}</p>
            <p class="mt-1 text-xs text-slate-500">{metrics.submitted_claims} claims submitted</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-100">
            <svg class="h-6 w-6 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
      </div>

      <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-slate-600">Collected This Month</p>
            <p class="mt-2 text-3xl font-bold text-emerald-600">${metrics.month_collected.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}</p>
            <p class="mt-1 text-xs text-slate-500">{metrics.paid_sessions} payments received</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100">
            <svg class="h-6 w-6 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
      </div>

      <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-slate-600">Ready to Bill</p>
            <p class="mt-2 text-3xl font-bold text-blue-600">{metrics.ready_to_bill}</p>
            <p class="mt-1 text-xs text-slate-500">{metrics.total_sessions} total sessions</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100">
            <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
          </div>
        </div>
      </div>

      <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-slate-600">Avg. Days to Payment</p>
            <p class="mt-2 text-3xl font-bold text-purple-600">{metrics.avg_days_to_payment}</p>
            <p class="mt-1 text-xs text-slate-500">{metrics.denied_claims} claims denied</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-purple-100">
            <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Revenue Chart -->
    <RevenueChart trends={revenueTrends} />

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
        href="/import"
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
            href="/import"
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
