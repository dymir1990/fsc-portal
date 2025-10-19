<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let { status = 404 } = $props<{ status?: number }>();

  const errorMessages = {
    404: {
      title: 'Page Not Found',
      description: "Sorry, we couldn't find the page you're looking for.",
      suggestion: 'The page might have been moved, deleted, or you might have entered the wrong URL.'
    },
    500: {
      title: 'Server Error',
      description: 'Something went wrong on our end.',
      suggestion: 'We apologize for the inconvenience. Please try again later or contact support if the problem persists.'
    }
  };

  const error = errorMessages[status as keyof typeof errorMessages] || errorMessages[404];

  onMount(() => {
    // Set page title
    document.title = `${status} - ${error.title} | FSC Portal`;
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

<div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 flex items-center justify-center px-4">
  <div class="max-w-md w-full text-center">
    <!-- Error Icon -->
    <div class="mb-8">
      <div class="mx-auto flex h-24 w-24 items-center justify-center rounded-full bg-gradient-to-br from-red-100 to-orange-100">
        {#if status === 404}
          <svg class="h-12 w-12 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        {:else}
          <svg class="h-12 w-12 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 18.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
        {/if}
      </div>
    </div>

    <!-- Error Code -->
    <div class="mb-4">
      <h1 class="text-6xl font-bold text-slate-900">{status}</h1>
    </div>

    <!-- Error Message -->
    <div class="mb-8">
      <h2 class="text-2xl font-semibold text-slate-800 mb-2">{error.title}</h2>
      <p class="text-slate-600 mb-4">{error.description}</p>
      <p class="text-sm text-slate-500">{error.suggestion}</p>
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
