<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	let email = '';
	let msg = '';
	let sending = false;

	async function signIn() {
		if (!email) {
			msg = 'Enter your work email.';
			return;
		}
		sending = true;
		msg = 'Sending magic link…';
		const { error } = await supabase.auth.signInWithOtp({ email });
		sending = false;
		msg = error ? `Error: ${error.message}` : 'Check your email for the login link.';
	}
</script>

<div class="min-h-[80vh] grid place-items-center">
	<div class="w-full max-w-md rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
		<div class="mb-4 text-center">
			<h1 class="text-2xl font-semibold">Sign in to FSC Portal</h1>
			<p class="mt-1 text-sm text-gray-600">Use your work email to receive a magic link.</p>
		</div>

		<label class="block text-sm font-medium text-gray-700" for="email">Email</label>
		<input
			id="email"
			class="mt-1 w-full rounded-lg border border-gray-300 p-2 focus:border-brand-600 focus:outline-none"
			type="email"
			bind:value={email}
			placeholder="you@fscnj.com"
		/>

		<button
			class="mt-4 w-full rounded-lg bg-brand-600 px-4 py-2 font-medium text-white hover:bg-brand-700 disabled:opacity-50"
			on:click={signIn}
			disabled={sending || !email}>{sending ? 'Sending…' : 'Send Magic Link'}</button
		>

		{#if msg}
			<p class="mt-3 text-sm text-gray-700">{msg}</p>
		{/if}
	</div>
</div>
