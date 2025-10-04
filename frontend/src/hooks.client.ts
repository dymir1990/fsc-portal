import { supabase } from '$lib/supabaseClient';
import type { Handle } from '@sveltejs/kit';

export const handle: Handle = async ({ event, resolve }) => {
  // Let login page always render
  if (event.url.pathname.startsWith('/login')) return resolve(event);

  const { data } = await supabase.auth.getUser();
  // Not logged in → go to login
  if (!data.user) {
    window.location.href = '/login';
    return new Response('Redirecting...', { status: 302 });
  }

  return resolve(event);
};
