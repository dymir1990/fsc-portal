<script>
	export let label = '';
	export let value = 0;
	export let icon = '📊';
	export let trend = null; // { value: '+5', positive: true }
	export let color = 'blue'; // blue | emerald | amber | red | violet

	const colorConfig = {
		blue: 'border-blue-500 bg-blue-50',
		emerald: 'border-emerald-500 bg-emerald-50',
		amber: 'border-amber-500 bg-amber-50',
		red: 'border-red-500 bg-red-50',
		violet: 'border-violet-500 bg-violet-50'
	};

	$: borderClass = colorConfig[color] || colorConfig.blue;
</script>

<div class="relative overflow-hidden rounded-xl border-l-4 bg-white p-6 shadow-sm transition-shadow hover:shadow-md {borderClass}">
	<div class="flex items-start justify-between">
		<div class="flex-1">
			<p class="text-sm font-medium text-slate-600">{label}</p>
			<p class="mt-2 text-4xl font-bold text-slate-900">{value.toLocaleString()}</p>
			{#if trend}
				<p class="mt-2 text-sm font-medium {trend.positive ? 'text-emerald-600' : 'text-red-600'}">
					{trend.value} this week
				</p>
			{/if}
		</div>
		<div class="flex h-12 w-12 items-center justify-center rounded-full bg-slate-100 text-2xl">
			{icon}
		</div>
	</div>
</div>
