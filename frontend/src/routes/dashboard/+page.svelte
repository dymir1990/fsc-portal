<script lang="ts">
  import { supabase } from '$lib/supabaseClient';

  type Session = {
    id: string;
    session_date: string;
    note_submitted: boolean;
    clients?: { name: string };
    providers?: { name: string };
  };

  type ImportRun = {
    id: string;
    source: string;
    file_name: string;
    started_at: string;
    total_rows: number;
    inserted_rows: number;
    flagged_rows: number;
  };

  let stats = $state({
    total: 0,
    pending: 0,
    submitted: 0,
    flagged: 0
  });

  let recentSessions = $state<Session[]>([]);
  let recentImports = $state<ImportRun[]>([]);
  let loading = $state(true);

  $effect(async () => {
    loading = true;

    // Fetch session stats
    const { data: sessions } = await supabase
      .from('sessions')
      .select('id, note_submitted')
      .limit(1000);

    if (sessions) {
      stats.total = sessions.length;
      stats.submitted = sessions.filter(s => s.note_submitted).length;
      stats.pending = sessions.filter(s => !s.note_submitted).length;
    }

    // Fetch flagged count from import staging
    const { count: flaggedCount } = await supabase
      .from('import_staging')
      .select('*', { count: 'exact', head: true });

    stats.flagged = flaggedCount ?? 0;

    // Fetch recent sessions with client/provider names
    const { data: recent } = await supabase
      .from('sessions')
      .select(`
        id,
        session_date,
        note_submitted,
        clients(name),
        providers(name)
      `)
      .order('imported_at', { ascending: false })
      .limit(10);

    recentSessions = (recent as Session[]) ?? [];

    // Fetch recent import runs
    const { data: imports } = await supabase
      .from('import_runs')
      .select('id, source, file_name, started_at, total_rows, inserted_rows, flagged_rows')
      .order('started_at', { ascending: false })
      .limit(5);

    recentImports = (imports as ImportRun[]) ?? [];

    loading = false;
  });

  const formatDate = (dateStr: string) => {
    try {
      return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    } catch {
      return dateStr;
    }
  };

  const formatStatus = (noteSubmitted: boolean) => noteSubmitted ? 'Submitted' : 'Pending';
</script>

<h1 class="text-xl font-semibold mb-4">Overview</h1>

{#if loading}
  <div class="text-center py-8 text-slate-500">Loading dashboard...</div>
{:else}
  <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
    <div class="bg-white rounded shadow p-4">
      <div class="text-sm text-slate-500">Total Sessions</div>
      <div class="text-2xl font-bold">{stats.total}</div>
    </div>
    <div class="bg-white rounded shadow p-4">
      <div class="text-sm text-slate-500">Pending Notes</div>
      <div class="text-2xl font-bold">{stats.pending}</div>
    </div>
    <div class="bg-white rounded shadow p-4">
      <div class="text-sm text-slate-500">Submitted</div>
      <div class="text-2xl font-bold">{stats.submitted}</div>
    </div>
    <div class="bg-white rounded shadow p-4">
      <div class="text-sm text-slate-500">Flagged</div>
      <div class="text-2xl font-bold">{stats.flagged}</div>
    </div>
  </div>

  {#if recentImports.length > 0}
    <h2 class="mt-8 mb-2 font-semibold">Recent Imports</h2>
    <div class="bg-white rounded shadow overflow-hidden mb-6">
      <table class="w-full text-sm">
        <thead class="bg-slate-50 text-slate-600">
          <tr>
            <th class="text-left p-3">File</th>
            <th class="text-left p-3">Date</th>
            <th class="text-right p-3">Total</th>
            <th class="text-right p-3">Inserted</th>
            <th class="text-right p-3">Flagged</th>
          </tr>
        </thead>
        <tbody>
          {#each recentImports as imp}
            <tr class="border-t">
              <td class="p-3">{imp.file_name}</td>
              <td class="p-3">{formatDate(imp.started_at)}</td>
              <td class="text-right p-3">{imp.total_rows}</td>
              <td class="text-right p-3">{imp.inserted_rows}</td>
              <td class="text-right p-3">{imp.flagged_rows}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}

  <h2 class="mt-8 mb-2 font-semibold">Recent Sessions</h2>
  <div class="bg-white rounded shadow overflow-hidden">
    {#if recentSessions.length === 0}
      <div class="p-8 text-center text-slate-500">No sessions yet. Import a CSV to get started.</div>
    {:else}
      <table class="w-full text-sm">
        <thead class="bg-slate-50 text-slate-600">
          <tr>
            <th class="text-left p-3">Date</th>
            <th class="text-left p-3">Client</th>
            <th class="text-left p-3">Provider</th>
            <th class="p-3">Status</th>
          </tr>
        </thead>
        <tbody>
          {#each recentSessions as session}
            <tr class="border-t">
              <td class="p-3">{formatDate(session.session_date)}</td>
              <td class="p-3">{session.clients?.name ?? 'Unknown'}</td>
              <td class="p-3">{session.providers?.name ?? 'Unknown'}</td>
              <td class="p-3">
                <span class="px-2 py-1 text-xs rounded {session.note_submitted ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}">
                  {formatStatus(session.note_submitted)}
                </span>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    {/if}
  </div>
{/if}
