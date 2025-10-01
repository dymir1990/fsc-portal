import { supabase } from '$lib/supabaseClient';

supabase.auth.onAuthStateChange((_event, session) => {
  if (!session) {
    // if logged out, push them to login
    if (window.location.pathname !== '/login') {
      window.location.href = '/login';
    }
  }
});
