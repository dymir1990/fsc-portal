<script>
  import { supabase } from '$lib/supabaseClient';
  import { goto } from '$app/navigation';

  let password = $state('');
  let confirmPassword = $state('');
  let error = $state('');
  let success = $state('');
  let loading = $state(false);

  async function handleResetPassword() {
    error = '';
    success = '';

    if (password !== confirmPassword) {
      error = 'Passwords do not match';
      return;
    }

    if (password.length < 6) {
      error = 'Password must be at least 6 characters';
      return;
    }

    loading = true;

    try {
      const { error: updateError } = await supabase.auth.updateUser({
        password: password
      });

      if (updateError) {
        error = updateError.message;
      } else {
        success = 'Password updated successfully! Redirecting...';
        setTimeout(() => {
          goto('/dashboard');
        }, 2000);
      }
    } catch (e) {
      error = 'Failed to reset password. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="reset-container">
  <div class="reset-box">
    <h1>Reset Password</h1>
    <p class="subtitle">Enter your new password</p>

    <form onsubmit={(e) => { e.preventDefault(); handleResetPassword(); }}>
      {#if error}
        <div class="error">{error}</div>
      {/if}

      {#if success}
        <div class="success">{success}</div>
      {/if}

      <div class="form-group">
        <label for="password">New Password</label>
        <input
          id="password"
          type="password"
          bind:value={password}
          placeholder="••••••••"
          required
          minlength="6"
        />
      </div>

      <div class="form-group">
        <label for="confirm-password">Confirm New Password</label>
        <input
          id="confirm-password"
          type="password"
          bind:value={confirmPassword}
          placeholder="••••••••"
          required
          minlength="6"
        />
      </div>

      <button type="submit" disabled={loading || success !== ''}>
        {loading ? 'Updating...' : 'Update Password'}
      </button>

      <div class="back-to-login">
        <a href="/login">← Back to Sign In</a>
      </div>
    </form>
  </div>
</div>

<style>
  .reset-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  .reset-box {
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

  .back-to-login {
    margin-top: 1rem;
    text-align: center;
  }

  .back-to-login a {
    color: #667eea;
    text-decoration: none;
    font-size: 0.9rem;
    transition: color 0.2s;
  }

  .back-to-login a:hover {
    color: #5568d3;
    text-decoration: underline;
  }
</style>
