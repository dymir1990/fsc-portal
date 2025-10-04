<script lang="ts">
  import { api, supabase } from '$lib';

  let file: File | null = null;
  let msg = $state('');
  let uploading = $state(false);

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

      msg = 'Uploaded. Check dashboard for counts.';
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Upload failed.';
      msg = `Error: ${message}`;
    } finally {
      uploading = false;
    }
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
    <button class="rounded bg-blue-600 text-white px-4 py-2 disabled:opacity-50" on:click={upload} disabled={uploading}>
      {uploading ? 'Uploading…' : 'Upload'}
    </button>
  </div>

  {#if msg}<p class="text-sm text-slate-600">{msg}</p>{/if}
</div>
