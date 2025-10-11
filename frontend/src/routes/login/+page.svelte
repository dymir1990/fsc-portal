<script>
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
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      if (resetError) {
        error = resetError.message;
      } else {
        success = 'Password reset link sent! Check your email.';
        showForgotPassword = false;
      }
    } catch (e) {
      error = 'Failed to send reset email. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="signin-container">
  <div class="signin-box">
    <h1>FSC Portal</h1>
    <p class="subtitle">Staff Sign In</p>
    
    <form onsubmit={(e) => { e.preventDefault(); showForgotPassword ? handleForgotPassword() : handleSignIn(); }}>
      {#if error}
        <div class="error">{error}</div>
      {/if}

      {#if success}
        <div class="success">{success}</div>
      {/if}

      <div class="form-group">
        <label for="email">Email</label>
        <input
          id="email"
          type="email"
          bind:value={email}
          placeholder="your.email@fscnj.com"
          required
        />
      </div>

      {#if !showForgotPassword}
        <div class="form-group">
          <label for="password">Password</label>
          <input
            id="password"
            type="password"
            bind:value={password}
            placeholder="••••••••"
            required
          />
        </div>
      {/if}

      <button type="submit" disabled={loading}>
        {#if loading}
          {showForgotPassword ? 'Sending...' : 'Signing in...'}
        {:else}
          {showForgotPassword ? 'Send Reset Link' : 'Sign In'}
        {/if}
      </button>

      <div class="forgot-password-toggle">
        <button
          type="button"
          class="text-link"
          onclick={() => { showForgotPassword = !showForgotPassword; error = ''; success = ''; }}
        >
          {showForgotPassword ? '← Back to Sign In' : 'Forgot Password?'}
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  .signin-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }
  
  .signin-box {
    background: white;
    padding: 3rem;
    border-radius: 12px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    width: 100%;
    max-width: 400px;
  }
  
  h1 {
    margin: 0 0 0.5rem 0;
    color: #333;
    text-align: center;
  }
  
  .subtitle {
    text-align: center;
    color: #666;
    margin-bottom: 2rem;
  }
  
  .form-group {
    margin-bottom: 1.5rem;
  }
  
  label {
    display: block;
    margin-bottom: 0.5rem;
    color: #333;
    font-weight: 500;
  }
  
  input {
    width: 100%;
    padding: 0.75rem;
    border: 2px solid #e0e0e0;
    border-radius: 6px;
    font-size: 1rem;
    transition: border-color 0.2s;
  }
  
  input:focus {
    outline: none;
    border-color: #667eea;
  }
  
  button {
    width: 100%;
    padding: 0.875rem;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
  }
  
  button:hover:not(:disabled) {
    background: #5568d3;
  }
  
  button:disabled {
    background: #ccc;
    cursor: not-allowed;
  }
  
  .error {
    background: #fee;
    color: #c33;
    padding: 0.75rem;
    border-radius: 6px;
    margin-bottom: 1rem;
    font-size: 0.9rem;
  }

  .success {
    background: #e6ffe6;
    color: #2d7a2d;
    padding: 0.75rem;
    border-radius: 6px;
    margin-bottom: 1rem;
    font-size: 0.9rem;
  }

  .forgot-password-toggle {
    margin-top: 1rem;
    text-align: center;
  }

  .text-link {
    background: none;
    border: none;
    color: #667eea;
    cursor: pointer;
    font-size: 0.9rem;
    padding: 0.5rem;
    text-decoration: none;
    transition: color 0.2s;
  }

  .text-link:hover {
    color: #5568d3;
    text-decoration: underline;
  }
</style>
