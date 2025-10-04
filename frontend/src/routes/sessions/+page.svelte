<script lang="ts">
  import { supabase } from '$lib/supabaseClient';

  type Session = {
    id: string;
    session_date: string;
    client_id: string;
    provider_id: string;
    minutes: number | null;
    note_submitted: boolean;
    clients?: { name: string };
    providers?: { name: string };
  };

  let rows = $state<Session[]>([]);
  let q = $state('');
  let loading = $state(true);

  $effect(() => {
    (async () => {
      loading = true;
      const { data } = await supabase
        .from('sessions')
        .select(`
          id,
          session_date,
          client_id,
          provider_id,
          minutes,
          note_submitted,
          clients(name),
          providers(name)
        `)
        .order('session_date', { ascending: false })
        .limit(50);
      rows = (data as unknown as Session[]) ?? [];
      loading = false;
    })();
  });

  const filtered = () => {
    if (!q) return rows;
    const search = q.toLowerCase();
    return rows.filter(r => {
      const clientName = r.clients?.name ?? '';
      const providerName = r.providers?.name ?? '';
      const date = r.session_date ?? '';
      return [clientName, providerName, date].join(' ').toLowerCase().includes(search);
    });
  };

  const formatStatus = (noteSubmitted: boolean) => noteSubmitted ? 'Submitted' : 'Pending';
</script>

<h1 class="text-xl font-semibold mb-3">Sessions</h1>
<input class="mb-3 w-full border rounded px-3 py-2" placeholder="Search by client, provider, or date…" bind:value={q} />

<div class="bg-white rounded shadow overflow-hidden">
  {#if loading}
    <div class="p-8 text-center text-slate-500">Loading sessions...</div>
  {:else if filtered().length === 0}
    <div class="p-8 text-center text-slate-500">No sessions found</div>
  {:else}
    <table class="w-full text-sm">
      <thead class="bg-slate-50 text-slate-600">
        <tr>
          <th class="text-left p-3">Date</th>
          <th class="text-left p-3">Client</th>
          <th class="text-left p-3">Provider</th>
          <th class="text-left p-3">Minutes</th>
          <th class="p-3">Note Status</th>
        </tr>
      </thead>
      <tbody>
        {#each filtered() as r}
          <tr class="border-t">
            <td class="p-3">{r.session_date}</td>
            <td class="p-3">{r.clients?.name ?? 'Unknown'}</td>
            <td class="p-3">{r.providers?.name ?? 'Unknown'}</td>
            <td class="p-3">{r.minutes ?? '-'}</td>
            <td class="p-3">
              <span class="px-2 py-1 text-xs rounded {r.note_submitted ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}">
                {formatStatus(r.note_submitted)}
              </span>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</div>
