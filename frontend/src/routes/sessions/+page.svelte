<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  let rows = $state<{ client_name:string, provider_name:string, status:string }[]>([]);
  let q = $state('');

  $effect(async () => {
    // simple fetch; later add pagination + filters
    const { data } = await supabase.from('sessions').select('client_name,provider_name,status').limit(25);
    rows = data ?? [];
  });

  const filtered = () => rows.filter(r =>
    [r.client_name, r.provider_name, r.status].join(' ').toLowerCase().includes(q.toLowerCase())
  );
</script>

<h1 class="text-xl font-semibold mb-3">Sessions</h1>
<input class="mb-3 w-full border rounded px-3 py-2" placeholder="Search…" bind:value={q} />

<div class="bg-white rounded shadow overflow-hidden">
  <table class="w-full text-sm">
    <thead class="bg-slate-50 text-slate-600">
      <tr><th class="text-left p-3">Client</th><th class="text-left p-3">Provider</th><th class="p-3">Status</th></tr>
    </thead>
    <tbody>
      {#each filtered() as r}
        <tr class="border-t">
          <td class="p-3">{r.client_name}</td>
          <td class="p-3">{r.provider_name}</td>
          <td class="p-3">{r.status}</td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>
