import { PUBLIC_API_BASE } from '$env/static/public';

// Default to production API if not set
const API_BASE = PUBLIC_API_BASE || 'https://api.fscnj.com';

export const api = (path: string) => {
    if (!PUBLIC_API_BASE) {
        console.warn('PUBLIC_API_BASE is not set, using default:', API_BASE);
    }
    return `${API_BASE}${path}`;
};
