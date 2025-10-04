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

  $effect(async () => {
    loadingPayers = true;
    const { data } = await supabase
      .from('payers')
      .select('id, name, billing_route, status')
      .eq('status', 'Active')
      .order('name');
    payers = (data as Payer[]) ?? [];
    loadingPayers = false;
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
      const res = await fetch(api('/api/imports/simplepractice'), {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` },
        body
      });

      if (!res.ok) {
        const detail = await res.text();
        throw new Error(detail || res.statusText);
      }

      const data = await res.json();
      result = data as ImportResult;
      msg = `Success! Imported ${data.inserted} sessions, updated ${data.updated}, flagged ${data.flagged}.`;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Upload failed.';
      msg = `Error: ${message}`;
    } finally {
      uploading = false;
    }
  }
</script>

<h1 class="text-xl font-semibold mb-4">Import SimplePractice CSV</h1>

<div class="bg-white rounded shadow p-4 space-y-4 max-w-3xl">
  <div class="text-sm text-slate-600">
    Upload last week's export. We'll de-dupe, tag payer routes, and flag anything odd.
  </div>

  <div class="flex items-center gap-3">
    <input type="file" accept=".csv" on:change={(e:any) => file = e.target.files?.[0] ?? null}
           class="block w-full text-sm file:mr-3 file:px-3 file:py-2 file:rounded file:bg-slate-100 file:border file:text-slate-600" />
    <button class="rounded bg-blue-600 text-white px-4 py-2 disabled:opacity-50" on:click={upload} disabled={uploading}>
      {uploading ? 'Uploading…' : 'Upload'}
    </button>
  </div>

  {#if msg}
    <p class="text-sm" class:text-red-600={msg.includes('Error')} class:text-green-600={msg.includes('Success')}>
      {msg}
    </p>
  {/if}

  {#if result?.flagged_preview && result.flagged_preview.length > 0}
    <div class="mt-4 border-t pt-4">
      <h3 class="font-semibold text-sm mb-2">Flagged Rows Preview</h3>
      <div class="text-xs space-y-2">
        {#each result.flagged_preview as flagged}
          <div class="bg-amber-50 border border-amber-200 rounded p-2">
            <div class="font-medium text-amber-800">{flagged.reason.replace('_', ' ')}</div>
            <div class="text-slate-600 mt-1">
              {flagged.client_name ?? 'N/A'} • {flagged.provider_name ?? 'N/A'} • {flagged.service_date ?? 'N/A'}
            </div>
          </div>
        {/each}
      </div>
    </div>
  {/if}
</div>

<div class="mt-8 max-w-3xl">
  <h2 class="text-lg font-semibold mb-3">Active Payers & Routes</h2>
  {#if loadingPayers}
    <p class="text-sm text-slate-500">Loading payers...</p>
  {:else if payers.length === 0}
    <p class="text-sm text-slate-500">No active payers found. Add payers in Supabase.</p>
  {:else}
    <div class="bg-white rounded shadow overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-slate-50 text-slate-600">
          <tr>
            <th class="text-left p-3">Payer</th>
            <th class="text-left p-3">Billing Route</th>
          </tr>
        </thead>
        <tbody>
          {#each payers as payer}
            <tr class="border-t">
              <td class="p-3">{payer.name}</td>
              <td class="p-3">
                <span class="px-2 py-1 rounded text-xs {payer.billing_route === 'portal' ? 'bg-blue-100 text-blue-700' : 'bg-slate-100 text-slate-700'}">
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
