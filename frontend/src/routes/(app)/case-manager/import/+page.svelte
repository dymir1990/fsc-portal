<script lang="ts">
  import { api, supabase } from '$lib';

  type Payer = {
    id: string;
    name: string;
    billing_route: string;
    status: string;
  };

  type ImportResult = {
    run_id: string;
    total: number;
    inserted: number;
    updated: number;
    flagged: number;
    errors: number;
    duplicates: number;
    flagged_preview?: Array<{
      reason: string;
      provider_name?: string;
      client_name?: string;
      service_date?: string;
    }>;
  };

  let file: File | null = null;
  let msg = $state('');
  let uploading = $state(false);
  let payers = $state<Payer[]>([]);
  let loadingPayers = $state(true);
  let result = $state<ImportResult | null>(null);

  $effect(() => {
    (async () => {
      loadingPayers = true;
      const { data } = await supabase
        .from('payers')
        .select('id, name, billing_route, status')
        .eq('status', 'Active')
        .order('name');
      payers = (data as Payer[]) ?? [];
      loadingPayers = false;
    })();
  });

  async function upload() {
    if (!file) { msg = 'Pick a CSV first.'; return; }

    const { data } = await supabase.auth.getSession();
    const token = data.session?.access_token;
    if (!token) {
      msg = 'Sign in again to upload.';
      return;
    }

    const body = new FormData();
    body.append('file', file);

    uploading = true;
    msg = 'Uploading…';
    result = null;

    try {
      const apiUrl = api('/api/imports/simplepractice');
      console.log('Uploading to:', apiUrl);

      const res = await fetch(apiUrl, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` },
        body
      });

      console.log('Response status:', res.status);

      if (!res.ok) {
        const detail = await res.text();
        console.error('Upload error:', detail);
        throw new Error(detail || res.statusText);
      }

      const data = await res.json();
      console.log('Upload result:', data);
      result = data as ImportResult;
      msg = `Success! Imported ${data.inserted} sessions, updated ${data.updated}, flagged ${data.flagged}.`;
    } catch (err) {
      console.error('Upload exception:', err);
      const message = err instanceof Error ? err.message : 'Upload failed.';
      msg = `Error: ${message}`;
    } finally {
      uploading = false;
    }
  }
</script>

<div class="space-y-8">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-3xl font-bold text-fsc-navy-900">Import CSV Data</h1>
      <p class="mt-1 text-slate-600">Upload weekly SimplePractice session exports</p>
    </div>
    <a
      href="/sessions"
      class="flex items-center gap-2 rounded-xl border-2 border-slate-200 bg-white px-6 py-2.5 text-sm font-semibold text-slate-700 transition-all hover:border-slate-300 hover:bg-slate-50"
    >
      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
      </svg>
      View Sessions
    </a>
  </div>

  <!-- Upload Section -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    <div class="border-b border-slate-200 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 p-6">
      <div class="flex items-start gap-4">
        <div class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-blue-500 text-white shadow-lg">
          <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
          </svg>
        </div>
        <div class="flex-1">
          <h2 class="text-lg font-semibold text-fsc-navy-900">Upload SimplePractice Export</h2>
          <p class="mt-1 text-sm text-slate-600">
            Upload last week's export. We'll de-duplicate, tag payer routes, and flag any issues automatically.
          </p>
        </div>
      </div>
    </div>

    <div class="space-y-6 p-6">
      <!-- File Input -->
      <div class="space-y-3">
        <label for="csv-upload" class="block text-sm font-semibold text-slate-700">
          Select CSV File
        </label>
        <div class="flex flex-col gap-3 sm:flex-row sm:items-center">
          <input
            id="csv-upload"
            type="file"
            accept=".csv"
            onchange={(e:any) => file = e.target.files?.[0] ?? null}
            class="block flex-1 rounded-xl border-2 border-slate-200 bg-white text-sm transition-all file:mr-4 file:rounded-lg file:border-0 file:bg-blue-50 file:px-4 file:py-2 file:text-sm file:font-semibold file:text-blue-700 hover:file:bg-blue-100 focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
          />
          <button
            class="group relative overflow-hidden rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-8 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:hover:scale-100 sm:w-auto"
            onclick={upload}
            disabled={uploading}
          >
            <span class="relative z-10">
              {#if uploading}
                <span class="inline-flex items-center gap-2">
                  <span class="spinner"></span>
                  Uploading...
                </span>
              {:else}
                Upload & Process
              {/if}
            </span>
            <div class="absolute inset-0 bg-gradient-to-r from-blue-700 to-teal-700 opacity-0 transition-opacity group-hover:opacity-100"></div>
          </button>
        </div>
      </div>

      <!-- Status Message -->
      {#if msg}
        <div class="rounded-xl border-2 p-4 {msg.includes('Error') ? 'border-red-200 bg-red-50 text-red-700' : msg.includes('Success') ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-blue-200 bg-blue-50 text-blue-700'}">
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0">
              {#if msg.includes('Error')}
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              {:else if msg.includes('Success')}
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              {:else}
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              {/if}
            </div>
            <p class="text-sm font-medium">{msg}</p>
          </div>
        </div>
      {/if}

      <!-- Results Summary -->
      {#if result}
        <div class="grid grid-cols-2 gap-4 rounded-xl border border-slate-200 bg-slate-50 p-4 sm:grid-cols-4">
          <div class="text-center">
            <div class="text-2xl font-bold text-fsc-navy-900">{result.inserted}</div>
            <div class="mt-1 text-xs text-slate-600">Inserted</div>
          </div>
          <div class="text-center">
            <div class="text-2xl font-bold text-blue-600">{result.updated}</div>
            <div class="mt-1 text-xs text-slate-600">Updated</div>
          </div>
          <div class="text-center">
            <div class="text-2xl font-bold text-amber-600">{result.flagged}</div>
            <div class="mt-1 text-xs text-slate-600">Flagged</div>
          </div>
          <div class="text-center">
            <div class="text-2xl font-bold text-slate-400">{result.duplicates}</div>
            <div class="mt-1 text-xs text-slate-600">Duplicates</div>
          </div>
        </div>
      {/if}

      <!-- Flagged Preview -->
      {#if result?.flagged_preview && result.flagged_preview.length > 0}
        <div class="space-y-3 rounded-xl border-2 border-amber-200 bg-amber-50 p-4">
          <div class="flex items-center gap-2">
            <svg class="h-5 w-5 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <h3 class="font-semibold text-amber-900">Flagged Items Preview</h3>
          </div>
          <div class="space-y-2">
            {#each result.flagged_preview as flagged}
              <div class="rounded-lg border border-amber-300 bg-white p-3">
                <div class="mb-2 flex items-start gap-2">
                  <span class="inline-flex items-center rounded-md bg-amber-100 px-2 py-1 text-xs font-medium text-amber-800">
                    {flagged.reason.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                  </span>
                </div>
                <div class="flex flex-wrap gap-x-4 gap-y-1 text-xs text-slate-600">
                  <span><strong>Client:</strong> {flagged.client_name ?? 'N/A'}</span>
                  <span><strong>Provider:</strong> {flagged.provider_name ?? 'N/A'}</span>
                  <span><strong>Date:</strong> {flagged.service_date ?? 'N/A'}</span>
                </div>
              </div>
            {/each}
          </div>
        </div>
      {/if}
    </div>
  </div>

  <!-- Active Payers Section -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    <div class="border-b border-slate-200 p-6">
      <h2 class="text-lg font-semibold text-fsc-navy-900">Active Payers & Billing Routes</h2>
      <p class="mt-1 text-sm text-slate-600">Current payer configuration for automatic routing</p>
    </div>

    {#if loadingPayers}
      <div class="flex flex-col items-center justify-center py-12">
        <div class="spinner mb-4 h-8 w-8 border-4"></div>
        <p class="text-slate-600">Loading payers...</p>
      </div>
    {:else if payers.length === 0}
      <div class="flex flex-col items-center justify-center py-12 text-center">
        <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
          <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
          </svg>
        </div>
        <p class="text-slate-600">No active payers found</p>
        <p class="mt-1 text-sm text-slate-500">Add payers in Supabase to enable automatic routing</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
            <tr>
              <th class="p-4 text-left font-semibold">Payer Name</th>
              <th class="p-4 text-left font-semibold">Billing Route</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            {#each payers as payer}
              <tr class="transition-colors hover:bg-slate-50">
                <td class="p-4 font-medium text-slate-900">{payer.name}</td>
                <td class="p-4">
                  <span class="inline-flex items-center gap-1 rounded-lg px-3 py-1 text-xs font-semibold {payer.billing_route === 'portal' ? 'bg-blue-100 text-blue-700' : payer.billing_route === 'email' ? 'bg-purple-100 text-purple-700' : 'bg-slate-100 text-slate-700'}">
                    {#if payer.billing_route === 'portal'}
                      <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
                      </svg>
                    {:else if payer.billing_route === 'email'}
                      <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                      </svg>
                    {:else}
                      <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                    {/if}
                    {payer.billing_route}
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
