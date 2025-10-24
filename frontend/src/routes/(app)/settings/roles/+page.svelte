<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import { env } from '$env/dynamic/public';
	import { onMount } from 'svelte';

	type User = {
		id: string;
		email: string;
		full_name: string;
		role: 'admin' | 'billing' | 'manager' | 'provider';
		created_at: string;
	};

	let users = $state<User[]>([]);
	let loading = $state(true);
	let saving = $state(false);
	let message = $state('');
	let messageType = $state<'success' | 'error'>('success');

	const roles = [
		{ id: 'admin', name: 'Admin', description: 'Full system access', color: 'bg-purple-600' },
		{
			id: 'billing',
			name: 'Billing Staff',
			description: 'Billing and reporting access',
			color: 'bg-blue-600'
		},
		{
			id: 'manager',
			name: 'Manager',
			description: 'Team management access',
			color: 'bg-green-600'
		},
		{
			id: 'provider',
			name: 'Provider',
			description: 'Limited to own sessions',
			color: 'bg-orange-600'
		}
	];

	onMount(async () => {
		await loadUsers();
	});

	async function loadUsers() {
		loading = true;
		try {
			const {
				data: { session }
			} = await supabase.auth.getSession();
			if (!session?.access_token) {
				loading = false;
				return;
			}

			const response = await fetch(`${env.PUBLIC_API_BASE}/api/users`, {
				headers: {
					Authorization: `Bearer ${session.access_token}`
				}
			});

			if (response.ok) {
				users = await response.json();
			} else {
				// Fallback to mock data if API fails
				users = [
					{
						id: 'user-1',
						email: 'admin@fscnj.com',
						full_name: 'You (Admin)',
						role: 'admin',
						created_at: '2025-01-01T00:00:00Z'
					},
					{
						id: 'user-2',
						email: 'mackenzie@fscnj.com',
						full_name: 'Mackenzie',
						role: 'billing',
						created_at: '2025-01-01T00:00:00Z'
					},
					{
						id: 'user-3',
						email: 'samina@fscnj.com',
						full_name: 'Samina',
						role: 'manager',
						created_at: '2025-01-01T00:00:00Z'
					}
				];
				showMessage('Using demo data - API not available', 'error');
			}
		} catch (error) {
			console.error('Error loading users:', error);
			showMessage('Failed to load users', 'error');
		}
		loading = false;
	}

	async function updateUserRole(userId: string, newRole: string) {
		saving = true;
		try {
			const {
				data: { session }
			} = await supabase.auth.getSession();
			if (!session?.access_token) {
				showMessage('Not authenticated', 'error');
				return;
			}

			const response = await fetch(`${env.PUBLIC_API_BASE}/api/users/${userId}/role`, {
				method: 'PUT',
				headers: {
					Authorization: `Bearer ${session.access_token}`,
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ role: newRole })
			});

			if (response.ok) {
				// Update local state
				const userIndex = users.findIndex((u) => u.id === userId);
				if (userIndex !== -1) {
					users[userIndex].role = newRole as any;
				}
				showMessage(`Role updated successfully`, 'success');
			} else {
				const errorData = await response.json().catch(() => ({}));
				showMessage(errorData.detail || 'Failed to update role', 'error');
			}
		} catch (error) {
			console.error('Error updating role:', error);
			showMessage('Failed to update role', 'error');
		}
		saving = false;
	}

	function showMessage(text: string, type: 'success' | 'error') {
		message = text;
		messageType = type;
		setTimeout(() => {
			message = '';
		}, 3000);
	}

	function getRoleInfo(roleId: string) {
		return roles.find((r) => r.id === roleId) || roles[0];
	}

	function formatDate(dateString: string) {
		return new Date(dateString).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'short',
			day: 'numeric'
		});
	}
</script>

<div class="space-y-6">
	<!-- Header -->
	<div class="flex items-center justify-between">
		<div>
			<h1 class="text-3xl font-bold text-fsc-navy-900">Role Management</h1>
			<p class="mt-1 text-slate-600">Manage user roles and permissions</p>
		</div>
		<button
			onclick={loadUsers}
			disabled={loading}
			class="flex items-center gap-2 rounded-xl bg-blue-600 px-6 py-2.5 text-sm font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02] disabled:opacity-50"
		>
			<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
				/>
			</svg>
			Refresh
		</button>
	</div>

	<!-- Message -->
	{#if message}
		<div
			class="rounded-xl border p-4 {messageType === 'success'
				? 'border-green-200 bg-green-50 text-green-800'
				: 'border-red-200 bg-red-50 text-red-800'}"
		>
			<div class="flex items-center gap-2">
				{#if messageType === 'success'}
					<svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
				{:else}
					<svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
				{/if}
				<span class="font-medium">{message}</span>
			</div>
		</div>
	{/if}

	<!-- Role Information -->
	<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
		{#each roles as role}
			<div class="rounded-xl border border-slate-200 bg-white p-4">
				<div class="flex items-center gap-3">
					<div
						class="flex h-10 w-10 items-center justify-center rounded-lg {role.color} text-white"
					>
						<svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
							/>
						</svg>
					</div>
					<div>
						<h3 class="font-semibold text-slate-900">{role.name}</h3>
						<p class="text-sm text-slate-600">{role.description}</p>
					</div>
				</div>
			</div>
		{/each}
	</div>

	<!-- Users Table -->
	<div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
		{#if loading}
			<div class="flex flex-col items-center justify-center py-16">
				<div class="spinner mb-4 h-8 w-8 border-4"></div>
				<p class="text-slate-600">Loading users...</p>
			</div>
		{:else if users.length === 0}
			<div class="flex flex-col items-center justify-center py-16 text-center">
				<div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
					<svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
						/>
					</svg>
				</div>
				<p class="text-slate-600">No users found</p>
				<p class="mt-1 text-sm text-slate-500">
					Users will appear here once they're added to the system
				</p>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-sm">
					<thead class="border-b border-slate-200 bg-slate-50 text-slate-600">
						<tr>
							<th class="p-4 text-left font-semibold">User</th>
							<th class="p-4 text-left font-semibold">Email</th>
							<th class="p-4 text-left font-semibold">Current Role</th>
							<th class="p-4 text-left font-semibold">Joined</th>
							<th class="p-4 text-right font-semibold">Actions</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100">
						{#each users as user}
							<tr class="transition-colors hover:bg-slate-50">
								<td class="p-4">
									<div class="flex items-center gap-3">
										<div
											class="flex h-8 w-8 items-center justify-center rounded-full bg-slate-100 text-slate-600"
										>
											<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
												/>
											</svg>
										</div>
										<div>
											<p class="font-medium text-slate-900">{user.full_name}</p>
											<p class="text-xs text-slate-500">ID: {user.id}</p>
										</div>
									</div>
								</td>
								<td class="p-4 text-slate-600">{user.email}</td>
								<td class="p-4">
									<span
										class="inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-semibold {getRoleInfo(
											user.role
										).color} text-white"
									>
										{getRoleInfo(user.role).name}
									</span>
								</td>
								<td class="p-4 text-slate-600">{formatDate(user.created_at)}</td>
								<td class="p-4 text-right">
									<div class="flex items-center gap-2">
										<select
											value={user.role}
											onchange={(e) =>
												updateUserRole(
													user.id,
													(e.target as HTMLSelectElement)?.value || user.role
												)}
											disabled={saving}
											class="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-sm focus:border-blue-500 focus:outline-none disabled:opacity-50"
										>
											{#each roles as role}
												<option value={role.id}>{role.name}</option>
											{/each}
										</select>
										{#if saving}
											<div class="spinner h-4 w-4 border-2"></div>
										{/if}
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>

	<!-- Help Text -->
	<div class="rounded-xl border border-blue-200 bg-blue-50 p-6">
		<div class="flex items-start gap-3">
			<svg
				class="h-5 w-5 text-blue-600 mt-0.5"
				fill="none"
				stroke="currentColor"
				viewBox="0 0 24 24"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
				/>
			</svg>
			<div>
				<h3 class="font-semibold text-blue-900">Role Management Guide</h3>
				<div class="mt-2 text-sm text-blue-800">
					<ul class="list-disc list-inside space-y-1">
						<li><strong>Admin:</strong> Full system access, can manage all users and data</li>
						<li>
							<strong>Billing Staff:</strong> Can access billing data and reports, manage sessions
						</li>
						<li><strong>Manager:</strong> Can view team data and manage assignments</li>
						<li><strong>Provider:</strong> Limited to viewing only their own sessions</li>
					</ul>
					<p class="mt-2 text-xs text-blue-700">
						Changes take effect immediately. Users will need to refresh their browser to see updated
						permissions.
					</p>
				</div>
			</div>
		</div>
	</div>
</div>
