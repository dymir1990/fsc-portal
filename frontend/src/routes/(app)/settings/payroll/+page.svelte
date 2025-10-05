<script lang="ts">
  import { supabase } from '$lib/supabaseClient';

  type PayrollCycle = {
    id: string;
    start_date: string;
    end_date: string;
    status: 'draft' | 'sent' | 'approved' | 'paid';
    total_sessions: number;
    total_amount: number;
  };

  type ProviderPayroll = {
    provider_id: string;
    provider_name: string;
    session_count: number;
    total_minutes: number;
    total_amount: number;
    status: string;
  };

  let cycles = $state<PayrollCycle[]>([]);
  let selectedCycle = $state<PayrollCycle | null>(null);
  let providerDetails = $state<ProviderPayroll[]>([]);
  let loading = $state(true);

  // Mock data - replace with real Supabase queries
  $effect(() => {
    loading = true;

    // Simulate loading payroll cycles
    setTimeout(() => {
      cycles = [
        {
          id: '1',
          start_date: '2025-09-23',
          end_date: '2025-10-06',
          status: 'paid',
          total_sessions: 142,
          total_amount: 14200
        },
        {
          id: '2',
          start_date: '2025-10-07',
          end_date: '2025-10-20',
          status: 'approved',
          total_sessions: 156,
          total_amount: 15600
        },
        {
          id: '3',
          start_date: '2025-10-21',
          end_date: '2025-11-03',
          status: 'draft',
          total_sessions: 134,
          total_amount: 13400
        }
      ];
      loading = false;
    }, 500);
  });

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
  };

  const getStatusColor = (status: string) => {
    if (status === 'draft') return 'bg-slate-100 text-slate-700';
    if (status === 'sent') return 'bg-blue-100 text-blue-700';
    if (status === 'approved') return 'bg-purple-100 text-purple-700';
    if (status === 'paid') return 'bg-emerald-100 text-emerald-700';
    return 'bg-slate-100 text-slate-700';
  };

  const viewDetails = (cycle: PayrollCycle) => {
    selectedCycle = cycle;

    // Mock provider data
    providerDetails = [
      { provider_id: '1', provider_name: 'Dr. Emily Johnson', session_count: 24, total_minutes: 1200, total_amount: 2400, status: 'ready' },
      { provider_id: '2', provider_name: 'Dr. Michael Chen', session_count: 32, total_minutes: 1600, total_amount: 3200, status: 'ready' },
      { provider_id: '3', provider_name: 'Dr. Sarah Williams', session_count: 28, total_minutes: 1400, total_amount: 2800, status: 'ready' }
    ];
  };

  const closeDetails = () => {
    selectedCycle = null;
    providerDetails = [];
  };

  async function markAsPaid(cycleId: string) {
    // Update status in database
    cycles = cycles.map(c => c.id === cycleId ? { ...c, status: 'paid' } : c);
    closeDetails();
  }

  async function exportPayroll(cycleId: string) {
    alert('Exporting payroll to CSV...');
  }
</script>

<div class="space-y-6">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold text-fsc-navy-900">Payroll Management</h2>
      <p class="mt-1 text-sm text-slate-600">Biweekly payroll cycles for outpatient therapists</p>
    </div>
    <button
      class="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
    >
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
      Create New Cycle
    </button>
  </div>

  <!-- Payroll Cycles -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    {#if loading}
      <div class="flex flex-col items-center justify-center py-16">
        <div class="spinner mb-4 h-8 w-8 border-4"></div>
        <p class="text-slate-600">Loading payroll cycles...</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
            <tr>
              <th class="p-4 text-left font-semibold">Pay Period</th>
              <th class="p-4 text-right font-semibold">Sessions</th>
              <th class="p-4 text-right font-semibold">Total Amount</th>
              <th class="p-4 text-center font-semibold">Status</th>
              <th class="p-4"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            {#each cycles as cycle}
              <tr class="transition-colors hover:bg-slate-50">
                <td class="p-4">
                  <div class="font-medium text-slate-900">
                    {formatDate(cycle.start_date)} - {formatDate(cycle.end_date)}
                  </div>
                  <div class="text-xs text-slate-500">Biweekly Period</div>
                </td>
                <td class="p-4 text-right font-semibold text-slate-900">{cycle.total_sessions}</td>
                <td class="p-4 text-right font-bold text-fsc-navy-900">{formatCurrency(cycle.total_amount)}</td>
                <td class="p-4 text-center">
                  <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold capitalize {getStatusColor(cycle.status)}">
                    {cycle.status}
                  </span>
                </td>
                <td class="p-4">
                  <div class="flex items-center justify-end gap-2">
                    <button
                      onclick={() => viewDetails(cycle)}
                      class="rounded-lg bg-blue-600 px-4 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-blue-700"
                    >
                      View Details
                    </button>
                    <button
                      onclick={() => exportPayroll(cycle.id)}
                      class="rounded-lg border border-slate-300 bg-white px-4 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50"
                      title="Export to CSV"
                    >
                      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</div>

<!-- Payroll Details Modal -->
{#if selectedCycle}
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex min-h-screen items-center justify-center px-4 py-8">
      <div class="fixed inset-0 bg-slate-900 bg-opacity-75 transition-opacity" onclick={closeDetails}></div>

      <div class="relative z-10 w-full max-w-4xl transform overflow-hidden rounded-2xl bg-white shadow-2xl transition-all">
        <!-- Header -->
        <div class="border-b border-slate-200 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 px-8 py-6">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-xl font-bold text-fsc-navy-900">Payroll Cycle Details</h3>
              <p class="mt-1 text-sm text-slate-600">
                {formatDate(selectedCycle.start_date)} - {formatDate(selectedCycle.end_date)}
              </p>
            </div>
            <button
              onclick={closeDetails}
              class="rounded-lg p-2 text-slate-400 transition-colors hover:bg-white hover:text-slate-600"
            >
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Content -->
        <div class="p-8">
          <!-- Summary Cards -->
          <div class="mb-6 grid grid-cols-3 gap-4">
            <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
              <div class="text-2xl font-bold text-slate-900">{selectedCycle.total_sessions}</div>
              <div class="text-sm text-slate-600">Total Sessions</div>
            </div>
            <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
              <div class="text-2xl font-bold text-fsc-navy-900">{formatCurrency(selectedCycle.total_amount)}</div>
              <div class="text-sm text-slate-600">Total Amount</div>
            </div>
            <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
              <div class="text-2xl font-bold capitalize {selectedCycle.status === 'paid' ? 'text-emerald-600' : 'text-slate-900'}">
                {selectedCycle.status}
              </div>
              <div class="text-sm text-slate-600">Status</div>
            </div>
          </div>

          <!-- Provider Breakdown -->
          <div class="overflow-hidden rounded-xl border border-slate-200">
            <table class="w-full text-sm">
              <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
                <tr>
                  <th class="p-4 text-left font-semibold">Provider</th>
                  <th class="p-4 text-right font-semibold">Sessions</th>
                  <th class="p-4 text-right font-semibold">Minutes</th>
                  <th class="p-4 text-right font-semibold">Amount</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100">
                {#each providerDetails as provider}
                  <tr class="transition-colors hover:bg-slate-50">
                    <td class="p-4 font-medium text-slate-900">{provider.provider_name}</td>
                    <td class="p-4 text-right text-slate-700">{provider.session_count}</td>
                    <td class="p-4 text-right text-slate-700">{provider.total_minutes}</td>
                    <td class="p-4 text-right font-bold text-fsc-navy-900">{formatCurrency(provider.total_amount)}</td>
                  </tr>
                {/each}
              </tbody>
              <tfoot class="border-t-2 border-slate-300 bg-slate-50">
                <tr>
                  <td class="p-4 font-bold text-slate-900">Total</td>
                  <td class="p-4 text-right font-bold text-slate-900">
                    {providerDetails.reduce((sum, p) => sum + p.session_count, 0)}
                  </td>
                  <td class="p-4 text-right font-bold text-slate-900">
                    {providerDetails.reduce((sum, p) => sum + p.total_minutes, 0)}
                  </td>
                  <td class="p-4 text-right font-bold text-fsc-navy-900">
                    {formatCurrency(providerDetails.reduce((sum, p) => sum + p.total_amount, 0))}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Actions -->
          <div class="mt-8 flex gap-3">
            {#if selectedCycle.status === 'draft'}
              <button
                class="flex-1 rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
              >
                Send for Approval
              </button>
            {:else if selectedCycle.status === 'approved'}
              <button
                onclick={() => markAsPaid(selectedCycle.id)}
                class="flex-1 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
              >
                Mark as Paid
              </button>
            {/if}
            <button
              onclick={() => exportPayroll(selectedCycle.id)}
              class="flex-1 rounded-xl border-2 border-slate-300 bg-white px-6 py-3 font-semibold text-slate-700 transition-all hover:bg-slate-50"
            >
              Export PDF
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
{/if}
