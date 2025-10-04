import { PUBLIC_API_BASE } from '$env/static/public';

export const api = (path: string) => `${PUBLIC_API_BASE}${path}`;
