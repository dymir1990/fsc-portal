<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import Spinner from '$lib/Spinner.svelte';
  let statusMsg = 'Checking session…';

  onMount(async () => {
    try {
      const { data } = await supabase.auth.getUser();
      if (!data.user) {
        statusMsg = 'Redirecting to login…';
        window.location.href = '/login';
      } else {
        statusMsg = 'Opening dashboard…';
        window.location.href = '/dashboard';
      }
    } catch (e) {
      statusMsg = 'Error checking session. Redirecting to login…';
      setTimeout(() => window.location.href = '/login', 800);
    }
  });
</script>

<section class="mx-auto flex min-h-[60vh] max-w-md flex-col items-center justify-center text-center">
  <div class="mb-6 flex h-14 w-14 items-center justify-center rounded-2xl bg-brand-600 text-white shadow-sm">
    <span class="text-xl font-semibold">FS</span>
  </div>
  <h1 class="text-2xl font-semibold tracking-tight">FSC Portal</h1>
  <p class="mt-2 text-sm text-gray-600 max-w-sm">Secure internal portal for session imports, billing prep, and reporting. Redirecting you based on your session.</p>
  <div class="mt-6 flex items-center gap-3 text-sm text-gray-500">
    <Spinner size={18} />
    <span>{statusMsg}</span>
  </div>
  <p class="mt-8 text-xs text-gray-400">If nothing happens after a few seconds, <a href="/login" class="text-brand-600 hover:underline">click here</a>.</p>
</section>
