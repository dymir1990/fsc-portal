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

<div class="flex min-h-screen items-center justify-center px-4 py-12">
	<div class="w-full max-w-md">
		<!-- Logo/Brand -->
		<div class="mb-8 text-center">
			<div class="mb-4 flex justify-center">
				<div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-blue-500 via-violet-500 to-pink-500 shadow-lg">
					<span class="text-3xl">⭐</span>
				</div>
			</div>
			<h1 class="bg-gradient-to-r from-fsc-navy-900 to-fsc-navy-600 bg-clip-text text-3xl font-bold text-transparent">
				Fresh Start Portal
			</h1>
			<p class="mt-2 text-slate-600">Billing & compliance, simplified</p>
		</div>

		<!-- Sign In Card -->
		<div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl">
			<div class="bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 p-6">
				<h2 class="text-2xl font-bold text-fsc-navy-900">Welcome back</h2>
				<p class="mt-1 text-sm text-slate-600">Enter your email to receive a magic sign-in link</p>
			</div>

			<div class="p-6">
				<div class="space-y-4">
					<div>
						<label class="block text-sm font-semibold text-slate-700" for="email">
							Email address
						</label>
						<input
							id="email"
							class="mt-2 w-full rounded-xl border-2 border-slate-200 bg-white px-4 py-3 text-slate-900 placeholder-slate-400 transition-all focus:border-blue-500 focus:outline-none focus:ring-4 focus:ring-blue-100"
							type="email"
							bind:value={email}
							placeholder="you@fscnj.com"
							on:keydown={(e) => e.key === 'Enter' && signIn()}
						/>
					</div>

					<button
						class="group relative w-full overflow-hidden rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-8 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:hover:scale-100"
						on:click={signIn}
						disabled={sending || !email}
					>
						<span class="relative z-10">
							{#if sending}
								<span class="inline-flex items-center gap-2">
									<span class="spinner"></span>
									Sending magic link...
								</span>
							{:else}
								Send Magic Link
							{/if}
						</span>
						<div class="absolute inset-0 bg-gradient-to-r from-blue-700 to-teal-700 opacity-0 transition-opacity group-hover:opacity-100"></div>
					</button>

					{#if msg}
						<div class="rounded-lg {msg.includes('Error') ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'} px-4 py-3 text-sm">
							{msg}
						</div>
					{/if}
				</div>

				<div class="mt-6 flex items-center justify-center gap-2 text-xs text-slate-500">
					<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
					</svg>
					<span>Secure login • No passwords needed</span>
				</div>
			</div>
		</div>

		<!-- Footer -->
		<p class="mt-8 text-center text-sm text-slate-500">
			Fresh Start Counseling • Provider Portal
		</p>
	</div>
</div>
