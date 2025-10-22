<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let loading = $state(true);

  onMount(async () => {
    const { data: { session } } = await supabase.auth.getSession();

    if (session) {
      goto('/billing/revenue');
    } else {
      goto('/login');
    }
  });
</script>

{#if loading}
  <div class="flex min-h-screen items-center justify-center">
    <div class="text-center space-y-4">
      <div class="flex justify-center">
        <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-blue-500 via-violet-500 to-pink-500 shadow-lg">
          <span class="text-3xl">⭐</span>
        </div>
      </div>
      <div class="spinner h-8 w-8 border-4 mx-auto"></div>
      <p class="text-slate-600 font-medium">Loading Fresh Start Portal...</p>
    </div>
  </div>
{/if}

