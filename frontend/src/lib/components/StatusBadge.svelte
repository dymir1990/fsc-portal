<script>
	export let status = 'pending'; // pending | in-progress | submitted | paid | flagged

	const statusConfig = {
		pending: {
			label: 'Pending',
			class: 'bg-amber-100 text-amber-700 border-amber-200'
		},
		'in-progress': {
			label: 'In Progress',
			class: 'bg-blue-100 text-blue-700 border-blue-200'
		},
		submitted: {
			label: 'Submitted',
			class: 'bg-violet-100 text-violet-700 border-violet-200'
		},
		paid: {
			label: 'Paid',
			class: 'bg-emerald-100 text-emerald-700 border-emerald-200'
		},
		flagged: {
			label: 'Flagged',
			class: 'bg-red-100 text-red-700 border-red-200'
		}
	};

	$: config = statusConfig[status] || statusConfig.pending;
</script>

<span class="inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-semibold {config.class}">
	<span class="h-1.5 w-1.5 rounded-full bg-current"></span>
	{config.label}
</span>
