<script>
	import StatusBadge from './StatusBadge.svelte';
	import UserAvatar from './UserAvatar.svelte';

	export let session = {
		id: '',
		provider: '',
		client: '',
		date: '',
		hours: 0,
		status: 'pending',
		assignedTo: null
	};
	export let variant = 'kanban'; // kanban | list
</script>

{#if variant === 'kanban'}
	<div class="group relative rounded-lg border border-slate-200 bg-white p-4 shadow-sm transition-all hover:shadow-md">
		<!-- Drag Handle -->
		<div class="absolute left-2 top-1/2 -translate-y-1/2 cursor-grab opacity-0 transition-opacity group-hover:opacity-50">
			<svg class="h-4 w-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8h16M4 16h16" />
			</svg>
		</div>

		<!-- Card Content -->
		<div class="space-y-3">
			<div class="flex items-start justify-between">
				<div class="flex-1">
					<p class="font-semibold text-slate-900">{session.provider}</p>
					<p class="text-sm text-slate-600">{session.client}</p>
				</div>
				<span class="rounded-full bg-fsc-navy-100 px-2.5 py-0.5 text-xs font-semibold text-fsc-navy-700">
					{session.hours}h
				</span>
			</div>

			<div class="flex items-center justify-between text-xs text-slate-500">
				<span>{new Date(session.date).toLocaleDateString()}</span>
				{#if session.assignedTo}
					<UserAvatar name={session.assignedTo} size="sm" />
				{/if}
			</div>
		</div>
	</div>
{:else}
	<!-- List variant for table view -->
	<tr class="border-b border-slate-100 transition-colors hover:bg-slate-50">
		<td class="px-4 py-3 text-sm font-medium text-slate-900">#{session.id}</td>
		<td class="px-4 py-3 text-sm text-slate-600">{session.client}</td>
		<td class="px-4 py-3 text-sm text-slate-900">{session.provider}</td>
		<td class="px-4 py-3 text-sm text-slate-600">{new Date(session.date).toLocaleDateString()}</td>
		<td class="px-4 py-3 text-sm text-slate-900">{session.hours}</td>
		<td class="px-4 py-3">
			<StatusBadge status={session.status} />
		</td>
		<td class="px-4 py-3">
			{#if session.assignedTo}
				<div class="flex items-center gap-2">
					<UserAvatar name={session.assignedTo} size="sm" />
					<span class="text-sm text-slate-600">{session.assignedTo}</span>
				</div>
			{:else}
				<span class="text-sm text-slate-400">Unassigned</span>
			{/if}
		</td>
		<td class="px-4 py-3">
			<button class="rounded p-1 hover:bg-slate-100">
				<svg class="h-5 w-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
				</svg>
			</button>
		</td>
	</tr>
{/if}
