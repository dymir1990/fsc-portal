<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';

  let user: any = null;

  onMount(async () => {
    const { data, error } = await supabase.auth.getUser();
    if (error || !data.user) {
      window.location.href = '/login';
    } else {
      user = data.user;
    }
  });

  async function signOut() {
    await supabase.auth.signOut();
    window.location.href = '/login';
  }
</script>

<div class="min-h-[70vh] p-6">
  {#if user}
    <div class="mx-auto max-w-3xl space-y-4">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-semibold">Welcome, {user.email}</h1>
        <button
          on:click={signOut}
          class="rounded-lg bg-red-600 px-3 py-2 text-white hover:bg-red-700"
        >Sign Out</button>
      </div>

      <div class="grid gap-4 md:grid-cols-2">
        <a href="/case-manager/import" class="rounded-xl border border-gray-200 p-4 hover:shadow">
          <h2 class="font-medium">Import SimplePractice CSV</h2>
          <p class="mt-1 text-sm text-gray-600">Upload last week's sessions and review flagged rows.</p>
        </a>
        <a href="https://app.supabase.com" target="_blank" class="rounded-xl border border-gray-200 p-4 hover:shadow">
          <h2 class="font-medium">Open Supabase</h2>
          <p class="mt-1 text-sm text-gray-600">Check sessions, import runs, and payers.</p>
        </a>
      </div>
    </div>
  {:else}
    <p>Loading dashboard…</p>
  {/if}
</div>
