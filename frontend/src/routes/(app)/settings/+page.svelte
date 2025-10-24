<script lang="ts">
	import { goto } from '$app/navigation';

	type SettingCard = {
		title: string;
		description: string;
		href: string;
		icon: string;
	};

	const settings: SettingCard[] = [
		{
			title: 'Insurance Companies',
			description: 'Manage payers, portals, and billing routes',
			href: '/settings/payers',
			icon: 'building'
		},
		{
			title: 'Role Management',
			description: 'Manage user roles and permissions',
			href: '/settings/roles',
			icon: 'users'
		},
		{
			title: 'Payroll',
			description: 'Provider compensation settings',
			href: '/settings/payroll',
			icon: 'wallet'
		}
	];

	const getIcon = (iconName: string) => {
		const icons: Record<string, string> = {
			building:
				'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4',
			users:
				'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z',
			wallet:
				'M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z'
		};
		return icons[iconName] || icons.building;
	};
</script>

<div class="min-h-screen bg-gradient-to-br from-slate-50 via-white to-blue-50 p-8">
	<div class="mx-auto max-w-5xl">
		<!-- Header -->
		<div class="mb-8">
			<h1 class="text-3xl font-bold text-slate-900">Settings</h1>
			<p class="mt-2 text-slate-600">Manage your practice configuration</p>
		</div>

		<!-- Settings Cards -->
		<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
			{#each settings as setting}
				<button
					onclick={() => goto(setting.href)}
					class="group relative overflow-hidden rounded-2xl bg-white p-6 shadow-sm transition-all hover:shadow-xl hover:-translate-y-1"
				>
					<div class="flex items-start gap-4">
						<div
							class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 text-white shadow-lg"
						>
							<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d={getIcon(setting.icon)}
								/>
							</svg>
						</div>
						<div class="flex-1 text-left">
							<h3 class="font-semibold text-slate-900 group-hover:text-blue-600 transition-colors">
								{setting.title}
							</h3>
							<p class="mt-1 text-sm text-slate-600">
								{setting.description}
							</p>
						</div>
					</div>

					<!-- Hover indicator -->
					<div
						class="absolute bottom-0 left-0 h-1 w-0 bg-gradient-to-r from-blue-500 to-purple-600 transition-all group-hover:w-full"
					/>
				</button>
			{/each}
		</div>

		<!-- Profile Section -->
		<div class="mt-8 rounded-2xl bg-white p-6 shadow-sm">
			<h2 class="text-lg font-semibold text-slate-900">Your Profile</h2>
			<p class="mt-1 text-sm text-slate-600">Manage your account settings and preferences</p>

			<div class="mt-4 space-y-2">
				<div class="flex items-center justify-between rounded-lg p-3 hover:bg-slate-50">
					<span class="text-sm text-slate-700">Email notifications</span>
					<span class="text-sm text-slate-500">Coming soon</span>
				</div>
				<div class="flex items-center justify-between rounded-lg p-3 hover:bg-slate-50">
					<span class="text-sm text-slate-700">Two-factor authentication</span>
					<span class="text-sm text-slate-500">Coming soon</span>
				</div>
			</div>
		</div>
	</div>
</div>
