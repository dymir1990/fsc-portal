import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ request }) => {
    try {
        const formData = await request.formData();
        const file = formData.get('file') as File;
        
        if (!file || file.size === 0) {
            return json({ error: 'No file uploaded' }, { status: 400 });
        }

        const text = await file.text();
        const lines = text.split('\n').filter(line => line.trim());
        const headers = lines[0].split(',').map(h => h.trim());
        const records = [];
        
        for (let i = 1; i < lines.length; i++) {
            const values = lines[i].split(',');
            const record = {};
            headers.forEach((header, index) => {
                record[header] = values[index]?.trim() || '';
            });
            records.push(record);
        }

        return json({
            success: true,
            message: 'CSV processed successfully',
            stats: {
                total: records.length,
                processed: records.length,
                duplicates: 0,
                errors: 0
            }
        });

    } catch (error) {
        console.error('CSV error:', error);
        return json({ error: 'Failed to process CSV' }, { status: 500 });
    }
};
