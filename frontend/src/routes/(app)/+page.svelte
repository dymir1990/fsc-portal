<script lang="ts">
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';

  // Nordic Clean: Revenue page is the home
  onMount(() => {
    goto('/billing/revenue', { replaceState: true });
  });
</script>

<div class="flex h-screen items-center justify-center">
  <div class="text-center">
    <div class="animate-spin h-8 w-8 border-4 border-blue-600 border-t-transparent rounded-full mx-auto" />
    <p class="mt-4 text-slate-600">Loading...</p>
  </div>
</div>

