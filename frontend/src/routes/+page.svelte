<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  let email = $state('');

  async function sendLink() {
    const { error } = await supabase.auth.signInWithOtp({ email });
    alert(error ? `Error: ${error.message}` : 'Check your email for the magic link.');
  }
</script>

<div class="max-w-md mx-auto bg-white shadow rounded p-6 space-y-4">
  <h1 class="text-xl font-semibold">Welcome back</h1>
  <input class="w-full border rounded px-3 py-2" placeholder="you@fscnj.com" bind:value={email} />
  <button class="w-full rounded bg-blue-600 text-white py-2" on:click={sendLink}>
    Send magic link
  </button>
</div>

