<script>
	import '../app.css';
</script>

<svelte:head>
	<title>FSC Portal</title>
	<meta name="viewport" content="width=device-width, initial-scale=1" />
</svelte:head>

<div class="min-h-screen bg-gradient-to-b from-indigo-600 via-sky-600 to-blue-600">
	<!-- Top nav -->
	<header class="mx-auto max-w-6xl px-4 py-6 flex items-center justify-between text-white/90">
		<div class="flex items-center gap-2 font-semibold tracking-tight">
			<span class="inline-grid h-8 w-8 place-items-center rounded-lg bg-white/10">FS</span>
			<span>FSC Portal</span>
		</div>
		<nav class="hidden sm:flex gap-6 text-sm">
			<a href="/" class="hover:text-white">Home</a>
			<a href="/dashboard" class="hover:text-white">Dashboard</a>
			<a href="/case-manager/import" class="hover:text-white">Import</a>
			<a href="/login" class="hover:text-white">Sign in</a>
		</nav>
	</header>

	<!-- Hero -->
	<main class="mx-auto max-w-6xl px-4 pb-24">
		<div class="grid items-center gap-10 lg:grid-cols-2">
			<!-- Left: copy + CTAs -->
			<div>
				<h1 class="text-4xl sm:text-5xl font-bold leading-tight text-white">
					All your billing &amp; compliance, in one place.
				</h1>
				<p class="mt-4 text-white/80 text-lg">
					Upload SimplePractice CSVs, tag sessions, and keep providers paid on time — without
					spreadsheets.
				</p>

				<div class="mt-6 flex flex-wrap gap-3">
					<a
						href="/import"
						class="inline-flex items-center rounded-md bg-white px-4 py-2 font-semibold text-indigo-700 shadow hover:bg-white/90"
					>
						Import CSV
					</a>
					<a
						href="/dashboard"
						class="inline-flex items-center rounded-md bg-white/10 px-4 py-2 font-semibold text-white ring-1 ring-inset ring-white/30 hover:bg-white/10"
					>
						Open Dashboard
					</a>
				</div>

				<div class="mt-8 text-white/70 text-sm">
					Synced with Supabase • Role-based access • Magic link sign-in
				</div>
			</div>

			<!-- Right: UI preview card -->
			<div class="relative">
				<div class="overflow-hidden rounded-2xl bg-white shadow-2xl ring-1 ring-black/5">
					<div class="border-b bg-gray-50 px-4 py-2 text-sm text-gray-600">
						FSC Portal — Billing queue
					</div>
					<div class="p-4">
						<div class="overflow-hidden rounded-xl border border-gray-200">
							<table class="w-full text-left text-sm">
								<thead class="bg-gray-50 text-gray-600">
									<tr>
										<th class="px-3 py-2">Client</th>
										<th class="px-3 py-2">Provider</th>
										<th class="px-3 py-2 text-right">Hours</th>
										<th class="px-3 py-2 text-right">Status</th>
									</tr>
								</thead>
								<tbody class="divide-y">
									<tr>
										<td class="px-3 py-2">Harlem M.</td>
										<td class="px-3 py-2">E. Echevarria</td>
										<td class="px-3 py-2 text-right">3.5</td>
										<td class="px-3 py-2 text-right">
											<span
												class="inline-flex items-center rounded-full bg-emerald-100 px-2 py-0.5 text-emerald-700"
												>Ready</span
											>
										</td>
									</tr>
									<tr>
										<td class="px-3 py-2">Nicholas T.</td>
										<td class="px-3 py-2">W. Rivera</td>
										<td class="px-3 py-2 text-right">2.0</td>
										<td class="px-3 py-2 text-right">
											<span
												class="inline-flex items-center rounded-full bg-amber-100 px-2 py-0.5 text-amber-700"
												>Needs review</span
											>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>

				<!-- soft glow -->
				<div
					class="absolute -left-6 -bottom-6 -z-10 h-40 w-40 rounded-full bg-white/20 blur-2xl"
				></div>
			</div>
		</div>

		<!-- Render route content below the hero -->
		<div class="mt-16 rounded-2xl bg-white/5 p-6 text-white">
			<slot />
		</div>
	</main>
</div>
