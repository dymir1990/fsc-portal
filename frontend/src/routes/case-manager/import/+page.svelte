<script lang="ts">
  let file: File | null = null;
  let msg = $state('');

  async function upload() {
    if (!file) { msg = 'Pick a CSV first.'; return; }
    const body = new FormData();
    body.append('file', file);

    // Call your FastAPI endpoint
    const res = await fetch('http://localhost:8001/api/imports/simplepractice', { method: 'POST', body });
    msg = res.ok ? 'Uploaded. Check dashboard for counts.' : `Error: ${await res.text()}`;
  }
</script>

<h1 class="text-xl font-semibold mb-4">Import SimplePractice CSV</h1>

<div class="bg-white rounded shadow p-4 space-y-4 max-w-2xl">
  <div class="text-sm text-slate-600">
    Upload last week’s export. We’ll de-dupe, tag payer routes, and flag anything odd.
  </div>

  <div class="flex items-center gap-3">
    <input type="file" accept=".csv" on:change={(e:any) => file = e.target.files?.[0] ?? null}
           class="block w-full text-sm file:mr-3 file:px-3 file:py-2 file:rounded file:bg-slate-100 file:border file:text-slate-600" />
    <button class="rounded bg-blue-600 text-white px-4 py-2" on:click={upload}>Upload</button>
  </div>

  {#if msg}<p class="text-sm text-slate-600">{msg}</p>{/if}
</div>
