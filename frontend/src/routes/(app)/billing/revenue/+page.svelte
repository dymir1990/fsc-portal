<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { env } from '$env/dynamic/public';

  type DashboardMetrics = {
    completed_sessions: number;
    ready_to_bill: number;
    submitted_claims: number;
    paid_sessions: number;
    denied_claims: number;
    outstanding_amount: number;
    total_collected: number;
    avg_days_to_payment: number;
  };

  let metrics = $state<DashboardMetrics | null>(null);
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

        // For now, we'll calculate basic metrics from sessions
        // Later this will use the dashboard_metrics view
        const response = await fetch(`${env.PUBLIC_API_BASE}/api/sessions`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (response.ok) {
          const sessions = await response.json();
          
          // Calculate basic metrics
          metrics = {
            completed_sessions: sessions.filter((s: any) => s.billing_status === 'completed').length,
            ready_to_bill: sessions.filter((s: any) => s.billing_status === 'ready_to_bill').length,
            submitted_claims: sessions.filter((s: any) => s.billing_status === 'submitted').length,
            paid_sessions: sessions.filter((s: any) => s.billing_status === 'paid').length,
            denied_claims: sessions.filter((s: any) => s.billing_status === 'denied').length,
            outstanding_amount: sessions.reduce((sum: number, s: any) => sum + (s.amount_billed || 0), 0),
            total_collected: sessions.reduce((sum: number, s: any) => sum + (s.amount_paid || 0), 0),
            avg_days_to_payment: 0 // Will be calculated from database view later
          };
        }
      } catch (error) {
        console.error('Error loading revenue metrics:', error);
      }
      loading = false;
    })();
  });

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(amount);
  };
</script>

<div class="space-y-6">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-3xl font-bold text-fsc-navy-900">Revenue Dashboard</h1>
      <p class="mt-1 text-slate-600">Track billing lifecycle and revenue metrics</p>
    </div>
    <a
      href="/case-manager/import"
      class="flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 px-6 py-3 text-white font-semibold shadow-lg hover:shadow-xl transition-all hover:scale-105"
    >
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
      </svg>
      Import CSV
    </a>
  </div>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-16">
      <div class="spinner mb-4 h-8 w-8 border-4"></div>
      <p class="text-slate-600">Loading revenue metrics...</p>
    </div>
  {:else if metrics}
    <!-- Key Metrics Cards -->
    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
      <!-- Outstanding Amount -->
      <div class="rounded-xl border border-slate-200 bg-white p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-slate-600">Outstanding</p>
            <p class="text-2xl font-bold text-amber-600">{formatCurrency(metrics.outstanding_amount)}</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-100">
            <svg class="h-6 w-6 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Total Collected -->
      <div class="rounded-xl border border-slate-200 bg-white p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-slate-600">Collected</p>
            <p class="text-2xl font-bold text-emerald-600">{formatCurrency(metrics.total_collected)}</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100">
            <svg class="h-6 w-6 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Ready to Bill -->
      <div class="rounded-xl border border-slate-200 bg-white p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-slate-600">Ready to Bill</p>
            <p class="text-2xl font-bold text-blue-600">{metrics.ready_to_bill}</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100">
            <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Submitted Claims -->
      <div class="rounded-xl border border-slate-200 bg-white p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-slate-600">Submitted</p>
            <p class="text-2xl font-bold text-purple-600">{metrics.submitted_claims}</p>
          </div>
          <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-purple-100">
            <svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Status Breakdown -->
    <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
      <!-- Billing Status Overview -->
      <div class="rounded-xl border border-slate-200 bg-white p-6">
        <h3 class="text-lg font-semibold text-slate-900 mb-4">Billing Status Overview</h3>
        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <span class="text-sm text-slate-600">Completed</span>
            <span class="font-semibold text-slate-900">{metrics.completed_sessions}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-slate-600">Ready to Bill</span>
            <span class="font-semibold text-blue-600">{metrics.ready_to_bill}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-slate-600">Submitted</span>
            <span class="font-semibold text-purple-600">{metrics.submitted_claims}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-slate-600">Paid</span>
            <span class="font-semibold text-emerald-600">{metrics.paid_sessions}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-slate-600">Denied</span>
            <span class="font-semibold text-red-600">{metrics.denied_claims}</span>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="rounded-xl border border-slate-200 bg-white p-6">
        <h3 class="text-lg font-semibold text-slate-900 mb-4">Quick Actions</h3>
        <div class="space-y-3">
          <a
            href="/sessions"
            class="flex items-center gap-3 rounded-lg border border-slate-200 p-3 text-slate-700 hover:bg-slate-50 transition-colors"
          >
            <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
            <span>View All Sessions</span>
          </a>
          <a
            href="/import"
            class="flex items-center gap-3 rounded-lg border border-slate-200 p-3 text-slate-700 hover:bg-slate-50 transition-colors"
          >
            <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            <span>Import New Sessions</span>
          </a>
          <a
            href="/billing/aging"
            class="flex items-center gap-3 rounded-lg border border-slate-200 p-3 text-slate-700 hover:bg-slate-50 transition-colors"
          >
            <svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>View Aging Report</span>
          </a>
        </div>
      </div>
    </div>

    <!-- Phase 2 Notice -->
    <div class="rounded-xl border border-blue-200 bg-blue-50 p-6">
      <div class="flex items-start gap-3">
        <svg class="h-6 w-6 text-blue-600 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <div>
          <h3 class="text-lg font-semibold text-blue-900">Phase 2 Revenue Cycle Management</h3>
          <p class="mt-1 text-blue-700">
            This dashboard shows basic metrics. Full revenue cycle tracking with aging reports, 
            payment reconciliation, and automated alerts is coming in Phase 2.
          </p>
          <p class="mt-2 text-sm text-blue-600">
            Next: Run the database migration script to enable full billing status tracking.
          </p>
        </div>
      </div>
    </div>
  {/if}
</div>
