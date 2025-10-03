<script lang="ts">
  // dummy stats for now (local state with runes)
  let stats = $state({
    pending: 12, submitted: 40, flagged: 3, paid: 26
  });
</script>

<h1 class="text-xl font-semibold mb-4">Overview</h1>
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
  {#each Object.entries(stats) as [label, value]}
    <div class="bg-white rounded shadow p-4">
      <div class="text-sm text-slate-500 capitalize">{label}</div>
      <div class="text-2xl font-bold">{value}</div>
    </div>
  {/each}
</div>

<h2 class="mt-8 mb-2 font-semibold">Recent activity</h2>
<div class="bg-white rounded shadow overflow-hidden">
  <table class="w-full text-sm">
    <thead class="bg-slate-50 text-slate-600">
      <tr><th class="text-left p-3">Client</th><th class="text-left p-3">Provider</th><th class="p-3">Status</th></tr>
    </thead>
    <tbody>
      <tr class="border-t"><td class="p-3">A. Gomez</td><td class="p-3">D. Chen</td><td class="p-3"><span class="px-2 py-1 text-xs rounded bg-amber-100 text-amber-700">Pending</span></td></tr>
      <tr class="border-t"><td class="p-3">K. Patel</td><td class="p-3">L. Rivera</td><td class="p-3"><span class="px-2 py-1 text-xs rounded bg-green-100 text-green-700">Paid</span></td></tr>
    </tbody>
  </table>
</div>
