<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import StatusBadge from '$lib/components/StatusBadge.svelte';

  type BillingTask = {
    id: string;
    session_date: string;
    client_id: string;
    provider_id: string;
    minutes: number | null;
    case_status: string;
    auth_number: string | null;
    claim_number: string | null;
    submission_date: string | null;
    notes: string | null;
    clients?: { name: string };
    providers?: { name: string };
    payers?: { name: string; billing_route: string; portal_url: string };
  };

  let tasks = $state<BillingTask[]>([]);
  let loading = $state(true);
  let filterView = $state<'this_week' | 'overdue' | 'all'>('this_week');
  let selectedTask = $state<BillingTask | null>(null);

  // Simulated current user - in production, fetch from auth
  const currentUserId = 'billing-user-1';

  $effect(() => {
    (async () => {
      loading = true;
      // Fetch sessions assigned to current user
      const { data } = await supabase
        .from('sessions')
        .select(`
          id,
          session_date,
          client_id,
          provider_id,
          minutes,
          case_status,
          auth_number,
          claim_number,
          submission_date,
          notes,
          clients(name),
          providers(name),
          payers(name, billing_route, portal_url)
        `)
        .eq('assigned_to', currentUserId)
        .order('session_date', { ascending: false })
        .limit(50);
      tasks = (data as unknown as BillingTask[]) ?? [];
      loading = false;
    })();
  });

  const filtered = () => {
    const now = new Date();
    const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    if (filterView === 'this_week') {
      return tasks.filter(t => new Date(t.session_date) >= oneWeekAgo);
    } else if (filterView === 'overdue') {
      return tasks.filter(t => t.case_status !== 'submitted' && t.case_status !== 'paid');
    }
    return tasks;
  };

  const counts = $derived({
    this_week: tasks.filter(t => {
      const now = new Date();
      const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      return new Date(t.session_date) >= oneWeekAgo;
    }).length,
    overdue: tasks.filter(t => t.case_status !== 'submitted' && t.case_status !== 'paid').length,
    all: tasks.length
  });

  const formatDate = (dateStr: string) => {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  const openDrawer = (task: BillingTask) => {
    selectedTask = task;
  };

  const closeDrawer = () => {
    selectedTask = null;
  };

  async function markAsSubmitted(taskId: string) {
    await supabase
      .from('sessions')
      .update({ case_status: 'submitted', submission_date: new Date().toISOString() })
      .eq('id', taskId);

    // Refresh tasks
    tasks = tasks.map(t => t.id === taskId ? { ...t, case_status: 'submitted', submission_date: new Date().toISOString() } : t);
    closeDrawer();
  }

  async function markAsPaid(taskId: string) {
    await supabase
      .from('sessions')
      .update({ case_status: 'paid' })
      .eq('id', taskId);

    tasks = tasks.map(t => t.id === taskId ? { ...t, case_status: 'paid' } : t);
    closeDrawer();
  }
</script>

<div class="space-y-6">
  <!-- Header Stats -->
  <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
    <button
      class="rounded-xl border-2 bg-white p-5 text-left transition-all hover:shadow-md {filterView === 'this_week' ? 'border-blue-500' : 'border-slate-200'}"
      onclick={() => filterView = 'this_week'}
    >
      <div class="text-3xl font-bold text-blue-600">{counts.this_week}</div>
      <div class="mt-1 text-sm text-slate-600">This Week</div>
    </button>
    <button
      class="rounded-xl border-2 bg-white p-5 text-left transition-all hover:shadow-md {filterView === 'overdue' ? 'border-red-500' : 'border-slate-200'}"
      onclick={() => filterView = 'overdue'}
    >
      <div class="text-3xl font-bold text-red-600">{counts.overdue}</div>
      <div class="mt-1 text-sm text-slate-600">Needs Attention</div>
    </button>
    <button
      class="rounded-xl border-2 bg-white p-5 text-left transition-all hover:shadow-md {filterView === 'all' ? 'border-purple-500' : 'border-slate-200'}"
      onclick={() => filterView = 'all'}
    >
      <div class="text-3xl font-bold text-purple-600">{counts.all}</div>
      <div class="mt-1 text-sm text-slate-600">All Tasks</div>
    </button>
  </div>

  <!-- Tasks Table -->
  <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
    {#if loading}
      <div class="flex flex-col items-center justify-center py-16">
        <div class="spinner mb-4 h-8 w-8 border-4"></div>
        <p class="text-slate-600">Loading your tasks...</p>
      </div>
    {:else if filtered().length === 0}
      <div class="flex flex-col items-center justify-center py-16 text-center">
        <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100">
          <svg class="h-8 w-8 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <p class="text-lg font-semibold text-slate-900">All caught up!</p>
        <p class="mt-1 text-sm text-slate-500">No tasks assigned for this filter</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
            <tr>
              <th class="p-4 text-left font-semibold">Date</th>
              <th class="p-4 text-left font-semibold">Client</th>
              <th class="p-4 text-left font-semibold">Provider</th>
              <th class="p-4 text-left font-semibold">Payer</th>
              <th class="p-4 text-center font-semibold">Status</th>
              <th class="p-4 text-left font-semibold">Auth #</th>
              <th class="p-4"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            {#each filtered() as task}
              <tr class="transition-colors hover:bg-slate-50">
                <td class="p-4 text-slate-600">{formatDate(task.session_date)}</td>
                <td class="p-4 font-medium text-slate-900">{task.clients?.name ?? 'Unknown'}</td>
                <td class="p-4 text-slate-700">{task.providers?.name ?? 'Unknown'}</td>
                <td class="p-4">
                  <div class="flex items-center gap-2">
                    <span class="text-slate-700">{task.payers?.name ?? 'Unknown'}</span>
                    {#if task.payers?.portal_url}
                      <a
                        href={task.payers.portal_url}
                        target="_blank"
                        class="text-blue-600 hover:text-blue-700"
                        title="Open payer portal"
                      >
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                        </svg>
                      </a>
                    {/if}
                  </div>
                </td>
                <td class="p-4 text-center">
                  <StatusBadge status={task.case_status || 'received'} />
                </td>
                <td class="p-4">
                  {#if task.auth_number}
                    <span class="text-xs text-slate-600">{task.auth_number}</span>
                  {:else}
                    <span class="text-xs text-slate-400">-</span>
                  {/if}
                </td>
                <td class="p-4">
                  <button
                    onclick={() => openDrawer(task)}
                    class="rounded-lg bg-blue-600 px-4 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-blue-700"
                  >
                    Work on This
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

<!-- Task Drawer -->
{#if selectedTask}
  <div class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="flex min-h-screen items-end justify-center px-4 pb-20 pt-4 text-center sm:block sm:p-0">
      <!-- Background overlay -->
      <div class="fixed inset-0 bg-slate-900 bg-opacity-75 transition-opacity" onclick={closeDrawer}></div>

      <!-- Drawer panel -->
      <div class="inline-block transform overflow-hidden rounded-t-2xl bg-white text-left align-bottom shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-2xl sm:rounded-2xl sm:align-middle">
        <!-- Header -->
        <div class="border-b border-slate-200 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 px-6 py-4">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-fsc-navy-900">Payer Checklist</h3>
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

        <!-- Content -->
        <div class="space-y-6 p-6">
          <!-- Session Info -->
          <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span class="text-slate-500">Client:</span>
                <span class="ml-2 font-medium text-slate-900">{selectedTask.clients?.name}</span>
              </div>
              <div>
                <span class="text-slate-500">Provider:</span>
                <span class="ml-2 font-medium text-slate-900">{selectedTask.providers?.name}</span>
              </div>
              <div>
                <span class="text-slate-500">Date:</span>
                <span class="ml-2 font-medium text-slate-900">{formatDate(selectedTask.session_date)}</span>
              </div>
              <div>
                <span class="text-slate-500">Payer:</span>
                <span class="ml-2 font-medium text-slate-900">{selectedTask.payers?.name}</span>
              </div>
            </div>
          </div>

          <!-- Checklist Form -->
          <div class="space-y-4">
            <div>
              <label for="auth_number" class="block text-sm font-semibold text-slate-700">Authorization Number</label>
              <input
                id="auth_number"
                type="text"
                value={selectedTask.auth_number || ''}
                class="mt-2 w-full rounded-xl border-2 border-slate-200 px-4 py-2.5 text-slate-900 focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
                placeholder="Enter auth number"
              />
            </div>

            <div>
              <label for="claim_number" class="block text-sm font-semibold text-slate-700">Claim Number</label>
              <input
                id="claim_number"
                type="text"
                value={selectedTask.claim_number || ''}
                class="mt-2 w-full rounded-xl border-2 border-slate-200 px-4 py-2.5 text-slate-900 focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
                placeholder="Enter claim number"
              />
            </div>

            <div>
              <label for="submission_date" class="block text-sm font-semibold text-slate-700">Submission Date</label>
              <input
                id="submission_date"
                type="date"
                value={selectedTask.submission_date?.split('T')[0] || ''}
                class="mt-2 w-full rounded-xl border-2 border-slate-200 px-4 py-2.5 text-slate-900 focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
              />
            </div>

            <div>
              <label for="notes" class="block text-sm font-semibold text-slate-700">Notes</label>
              <textarea
                id="notes"
                rows="3"
                value={selectedTask.notes || ''}
                class="mt-2 w-full rounded-xl border-2 border-slate-200 px-4 py-2.5 text-slate-900 focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
                placeholder="Add any notes or comments..."
              ></textarea>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-3">
            <button
              onclick={() => markAsSubmitted(selectedTask.id)}
              class="flex-1 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
            >
              Mark as Submitted
            </button>
            <button
              onclick={() => markAsPaid(selectedTask.id)}
              class="flex-1 rounded-xl bg-gradient-to-r from-blue-600 to-purple-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
            >
              Mark as Paid
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
{/if}
