<script>
	export let name = 'User';
	export let src = null;
	export let size = 'md'; // sm | md | lg

	const sizeClasses = {
		sm: 'h-8 w-8 text-xs',
		md: 'h-10 w-10 text-sm',
		lg: 'h-12 w-12 text-base'
	};

	$: initials = name
		.split(' ')
		.map(n => n[0])
		.join('')
		.toUpperCase()
		.slice(0, 2);

	$: sizeClass = sizeClasses[size] || sizeClasses.md;

	// Generate consistent color from name
	const getColorFromName = (str) => {
		const colors = [
			'bg-blue-500',
			'bg-emerald-500',
			'bg-violet-500',
			'bg-pink-500',
			'bg-orange-500',
			'bg-teal-500'
		];
		const hash = str.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
		return colors[hash % colors.length];
	};

	$: bgColor = getColorFromName(name);
</script>

{#if src}
	<img
		{src}
		alt={name}
		class="rounded-full object-cover {sizeClass}"
	/>
{:else}
	<div class="flex items-center justify-center rounded-full font-semibold text-white {sizeClass} {bgColor}">
		{initials}
	</div>
{/if}
