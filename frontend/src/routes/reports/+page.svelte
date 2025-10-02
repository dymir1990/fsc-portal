<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import Spinner from '$lib/Spinner.svelte';
  let user: any = null;
  let loading = true;

  onMount(async () => {
    const { data } = await supabase.auth.getUser();
    if (!data.user) {
      window.location.href = '/login';
    } else {
      user = data.user;
      loading = false;
    }
  });
</script>

<section class="mx-auto max-w-5xl p-6">
  <h1 class="text-2xl font-semibold">Reports (Preview)</h1>
  <p class="mt-2 text-sm text-gray-600 max-w-2xl">Future space for productivity, billing velocity, and payer mix analytics. Data comes directly from Supabase tables (sessions, import_runs, payers).</p>

  {#if loading}
    <div class="mt-10 flex items-center gap-3 text-sm text-gray-500"><Spinner /> <span>Loading…</span></div>
  {:else}
    <div class="mt-8 grid gap-6 md:grid-cols-3">
      <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
        <p class="text-xs uppercase tracking-wide text-slate-500 mb-1">Example</p>
        <p class="text-lg font-semibold text-slate-800">Sessions Imported</p>
        <p class="text-sm text-slate-500 mt-2">Coming soon.</p>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
        <p class="text-xs uppercase tracking-wide text-slate-500 mb-1">Example</p>
        <p class="text-lg font-semibold text-slate-800">Flag Rate</p>
        <p class="text-sm text-slate-500 mt-2">Coming soon.</p>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
        <p class="text-xs uppercase tracking-wide text-slate-500 mb-1">Example</p>
        <p class="text-lg font-semibold text-slate-800">Duplicate %</p>
        <p class="text-sm text-slate-500 mt-2">Coming soon.</p>
      </div>
    </div>
  {/if}
</section>
