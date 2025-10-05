<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseClient';
	let loading = true;

	onMount(async () => {
		const { data } = await supabase.auth.getUser();
		if (!data.user) {
			window.location.href = '/login';
		} else {
			loading = false;
		}
	});
</script>

<div class="space-y-8">
	<!-- Header -->
	<div class="flex items-center justify-between">
		<div>
			<h1 class="text-3xl font-bold text-fsc-navy-900">Billing Queue</h1>
			<p class="mt-1 text-slate-600">
				Sessions ready for claim submission with payer-specific batching rules
			</p>
		</div>
		<span class="inline-flex items-center gap-2 rounded-lg bg-blue-50 px-4 py-2 text-sm font-semibold text-blue-700">
			<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
			</svg>
			Preview
		</span>
	</div>

	{#if loading}
		<div class="flex flex-col items-center justify-center py-20">
			<div class="spinner mb-4 h-8 w-8 border-4"></div>
			<p class="text-slate-600">Loading billing queue...</p>
		</div>
	{:else}
		<!-- Coming Soon Card -->
		<div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
			<div class="border-b border-slate-200 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 p-6">
				<div class="flex items-start gap-4">
					<div class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-blue-500 text-white shadow-lg">
						<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
						</svg>
					</div>
					<div class="flex-1">
						<h2 class="text-lg font-semibold text-fsc-navy-900">Claim Submission Pipeline</h2>
						<p class="mt-1 text-sm text-slate-600">
							Automated billing queue for processing and submitting insurance claims
						</p>
					</div>
				</div>
			</div>

			<div class="p-8">
				<div class="mx-auto max-w-2xl text-center">
					<div class="mb-6 flex justify-center">
						<div class="flex h-20 w-20 items-center justify-center rounded-full bg-slate-100">
							<svg class="h-10 w-10 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
							</svg>
						</div>
					</div>
					<h3 class="text-xl font-semibold text-slate-900">Coming Soon</h3>
					<p class="mt-2 text-slate-600">
						No billing items yet. After you import sessions and they pass validation, they will appear here.
					</p>

					<div class="mt-8 rounded-xl border border-slate-200 bg-slate-50 p-6">
						<h4 class="mb-4 text-sm font-semibold text-slate-700">Planned Features</h4>
						<div class="space-y-2 text-left text-sm text-slate-600">
							<div class="flex items-start gap-2">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
								</svg>
								<span>Automatic claim batching by payer and billing route</span>
							</div>
							<div class="flex items-start gap-2">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
								</svg>
								<span>Missing note status alerts and validation</span>
							</div>
							<div class="flex items-start gap-2">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
								</svg>
								<span>Payer-specific submission rules and scheduling</span>
							</div>
							<div class="flex items-start gap-2">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
								</svg>
								<span>Claim submission tracking and status updates</span>
							</div>
						</div>
					</div>

					<a
						href="/sessions"
						class="mt-6 inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-3 text-sm font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
					>
						<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
						</svg>
						View Sessions
					</a>
				</div>
			</div>
		</div>
	{/if}
</div>
