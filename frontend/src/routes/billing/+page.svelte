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
  <h1 class="text-2xl font-semibold">Billing Queue (Preview)</h1>
  <p class="mt-2 text-sm text-gray-600 max-w-2xl">This section will surface sessions that are ready for claim submission, highlight missing note status, and show payer-specific batching rules.</p>

  {#if loading}
    <div class="mt-10 flex items-center gap-3 text-sm text-gray-500"><Spinner /> <span>Loading…</span></div>
  {:else}
    <div class="mt-8 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <p class="text-sm text-gray-700">No billing items yet. After you import sessions and they pass validation, they will appear here.</p>
    </div>
  {/if}
</section>
