<script lang="ts">
  import { supabase } from '$lib/supabaseClient';

  type Payer = {
    id: string;
    name: string;
    billing_route: string;
    portal_url: string | null;
    status: string;
    notes: string | null;
  };

  let payers = $state<Payer[]>([]);
  let loading = $state(true);
  let searchQuery = $state('');
  let selectedPayer = $state<Payer | null>(null);

  $effect(() => {
    (async () => {
      loading = true;
      const { data } = await supabase
        .from('payers')
        .select('*')
        .order('name');
      payers = (data as Payer[]) ?? [];
      loading = false;
    })();
  });

  const filtered = () => {
    if (!searchQuery) return payers;
    const search = searchQuery.toLowerCase();
    return payers.filter(p => p.name.toLowerCase().includes(search));
  };

  const counts = $derived({
    total: payers.length,
    active: payers.filter(p => p.status === 'Active').length,
    portal: payers.filter(p => p.billing_route === 'portal').length,
    email: payers.filter(p => p.billing_route === 'email').length
  });

  const openDrawer = (payer: Payer) => {
    selectedPayer = payer;
  };

  const closeDrawer = () => {
    selectedPayer = null;
  };

  const getBillingRouteColor = (route: string) => {
    if (route === 'portal') return 'bg-blue-100 text-blue-700';
    if (route === 'email') return 'bg-purple-100 text-purple-700';
    return 'bg-slate-100 text-slate-700';
  };

  const getBillingRouteIcon = (route: string) => {
    if (route === 'portal') {
      return 'M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9';
    }
    if (route === 'email') {
      return 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z';
    }
    return 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z';
  };
</script>

<div class="space-y-6">
  <!-- Stats -->
  <div class="grid grid-cols-1 gap-4 sm:grid-cols-4">
    <div class="rounded-xl border border-slate-200 bg-white p-4">
      <div class="text-2xl font-bold text-fsc-navy-900">{counts.total}</div>
      <div class="text-sm text-slate-600">Total Payers</div>
    </div>
    <div class="rounded-xl border border-slate-200 bg-white p-4">
      <div class="text-2xl font-bold text-emerald-600">{counts.active}</div>
      <div class="text-sm text-slate-600">Active</div>
    </div>
    <div class="rounded-xl border border-slate-200 bg-white p-4">
      <div class="text-2xl font-bold text-blue-600">{counts.portal}</div>
      <div class="text-sm text-slate-600">Portal Billing</div>
    </div>
    <div class="rounded-xl border border-slate-200 bg-white p-4">
      <div class="text-2xl font-bold text-purple-600">{counts.email}</div>
      <div class="text-sm text-slate-600">Email Billing</div>
    </div>
  </div>

  <!-- Search & Actions -->
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
        placeholder="Search payers..."
        bind:value={searchQuery}
      />
    </div>

    <button
      class="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
    >
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
      Add Payer
    </button>
  </div>

  <!-- Payers Table -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    {#if loading}
      <div class="flex flex-col items-center justify-center py-16">
        <div class="spinner mb-4 h-8 w-8 border-4"></div>
        <p class="text-slate-600">Loading payers...</p>
      </div>
    {:else if filtered().length === 0}
      <div class="flex flex-col items-center justify-center py-16 text-center">
        <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
          <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
          </svg>
        </div>
        <p class="text-slate-600">No payers found</p>
        <p class="mt-1 text-sm text-slate-500">Try adjusting your search</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
            <tr>
              <th class="p-4 text-left font-semibold">Payer Name</th>
              <th class="p-4 text-left font-semibold">Billing Route</th>
              <th class="p-4 text-left font-semibold">Portal URL</th>
              <th class="p-4 text-center font-semibold">Status</th>
              <th class="p-4"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            {#each filtered() as payer}
              <tr class="transition-colors hover:bg-slate-50">
                <td class="p-4 font-medium text-slate-900">{payer.name}</td>
                <td class="p-4">
                  <span class="inline-flex items-center gap-1.5 rounded-lg px-3 py-1 text-xs font-semibold {getBillingRouteColor(payer.billing_route)}">
                    <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getBillingRouteIcon(payer.billing_route)} />
                    </svg>
                    {payer.billing_route}
                  </span>
                </td>
                <td class="p-4">
                  {#if payer.portal_url}
                    <a
                      href={payer.portal_url}
                      target="_blank"
                      class="flex items-center gap-1 text-blue-600 hover:text-blue-700"
                    >
                      <span class="text-sm">Open Portal</span>
                      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                      </svg>
                    </a>
                  {:else}
                    <span class="text-xs text-slate-400">-</span>
                  {/if}
                </td>
                <td class="p-4 text-center">
                  <span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold {payer.status === 'Active' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-700'}">
                    {payer.status}
                  </span>
                </td>
                <td class="p-4">
                  <button
                    onclick={() => openDrawer(payer)}
                    class="rounded-lg p-2 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-600"
                  >
                    <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
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

<!-- Payer Detail Drawer -->
{#if selectedPayer}
  <div class="fixed inset-0 z-50 overflow-y-auto">
    <div class="flex min-h-screen items-end justify-center px-4 pb-20 pt-4 text-center sm:block sm:p-0">
      <div class="fixed inset-0 bg-slate-900 bg-opacity-75 transition-opacity" onclick={closeDrawer}></div>

      <div class="inline-block transform overflow-hidden rounded-t-2xl bg-white text-left align-bottom shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:rounded-2xl sm:align-middle">
        <div class="border-b border-slate-200 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 px-6 py-4">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-fsc-navy-900">Payer Details</h3>
            <button
              onclick={closeDrawer}
              class="rounded-lg p-2 text-slate-400 transition-colors hover:bg-white hover:text-slate-600"
            >
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <div class="space-y-6 p-6">
          <div>
            <label class="block text-sm font-semibold text-slate-700">Payer Name</label>
            <div class="mt-2 text-lg font-medium text-slate-900">{selectedPayer.name}</div>
          </div>

          <div>
            <label class="block text-sm font-semibold text-slate-700">Billing Route</label>
            <div class="mt-2">
              <span class="inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm font-semibold {getBillingRouteColor(selectedPayer.billing_route)}">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getBillingRouteIcon(selectedPayer.billing_route)} />
                </svg>
                {selectedPayer.billing_route}
              </span>
            </div>
          </div>

          {#if selectedPayer.portal_url}
            <div>
              <label class="block text-sm font-semibold text-slate-700">Portal URL</label>
              <a
                href={selectedPayer.portal_url}
                target="_blank"
                class="mt-2 flex items-center gap-2 text-blue-600 hover:text-blue-700"
              >
                <span class="break-all text-sm">{selectedPayer.portal_url}</span>
                <svg class="h-4 w-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
              </a>
            </div>
          {/if}

          {#if selectedPayer.notes}
            <div>
              <label class="block text-sm font-semibold text-slate-700">Notes</label>
              <div class="mt-2 rounded-lg border border-slate-200 bg-slate-50 p-3 text-sm text-slate-700">
                {selectedPayer.notes}
              </div>
            </div>
          {/if}

          <div>
            <label class="block text-sm font-semibold text-slate-700">Status</label>
            <div class="mt-2">
              <span class="inline-flex items-center rounded-full px-3 py-1 text-sm font-semibold {selectedPayer.status === 'Active' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-700'}">
                {selectedPayer.status}
              </span>
            </div>
          </div>

          <button
            class="w-full rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
          >
            Edit Payer Info
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}
