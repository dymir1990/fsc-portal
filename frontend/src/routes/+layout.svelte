<script lang="ts">
  import favicon from '$lib/assets/favicon.svg';
  import '/src/app.css';
  import { PUBLIC_BACKEND_URL } from '$env/static/public';
  // Build identifier (replace at build time via Vite define or env-pass). For now, inject from a global if present.
  // We'll attempt to read a window.__BUILD_HASH set in app.html (optional). Fallback to 'dev'.
  let buildHash: string = 'dev';
  if (typeof window !== 'undefined' && (window as any).__BUILD_HASH) {
    buildHash = (window as any).__BUILD_HASH;
  }

  let { children } = $props();
  import { onMount } from 'svelte';

  // health status for backend
  let backendHealthy: boolean | null = null;

  async function checkHealth() {
    try {
      const res = await fetch(`${PUBLIC_BACKEND_URL}/health`, { cache: 'no-store' });
      backendHealthy = res.ok;
    } catch (e) {
      backendHealthy = false;
    }
  }

  onMount(() => {
    checkHealth();
    // poll occasionally so header feels active
    const id = setInterval(checkHealth, 15_000);
    return () => clearInterval(id);
  });
</script>

<svelte:head>
  <link rel="icon" href={favicon} />
</svelte:head>

<header class="sticky top-0 z-10 border-b border-gray-200 bg-brand-600/90 backdrop-blur">
  <div class="mx-auto flex max-w-6xl items-center justify-between px-5 py-3 text-white">
  <a href="/dashboard" class="font-semibold tracking-wide">FSC Portal</a>
  <span class="ml-3 rounded bg-white/10 px-2 py-0.5 text-[11px] font-mono opacity-80">{buildHash}</span>
    <nav class="space-x-4 text-sm">
      <a class="hover:underline" href="/dashboard">Dashboard</a>
      <a class="hover:underline" href="/case-manager/import">Import</a>
      <!-- backend health indicator -->
      <span class="ml-3 inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-0.5 text-xs">
        <span class="h-2 w-2 rounded-full" aria-hidden="true" class:bg-emerald-400={backendHealthy === true} class:bg-amber-300={backendHealthy === null} class:bg-rose-400={backendHealthy === false}></span>
        <span>{backendHealthy === null ? 'checking' : (backendHealthy ? 'backend OK' : 'backend down')}</span>
        {#if backendHealthy === null}
          <span class="spinner" aria-hidden="true"></span>
        {/if}
      </span>
    </nav>
  </div>
  </header>

<main class="min-h-screen p-5 sm:p-8">
  {@render children?.()}
</main>
