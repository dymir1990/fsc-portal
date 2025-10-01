<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import { PUBLIC_BACKEND_URL } from '$env/static/public';

  // Minimal client-side state for demo
  let selectedPayer = '';
  let file: File | null = null;
  let msg = '';
  let flaggedPreview: { reason: string; provider_name?: string | null; client_name?: string | null; service_date?: string | null }[] = [];

  // If you already load payers from Supabase in +page.server.ts,
  // accept them via `export let data`. Otherwise fallback list below.
  export let data: { payers?: { name: string, portal?: string }[] } = {};
  const fallbackPayers = [
    { name: 'Aetna',        portal: 'Aetna Provider Portal' },
    { name: 'Horizon BCBS', portal: 'Availity' },
    { name: 'United',       portal: 'UHC Provider Portal' },
    { name: 'Medicaid NJ',  portal: 'NJ MMIS' },
  ];
  let payers: { name: string; portal?: string }[] = data?.payers?.length ? data.payers : fallbackPayers;

  // Load payers from Supabase on mount (reads public.payers)
  onMount(async () => {
    try {
      const { data: rows, error } = await supabase
        .from('payers')
        .select('name, portal')
        .order('name');
      if (!error && rows && rows.length) {
        payers = rows as any;
      }
    } catch { /* non-fatal for UI */ }
  });

  async function upload() {
    if (!file) { msg = 'Please choose a CSV file.'; return; }
    msg = 'Uploading…';
    flaggedPreview = [];

    try {
      // Acquire Supabase session token for backend auth
      const { data: sessionData } = await supabase.auth.getSession();
      const token = sessionData?.session?.access_token;
      if (!token) {
        msg = '❌ Not signed in. Please log in first.';
        return;
      }

      // POST to backend import endpoint with bearer token
      const form = new FormData();
      form.append('file', file);
      const res = await fetch(`${PUBLIC_BACKEND_URL}/api/imports/simplepractice`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` },
        body: form
      });

      if (!res.ok) {
        const text = await res.text();
        throw new Error(text || `HTTP ${res.status}`);
      }

      const json = await res.json();
      msg = `✅ Imported: total ${json.total} | inserted ${json.inserted} | updated ${json.updated} | flagged ${json.flagged}`;
      flaggedPreview = json.flagged_preview ?? [];
    } catch (e:any) {
      msg = `❌ Upload failed: ${e.message ?? e}`;
    }
  }
</script>

<!-- Top bar -->
<header class="sticky top-0 z-10 bg-white/80 backdrop-blur border-b border-slate-200">
  <div class="mx-auto max-w-7xl px-6 py-4 flex items-center justify-between">
    <div class="flex items-center gap-3">
      <div class="size-9 rounded-full bg-emerald-600 flex items-center justify-center text-white font-bold">FS</div>
      <h1 class="text-lg font-semibold text-slate-800">FSC Portal</h1>
    </div>
    <nav class="text-sm text-slate-500">
      <a href="/dashboard" class="hover:text-slate-800">Dashboard</a>
      <span class="mx-3">•</span>
      <span class="text-slate-800 font-medium">Import</span>
    </nav>
  </div>
</header>

<main class="mx-auto max-w-7xl px-6 py-8 grid grid-cols-1 lg:grid-cols-[260px_1fr] gap-6">
  <!-- Side panel -->
  <aside class="lg:pt-2">
    <div class="rounded-2xl bg-white border border-slate-200 shadow-sm p-5">
      <p class="text-xs uppercase tracking-wide text-slate-500 mb-2">Quick Links</p>
      <ul class="space-y-2 text-sm">
        <li><a class="text-slate-700 hover:text-emerald-700" href="/dashboard">Overview</a></li>
        <li><a class="text-emerald-700 font-medium" href="/case-manager/import">Import CSV</a></li>
        <li><a class="text-slate-700 hover:text-emerald-700" href="/billing">Billing queue</a></li>
        <li><a class="text-slate-700 hover:text-emerald-700" href="/reports">Reports</a></li>
      </ul>
    </div>
  </aside>

  <!-- Content card -->
  <section class="space-y-6">
    <div class="rounded-2xl bg-white border border-slate-200 shadow-sm">
      <div class="px-6 pt-6 pb-4 border-b border-slate-100">
        <h2 class="text-xl font-semibold text-slate-900">Import SimplePractice CSV</h2>
        <p class="text-sm text-slate-500 mt-1">
          Upload last week’s export. We’ll check duplicates, update Supabase, and flag anything that needs attention before billing.
        </p>
      </div>

      <div class="p-6 space-y-6">
        <!-- Payer reference box -->
        <div class="rounded-xl border border-slate-200 p-5 bg-slate-50">
          <div class="flex items-start justify-between gap-4">
            <div>
              <p class="text-sm font-medium text-slate-800">Billing routes reference</p>
              <p class="text-xs text-slate-500 mt-1">
                Synced from Supabase (<code>public.payers</code>). Confirm the correct portal before you tag sessions.
              </p>
            </div>
          </div>

          <div class="mt-4 grid gap-4 sm:grid-cols-2">
            <label class="block">
              <span class="block text-xs font-medium text-slate-600 mb-1">Browse payers</span>
              <select bind:value={selectedPayer}
                      class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500">
                <option value="">Select payer…</option>
                {#each payers as p}
                  <option value={p.name}>{p.name}</option>
                {/each}
              </select>
            </label>

            <div class="rounded-lg border border-slate-200 bg-white p-3">
              <p class="text-xs text-slate-500">Portal</p>
              <p class="text-sm font-medium text-slate-800">
                {#if selectedPayer}
                  {#each payers as p}
                    {#if p.name === selectedPayer}
                      {p.portal ?? '—'}
                    {/if}
                  {/each}
                {:else}
                  —
                {/if}
              </p>
            </div>
          </div>
        </div>

        <!-- Upload form -->
        <div class="rounded-xl border border-dashed border-slate-300 bg-slate-50 p-6 text-center">
          <p class="text-sm text-slate-700 mb-3">Drop your <span class="font-semibold">SimplePractice CSV</span> here, or choose a file.</p>
          <div class="flex items-center justify-center gap-3">
            <input
              type="file"
              accept=".csv,text/csv"
              on:change={(e: Event) => { const t = e.target as HTMLInputElement; file = t.files?.[0] ?? null; }}
              class="block w-full max-w-sm text-sm file:mr-3 file:rounded-md file:border-0 file:bg-emerald-600 file:px-4 file:py-2 file:text-white file:cursor-pointer file:hover:bg-emerald-700
                     file:transition file:duration-150 file:ease-out"
            />
            <button
              on:click|preventDefault={upload}
              class="inline-flex items-center gap-2 rounded-md bg-emerald-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500">
              Upload
            </button>
          </div>
          {#if msg}
            <p class="mt-4 text-sm {msg.startsWith('✅') ? 'text-emerald-700' : 'text-rose-700'}">{msg}</p>
          {/if}
        </div>

        {#if flaggedPreview?.length}
          <div class="rounded-xl border border-amber-200 bg-amber-50 p-4">
            <p class="text-sm font-medium text-amber-800 mb-2">Flagged preview (first {Math.min(10, flaggedPreview.length)})</p>
            <ul class="text-sm text-amber-900 grid gap-1">
              {#each flaggedPreview as r}
                <li>
                  <span class="font-medium">{r.reason}</span>
                  — {r.provider_name || 'unknown provider'} / {r.client_name || 'unknown client'} / {r.service_date || 'no date'}
                </li>
              {/each}
            </ul>
          </div>
        {/if}

        <!-- Help -->
        <p class="text-xs text-slate-500">
          Need to add a payer? Update <code>public.payers</code> in Supabase — this list refreshes automatically.
        </p>
      </div>
    </div>
  </section>
</main>
