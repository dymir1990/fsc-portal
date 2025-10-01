<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the documentation</p>


<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';

  onMount(async () => {
    // Check if user is logged in
    const { data } = await supabase.auth.getUser();

    if (!data.user) {
      // Not logged in → send to login page
      window.location.href = '/login';
    } else {
      // Logged in → send to dashboard
      window.location.href = '/dashboard';
    }
  });
</script>

<p class="p-6">Checking session…</p>
