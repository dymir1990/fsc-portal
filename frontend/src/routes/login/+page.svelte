<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { goto } from '$app/navigation';

  let email = $state('');
  let password = $state('');
  let error = $state('');
  let success = $state('');
  let loading = $state(false);
  let showForgotPassword = $state(false);

  async function handleSignIn() {
    loading = true;
    error = '';
    success = '';

    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (signInError) {
        error = signInError.message;
      } else {
        // Success! Redirect to dashboard
        goto('/dashboard');
      }
    } catch (e) {
      error = 'An error occurred. Please try again.';
    } finally {
      loading = false;
    }
  }

  async function handleForgotPassword() {
    if (!email) {
      error = 'Please enter your email address';
      return;
    }

    loading = true;
    error = '';
    success = '';

    try {
      console.log('Attempting password reset for:', email);
      console.log('Redirect URL:', `${window.location.origin}/reset-password`);

      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      console.log('Reset response:', { resetError });

      if (resetError) {
        console.error('Password reset error:', resetError);
        error = resetError.message;
      } else {
        console.log('Password reset email sent successfully');
        success = 'Password reset link sent! Check your email.';
        showForgotPassword = false;
      }
    } catch (e) {
      console.error('Password reset exception:', e);
      error = 'Failed to send reset email. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 flex items-center justify-center px-4">
  <div class="max-w-md w-full">
    <!-- Logo and Branding -->
    <div class="text-center mb-8">
      <div class="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-white shadow-lg border border-slate-200">
        <img src="/400PngdpiLogo.png" alt="Fresh Start Counseling Logo" class="h-12 w-auto object-contain" />
      </div>
      <h1 class="text-2xl font-bold text-fsc-navy-900">Fresh Start Counseling</h1>
      <p class="text-slate-600 mt-1 text-sm">Staff Portal</p>
    </div>

    <!-- Login Form -->
    <div class="bg-white rounded-2xl shadow-xl border border-slate-200 p-8">
      <div class="mb-8">
        <h2 class="text-xl font-semibold text-slate-900 text-center">
          {showForgotPassword ? 'Reset Password' : 'Sign In'}
        </h2>
        <p class="text-slate-500 text-center mt-1 text-sm">
          {showForgotPassword ? 'Enter your email to receive a reset link' : 'Access your dashboard'}
        </p>
      </div>

      <form onsubmit={(e) => { e.preventDefault(); showForgotPassword ? handleForgotPassword() : handleSignIn(); }}>
        {#if error}
          <div class="mb-4 p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 text-sm">
            <div class="flex items-center gap-2">
              <svg class="h-4 w-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              {error}
            </div>
          </div>
        {/if}

        {#if success}
          <div class="mb-4 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm">
            <div class="flex items-center gap-2">
              <svg class="h-4 w-4 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              {success}
            </div>
          </div>
        {/if}

        <!-- Email Field -->
        <div class="mb-4">
          <label for="email" class="block text-sm font-medium text-slate-700 mb-2">Email</label>
          <input
            id="email"
            type="email"
            bind:value={email}
            placeholder="your.email@fscnj.com"
            required
            class="w-full px-3 py-2.5 rounded-lg border border-slate-300 bg-white text-slate-900 placeholder-slate-400 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 focus:outline-none transition-all text-sm"
          />
        </div>

        <!-- Password Field (only show if not forgot password) -->
        {#if !showForgotPassword}
          <div class="mb-6">
            <label for="password" class="block text-sm font-medium text-slate-700 mb-2">Password</label>
            <input
              id="password"
              type="password"
              bind:value={password}
              placeholder="Enter your password"
              required
              class="w-full px-3 py-2.5 rounded-lg border border-slate-300 bg-white text-slate-900 placeholder-slate-400 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 focus:outline-none transition-all text-sm"
            />
          </div>
        {/if}

        <!-- Submit Button -->
        <button
          type="submit"
          disabled={loading}
          class="w-full bg-blue-600 text-white font-medium py-2.5 px-4 rounded-lg hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 text-sm"
        >
          {#if loading}
            <div class="spinner h-5 w-5 border-2"></div>
            {showForgotPassword ? 'Sending...' : 'Signing in...'}
          {:else}
            {#if showForgotPassword}
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              Send Reset Link
            {:else}
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
              </svg>
              Sign In
            {/if}
          {/if}
        </button>

        <!-- Forgot Password Toggle -->
        <div class="mt-6 text-center">
          <button
            type="button"
            onclick={() => { showForgotPassword = !showForgotPassword; error = ''; success = ''; }}
            class="text-blue-600 hover:text-blue-700 text-sm transition-colors"
          >
            {showForgotPassword ? '← Back to Sign In' : 'Forgot your password?'}
          </button>
        </div>
      </form>
    </div>

    <!-- Footer -->
    <div class="text-center mt-8 text-sm text-slate-500">
      <p>Need help? Contact support at <a href="mailto:support@fscnj.com" class="text-blue-600 hover:text-blue-700">support@fscnj.com</a></p>
    </div>
  </div>
</div>
