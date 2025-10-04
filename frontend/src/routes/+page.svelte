<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let loading = $state(true);

  onMount(async () => {
    const { data: { session } } = await supabase.auth.getSession();

    if (session) {
      goto('/dashboard');
    } else {
      goto('/login');
    }
  });
</script>

{#if loading}
  <div class="min-h-screen grid place-items-center">
    <div class="text-center space-y-3">
      <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-blue-600 border-r-transparent"></div>
      <p class="text-slate-600">Loading...</p>
    </div>
  </div>
{/if}

