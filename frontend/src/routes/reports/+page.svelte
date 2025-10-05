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
			<h1 class="text-3xl font-bold text-fsc-navy-900">Reports & Analytics</h1>
			<p class="mt-1 text-slate-600">
				Productivity, billing velocity, and payer mix insights
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
			<p class="text-slate-600">Loading reports...</p>
		</div>
	{:else}
		<!-- Preview Cards -->
		<div class="grid gap-6 md:grid-cols-3">
			<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
				<div class="flex items-center justify-between">
					<div class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100">
						<svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z" />
						</svg>
					</div>
				</div>
				<p class="mt-4 text-xs uppercase tracking-wide text-slate-500">Example Metric</p>
				<p class="mt-1 text-2xl font-bold text-slate-800">Sessions Imported</p>
				<p class="mt-2 text-sm text-slate-500">Coming soon - track total sessions imported over time</p>
			</div>

			<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
				<div class="flex items-center justify-between">
					<div class="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-100">
						<svg class="h-6 w-6 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
						</svg>
					</div>
				</div>
				<p class="mt-4 text-xs uppercase tracking-wide text-slate-500">Example Metric</p>
				<p class="mt-1 text-2xl font-bold text-slate-800">Flag Rate</p>
				<p class="mt-2 text-sm text-slate-500">Coming soon - monitor validation issue frequency</p>
			</div>

			<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
				<div class="flex items-center justify-between">
					<div class="flex h-12 w-12 items-center justify-center rounded-xl bg-purple-100">
						<svg class="h-6 w-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
						</svg>
					</div>
				</div>
				<p class="mt-4 text-xs uppercase tracking-wide text-slate-500">Example Metric</p>
				<p class="mt-1 text-2xl font-bold text-slate-800">Duplicate Rate</p>
				<p class="mt-2 text-sm text-slate-500">Coming soon - track duplicate session detection</p>
			</div>
		</div>

		<!-- Analytics Overview -->
		<div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
			<div class="border-b border-slate-200 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 p-6">
				<div class="flex items-start gap-4">
					<div class="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-xl bg-purple-500 text-white shadow-lg">
						<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
						</svg>
					</div>
					<div class="flex-1">
						<h2 class="text-lg font-semibold text-fsc-navy-900">Advanced Analytics Dashboard</h2>
						<p class="mt-1 text-sm text-slate-600">
							Comprehensive insights powered by Supabase data (sessions, import_runs, payers)
						</p>
					</div>
				</div>
			</div>

			<div class="p-8">
				<div class="mx-auto max-w-2xl text-center">
					<div class="mb-6 flex justify-center">
						<div class="flex h-20 w-20 items-center justify-center rounded-full bg-slate-100">
							<svg class="h-10 w-10 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z" />
							</svg>
						</div>
					</div>
					<h3 class="text-xl font-semibold text-slate-900">Coming Soon</h3>
					<p class="mt-2 text-slate-600">
						Detailed analytics and reporting features are in development.
					</p>

					<div class="mt-8 rounded-xl border border-slate-200 bg-slate-50 p-6">
						<h4 class="mb-4 text-sm font-semibold text-slate-700">Planned Reports</h4>
						<div class="grid gap-3 sm:grid-cols-2">
							<div class="flex items-start gap-2 text-left text-sm text-slate-600">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
								</svg>
								<span>Provider productivity metrics</span>
							</div>
							<div class="flex items-start gap-2 text-left text-sm text-slate-600">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
								</svg>
								<span>Billing velocity trends</span>
							</div>
							<div class="flex items-start gap-2 text-left text-sm text-slate-600">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
								</svg>
								<span>Payer mix analysis</span>
							</div>
							<div class="flex items-start gap-2 text-left text-sm text-slate-600">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
								</svg>
								<span>Session timing patterns</span>
							</div>
							<div class="flex items-start gap-2 text-left text-sm text-slate-600">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
								</svg>
								<span>Error and flag analytics</span>
							</div>
							<div class="flex items-start gap-2 text-left text-sm text-slate-600">
								<svg class="mt-0.5 h-4 w-4 flex-shrink-0 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
								</svg>
								<span>Weekly/monthly summaries</span>
							</div>
						</div>
					</div>

					<a
						href="/dashboard"
						class="mt-6 inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-3 text-sm font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
					>
						<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
						</svg>
						Back to Dashboard
					</a>
				</div>
			</div>
		</div>
	{/if}
</div>
