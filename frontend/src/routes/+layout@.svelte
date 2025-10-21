<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  onMount(() => {
    // Set page title
    document.title = '404 - Page Not Found | FSC Portal';
  });

  const goHome = () => {
    goto('/dashboard');
  };

  const goBack = () => {
    if (typeof window !== 'undefined' && window.history.length > 1) {
      window.history.back();
    } else {
      goto('/dashboard');
    }
  };
</script>

<svelte:head>
  <meta name="robots" content="noindex, nofollow" />
</svelte:head>

<div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 flex items-center justify-center px-4">
  <div class="max-w-md w-full text-center">
    <!-- 404 Icon -->
    <div class="mb-8">
      <div class="mx-auto flex h-24 w-24 items-center justify-center rounded-full bg-gradient-to-br from-blue-100 to-purple-100">
        <svg class="h-12 w-12 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
    </div>

    <!-- Error Code -->
    <div class="mb-4">
      <h1 class="text-6xl font-bold text-slate-900">404</h1>
    </div>

    <!-- Error Message -->
    <div class="mb-8">
      <h2 class="text-2xl font-semibold text-slate-800 mb-2">Page Not Found</h2>
      <p class="text-slate-600 mb-4">Sorry, we couldn't find the page you're looking for.</p>
      <p class="text-sm text-slate-500">The page might have been moved, deleted, or you might have entered the wrong URL.</p>
    </div>

    <!-- Action Buttons -->
    <div class="flex flex-col gap-3 sm:flex-row sm:justify-center">
      <button
        onclick={goBack}
        class="flex items-center justify-center gap-2 rounded-xl border-2 border-slate-200 bg-white px-6 py-3 text-sm font-semibold text-slate-700 transition-all hover:border-slate-300 hover:bg-slate-50"
      >
        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Go Back
      </button>
      
      <button
        onclick={goHome}
        class="flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-3 text-sm font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
      >
        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
        Go to Dashboard
      </button>
    </div>

    <!-- Help Text -->
    <div class="mt-8 text-xs text-slate-400">
      <p>Need help? Contact support at <a href="mailto:support@fscnj.com" class="text-blue-500 hover:text-blue-600">support@fscnj.com</a></p>
    </div>
  </div>
</div>


