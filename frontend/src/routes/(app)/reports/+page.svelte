<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { env } from '$env/dynamic/public';

  type ProviderMetric = {
    id: string;
    name: string;
    sessions: number;
    billed: number;
    collected: number;
    collection_rate: number;
  };

  type PayerMetric = {
    id: string;
    name: string;
    sessions: number;
    billed: number;
    collected: number;
    collection_rate: number;
  };

  let providers = $state<ProviderMetric[]>([]);
  let payers = $state<PayerMetric[]>([]);
  let loading = $state(true);
  let activeTab = $state<'providers' | 'payers' | 'revenue'>('providers');

  $effect(() => {
    (async () => {
      loading = true;

      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session?.access_token) {
          loading = false;
          return;
        }

        // Fetch provider metrics
        const providersResponse = await fetch(`${env.PUBLIC_API_BASE}/api/metrics/providers`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (providersResponse.ok) {
          const data = await providersResponse.json();
          providers = data.providers || [];
        }

        // Fetch payer metrics
        const payersResponse = await fetch(`${env.PUBLIC_API_BASE}/api/metrics/payers`, {
          headers: {
            'Authorization': `Bearer ${session.access_token}`
          }
        });

        if (payersResponse.ok) {
          const data = await payersResponse.json();
          payers = data.payers || [];
        }
      } catch (error) {
        console.error('Error loading reports data:', error);
      }

      loading = false;
    })();
  });

  const formatCurrency = (value: number) => {
    return `$${value.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}`;
  };
</script>

<div class="space-y-6">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-3xl font-bold text-fsc-navy-900">Reports & Analytics</h1>
      <p class="mt-1 text-slate-600">
        Provider performance, payer analysis, and revenue insights
      </p>
    </div>
  </div>

  {#if loading}
    <div class="flex flex-col items-center justify-center py-20">
      <div class="spinner mb-4 h-8 w-8 border-4"></div>
      <p class="text-slate-600">Loading reports...</p>
    </div>
  {:else}
    <!-- Tabs -->
    <div class="border-b border-slate-200">
      <nav class="flex gap-4">
        <button
          onclick={() => activeTab = 'providers'}
          class="border-b-2 px-4 py-3 text-sm font-semibold transition-colors {activeTab === 'providers' ? 'border-blue-600 text-blue-600' : 'border-transparent text-slate-600 hover:text-slate-900'}"
        >
          Provider Performance
        </button>
        <button
          onclick={() => activeTab = 'payers'}
          class="border-b-2 px-4 py-3 text-sm font-semibold transition-colors {activeTab === 'payers' ? 'border-blue-600 text-blue-600' : 'border-transparent text-slate-600 hover:text-slate-900'}"
        >
          Payer Analysis
        </button>
      </nav>
    </div>

    <!-- Provider Performance Tab -->
    {#if activeTab === 'providers'}
      <div class="space-y-6">
        <!-- Summary Stats -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
            <p class="text-sm font-medium text-slate-600">Total Providers</p>
            <p class="mt-2 text-3xl font-bold text-slate-900">{providers.length}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
            <p class="text-sm font-medium text-slate-600">Total Sessions</p>
            <p class="mt-2 text-3xl font-bold text-blue-600">
              {providers.reduce((sum, p) => sum + p.sessions, 0)}
            </p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
            <p class="text-sm font-medium text-slate-600">Total Billed</p>
            <p class="mt-2 text-3xl font-bold text-emerald-600">
              {formatCurrency(providers.reduce((sum, p) => sum + p.billed, 0))}
            </p>
          </div>
        </div>

        <!-- Provider Table -->
        <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
          <div class="border-b border-slate-200 p-6">
            <h2 class="text-lg font-semibold text-fsc-navy-900">Provider Performance</h2>
            <p class="mt-1 text-sm text-slate-600">Sessions, billing, and collection metrics by provider</p>
          </div>
          {#if providers.length === 0}
            <div class="flex flex-col items-center justify-center py-12 text-center">
              <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <p class="text-slate-600">No provider data available</p>
              <p class="mt-1 text-sm text-slate-500">Import sessions to see provider metrics</p>
            </div>
          {:else}
            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
                  <tr>
                    <th class="p-4 text-left font-semibold">Provider</th>
                    <th class="p-4 text-right font-semibold">Sessions</th>
                    <th class="p-4 text-right font-semibold">Billed</th>
                    <th class="p-4 text-right font-semibold">Collected</th>
                    <th class="p-4 text-right font-semibold">Collection Rate</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  {#each providers as provider}
                    <tr class="transition-colors hover:bg-slate-50">
                      <td class="p-4 font-medium text-slate-900">{provider.name}</td>
                      <td class="p-4 text-right text-slate-700">{provider.sessions}</td>
                      <td class="p-4 text-right text-blue-600">{formatCurrency(provider.billed)}</td>
                      <td class="p-4 text-right text-emerald-600">{formatCurrency(provider.collected)}</td>
                      <td class="p-4 text-right">
                        <span class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-semibold {provider.collection_rate >= 80 ? 'bg-emerald-100 text-emerald-700' : provider.collection_rate >= 60 ? 'bg-amber-100 text-amber-700' : 'bg-red-100 text-red-700'}">
                          {provider.collection_rate}%
                        </span>
                      </td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          {/if}
        </div>
      </div>
    {/if}

    <!-- Payer Analysis Tab -->
    {#if activeTab === 'payers'}
      <div class="space-y-6">
        <!-- Summary Stats -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
            <p class="text-sm font-medium text-slate-600">Total Payers</p>
            <p class="mt-2 text-3xl font-bold text-slate-900">{payers.length}</p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
            <p class="text-sm font-medium text-slate-600">Total Sessions</p>
            <p class="mt-2 text-3xl font-bold text-blue-600">
              {payers.reduce((sum, p) => sum + p.sessions, 0)}
            </p>
          </div>
          <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
            <p class="text-sm font-medium text-slate-600">Total Billed</p>
            <p class="mt-2 text-3xl font-bold text-emerald-600">
              {formatCurrency(payers.reduce((sum, p) => sum + p.billed, 0))}
            </p>
          </div>
        </div>

        <!-- Payer Table -->
        <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
          <div class="border-b border-slate-200 p-6">
            <h2 class="text-lg font-semibold text-fsc-navy-900">Payer Analysis</h2>
            <p class="mt-1 text-sm text-slate-600">Sessions, billing, and collection metrics by payer</p>
          </div>
          {#if payers.length === 0}
            <div class="flex flex-col items-center justify-center py-12 text-center">
              <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
                </svg>
              </div>
              <p class="text-slate-600">No payer data available</p>
              <p class="mt-1 text-sm text-slate-500">Import sessions to see payer metrics</p>
            </div>
          {:else}
            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
                  <tr>
                    <th class="p-4 text-left font-semibold">Payer</th>
                    <th class="p-4 text-right font-semibold">Sessions</th>
                    <th class="p-4 text-right font-semibold">Billed</th>
                    <th class="p-4 text-right font-semibold">Collected</th>
                    <th class="p-4 text-right font-semibold">Collection Rate</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  {#each payers as payer}
                    <tr class="transition-colors hover:bg-slate-50">
                      <td class="p-4 font-medium text-slate-900">
                        {#if payer.id === 'unassigned'}
                          <span class="text-slate-500 italic">{payer.name}</span>
                        {:else}
                          {payer.name}
                        {/if}
                      </td>
                      <td class="p-4 text-right text-slate-700">{payer.sessions}</td>
                      <td class="p-4 text-right text-blue-600">{formatCurrency(payer.billed)}</td>
                      <td class="p-4 text-right text-emerald-600">{formatCurrency(payer.collected)}</td>
                      <td class="p-4 text-right">
                        <span class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-semibold {payer.collection_rate >= 80 ? 'bg-emerald-100 text-emerald-700' : payer.collection_rate >= 60 ? 'bg-amber-100 text-amber-700' : 'bg-red-100 text-red-700'}">
                          {payer.collection_rate}%
                        </span>
                      </td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          {/if}
        </div>
      </div>
    {/if}
  {/if}
</div>
