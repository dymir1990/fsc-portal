<script context="module">
  export const ssr = false;
</script>

<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabaseClient';
  import { env } from '$env/dynamic/public';
  
  let selectedFile = null;
  let uploading = false;
  let uploadProgress = 0;
  let uploadResult = null;
  let errorMessage = '';
  let importHistory = [];
  let dragOver = false;

  // Get auth token from Supabase
  async function getAuthToken() {
    const { data: { session } } = await supabase.auth.getSession();
    return session?.access_token;
  }
  
  // Load import history on mount
  onMount(async () => {
    await loadImportHistory();
  });

  async function loadImportHistory() {
    try {
      const token = await getAuthToken();
      if (!token) {
        goto('/login');
        return;
      }

      const response = await fetch(`${env.PUBLIC_API_BASE}/api/import/history`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        importHistory = await response.json();
      }
    } catch (error) {
      console.error('Error loading import history:', error);
    }
  }

  function handleFileSelect(event) {
    const file = event.target.files[0];
    if (file && file.name.endsWith('.csv')) {
      selectedFile = file;
      errorMessage = '';
    } else {
      errorMessage = 'Please select a valid CSV file';
      selectedFile = null;
    }
  }

  function handleDragOver(event) {
    event.preventDefault();
    dragOver = true;
  }

  function handleDragLeave() {
    dragOver = false;
  }

  function handleDrop(event) {
    event.preventDefault();
    dragOver = false;
    
    const file = event.dataTransfer.files[0];
    if (file && file.name.endsWith('.csv')) {
      selectedFile = file;
      errorMessage = '';
    } else {
      errorMessage = 'Please drop a valid CSV file';
    }
  }

  async function uploadCSV() {
    if (!selectedFile) return;

    uploading = true;
    uploadProgress = 0;
    errorMessage = '';
    uploadResult = null;

    try {
      const token = await getAuthToken();
      if (!token) {
        goto('/login');
        return;
      }

      const formData = new FormData();
      formData.append('file', selectedFile);

      const xhr = new XMLHttpRequest();

      // Track upload progress
      xhr.upload.addEventListener('progress', (e) => {
        if (e.lengthComputable) {
          uploadProgress = Math.round((e.loaded / e.total) * 100);
        }
      });

      // Handle completion
      xhr.addEventListener('load', async () => {
        if (xhr.status === 200) {
          uploadResult = JSON.parse(xhr.responseText);
          selectedFile = null;
          await loadImportHistory();
        } else {
          const error = JSON.parse(xhr.responseText);
          errorMessage = error.detail || 'Upload failed';
        }
        uploading = false;
      });

      // Handle errors
      xhr.addEventListener('error', () => {
        errorMessage = 'Network error during upload';
        uploading = false;
      });

      xhr.open('POST', `${env.PUBLIC_API_BASE}/api/import`);
      xhr.setRequestHeader('Authorization', `Bearer ${token}`);
      xhr.send(formData);

    } catch (error) {
      errorMessage = error.message || 'Upload failed';
      uploading = false;
    }
  }

  function formatDate(dateString) {
    return new Date(dateString).toLocaleString();
  }

  function clearResult() {
    uploadResult = null;
    errorMessage = '';
  }
</script>

<div class="import-page">
  <div class="header">
    <div>
      <h1>Import CSV Data</h1>
      <p>Upload SimplePractice CSV files to import client sessions and billing data</p>
    </div>
    <button class="back-btn" on:click={() => goto('/dashboard')}>
      ← Back to Dashboard
    </button>
  </div>

  <!-- Upload Section -->
  <div class="upload-section">
    <div 
      class="dropzone" 
      class:drag-over={dragOver}
      class:has-file={selectedFile}
      on:dragover={handleDragOver}
      on:dragleave={handleDragLeave}
      on:drop={handleDrop}
    >
      {#if !selectedFile}
        <div class="dropzone-content">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="17 8 12 3 7 8" />
            <line x1="12" y1="3" x2="12" y2="15" />
          </svg>
          <h3>Drop CSV file here</h3>
          <p>or</p>
          <label class="file-label">
            <input 
              type="file" 
              accept=".csv" 
              on:change={handleFileSelect}
              disabled={uploading}
            />
            <span class="file-button">Choose File</span>
          </label>
        </div>
      {:else}
        <div class="file-selected">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z" />
            <polyline points="13 2 13 9 20 9" />
          </svg>
          <div class="file-info">
            <p class="file-name">{selectedFile.name}</p>
            <p class="file-size">{(selectedFile.size / 1024).toFixed(2)} KB</p>
          </div>
          {#if !uploading}
            <button class="remove-btn" on:click={() => selectedFile = null}>×</button>
          {/if}
        </div>
      {/if}
    </div>

    {#if selectedFile && !uploading}
      <button class="upload-btn" on:click={uploadCSV}>
        Upload CSV
      </button>
    {/if}

    {#if uploading}
      <div class="progress-container">
        <div class="progress-bar">
          <div class="progress-fill" style="width: {uploadProgress}%"></div>
        </div>
        <p class="progress-text">Uploading... {uploadProgress}%</p>
      </div>
    {/if}

    {#if errorMessage}
      <div class="error-message">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10" />
          <line x1="12" y1="8" x2="12" y2="12" />
          <line x1="12" y1="16" x2="12.01" y2="16" />
        </svg>
        {errorMessage}
      </div>
    {/if}
  </div>

  <!-- Upload Result -->
  {#if uploadResult}
    <div class="result-section">
      <div class="result-header">
        <h2>Upload Complete!</h2>
        <button class="close-btn" on:click={clearResult}>×</button>
      </div>
      
      <div class="result-stats">
        <div class="stat-card success">
          <h3>{uploadResult.summary?.total_imported || 0}</h3>
          <p>Records Imported</p>
        </div>
        
        {#if uploadResult.summary?.duplicates_found > 0}
          <div class="stat-card warning">
            <h3>{uploadResult.summary.duplicates_found}</h3>
            <p>Duplicates Found</p>
          </div>
        {/if}
        
        {#if uploadResult.summary?.errors > 0}
          <div class="stat-card error">
            <h3>{uploadResult.summary.errors}</h3>
            <p>Errors</p>
          </div>
        {/if}
      </div>

      {#if uploadResult.duplicates && uploadResult.duplicates.length > 0}
        <div class="duplicates-section">
          <h3>Duplicate Records Detected</h3>
          <div class="duplicates-list">
            {#each uploadResult.duplicates as duplicate}
              <div class="duplicate-item">
                <div class="duplicate-icon">⚠️</div>
                <div class="duplicate-details">
                  <p class="duplicate-name"><strong>{duplicate.client_name}</strong></p>
                  <p class="duplicate-info">
                    Session: {duplicate.session_date} | Provider: {duplicate.provider_name}
                  </p>
                  <p class="duplicate-reason">{duplicate.reason}</p>
                </div>
              </div>
            {/each}
          </div>
        </div>
      {/if}
    </div>
  {/if}

  <!-- Import History -->
  {#if importHistory.length > 0}
    <div class="history-section">
      <h2>Recent Imports</h2>
      <div class="history-list">
        {#each importHistory as import_run}
          <div class="history-item">
            <div class="history-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z" />
                <polyline points="13 2 13 9 20 9" />
              </svg>
            </div>
            <div class="history-details">
              <p class="history-filename">{import_run.filename}</p>
              <p class="history-date">{formatDate(import_run.imported_at)}</p>
            </div>
            <div class="history-stats">
              <span class="stat-badge success">{import_run.records_imported} imported</span>
              {#if import_run.duplicates_found > 0}
                <span class="stat-badge warning">{import_run.duplicates_found} duplicates</span>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    </div>
  {/if}
</div>

<style>
  .import-page {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 2rem;
  }

  .header h1 {
    font-size: 2rem;
    font-weight: 700;
    margin: 0 0 0.5rem 0;
    color: #1a1a1a;
  }

  .header p {
    color: #666;
    margin: 0;
  }

  .back-btn {
    padding: 0.75rem 1.5rem;
    background: #f3f4f6;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
    color: #374151;
    transition: all 0.2s;
  }

  .back-btn:hover {
    background: #e5e7eb;
  }

  .upload-section {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
  }

  .dropzone {
    border: 2px dashed #d1d5db;
    border-radius: 12px;
    padding: 3rem;
    text-align: center;
    transition: all 0.3s;
    background: #fafafa;
  }

  .dropzone.drag-over {
    border-color: #3b82f6;
    background: #eff6ff;
  }

  .dropzone.has-file {
    border-color: #10b981;
    background: #f0fdf4;
  }

  .dropzone-content svg {
    color: #9ca3af;
    margin-bottom: 1rem;
  }

  .dropzone-content h3 {
    font-size: 1.25rem;
    color: #374151;
    margin-bottom: 0.5rem;
  }

  .dropzone-content p {
    color: #6b7280;
    margin: 1rem 0;
  }

  .file-label {
    display: inline-block;
    cursor: pointer;
  }

  .file-label input {
    display: none;
  }

  .file-button {
    display: inline-block;
    padding: 0.75rem 2rem;
    background: #3b82f6;
    color: white;
    border-radius: 8px;
    font-weight: 500;
    transition: all 0.2s;
  }

  .file-button:hover {
    background: #2563eb;
  }

  .file-selected {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .file-selected svg {
    color: #10b981;
    flex-shrink: 0;
  }

  .file-info {
    flex: 1;
    text-align: left;
  }

  .file-name {
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 0.25rem 0;
  }

  .file-size {
    color: #6b7280;
    font-size: 0.875rem;
    margin: 0;
  }

  .remove-btn {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: none;
    background: #fee2e2;
    color: #ef4444;
    font-size: 1.5rem;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
  }

  .remove-btn:hover {
    background: #fecaca;
  }

  .upload-btn {
    width: 100%;
    padding: 1rem;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    font-size: 1rem;
    cursor: pointer;
    margin-top: 1rem;
    transition: all 0.2s;
  }

  .upload-btn:hover {
    background: #2563eb;
  }

  .progress-container {
    margin-top: 1rem;
  }

  .progress-bar {
    width: 100%;
    height: 8px;
    background: #e5e7eb;
    border-radius: 4px;
    overflow: hidden;
  }

  .progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #3b82f6, #2563eb);
    transition: width 0.3s ease;
  }

  .progress-text {
    text-align: center;
    color: #6b7280;
    margin-top: 0.5rem;
    font-weight: 500;
  }

  .error-message {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 1rem;
    background: #fee2e2;
    border-radius: 8px;
    color: #dc2626;
    margin-top: 1rem;
  }

  .error-message svg {
    flex-shrink: 0;
  }

  .result-section {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
  }

  .result-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }

  .result-header h2 {
    color: #10b981;
    margin: 0;
    font-size: 1.5rem;
  }

  .close-btn {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: none;
    background: #f3f4f6;
    color: #6b7280;
    font-size: 1.5rem;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
  }

  .close-btn:hover {
    background: #e5e7eb;
  }

  .result-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .stat-card {
    padding: 1.5rem;
    border-radius: 8px;
    text-align: center;
  }

  .stat-card.success {
    background: #f0fdf4;
    border: 2px solid #10b981;
  }

  .stat-card.warning {
    background: #fffbeb;
    border: 2px solid #f59e0b;
  }

  .stat-card.error {
    background: #fee2e2;
    border: 2px solid #ef4444;
  }

  .stat-card h3 {
    font-size: 2rem;
    margin: 0 0 0.5rem 0;
  }

  .stat-card.success h3 { color: #10b981; }
  .stat-card.warning h3 { color: #f59e0b; }
  .stat-card.error h3 { color: #ef4444; }

  .stat-card p {
    color: #6b7280;
    margin: 0;
    font-weight: 500;
  }

  .duplicates-section {
    margin-top: 2rem;
    padding-top: 2rem;
    border-top: 1px solid #e5e7eb;
  }

  .duplicates-section h3 {
    color: #f59e0b;
    margin-bottom: 1rem;
  }

  .duplicates-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .duplicate-item {
    display: flex;
    gap: 1rem;
    padding: 1rem;
    background: #fffbeb;
    border-radius: 8px;
    border-left: 4px solid #f59e0b;
  }

  .duplicate-icon {
    font-size: 1.5rem;
    flex-shrink: 0;
  }

  .duplicate-details {
    flex: 1;
  }

  .duplicate-name {
    margin: 0 0 0.25rem 0;
    font-size: 1rem;
  }

  .duplicate-info {
    color: #6b7280;
    font-size: 0.875rem;
    margin: 0 0 0.25rem 0;
  }

  .duplicate-reason {
    color: #92400e;
    font-size: 0.875rem;
    margin: 0;
    font-style: italic;
  }

  .history-section {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .history-section h2 {
    margin: 0 0 1.5rem 0;
    color: #1a1a1a;
  }

  .history-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .history-item {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem;
    background: #f9fafb;
    border-radius: 8px;
    transition: all 0.2s;
  }

  .history-item:hover {
    background: #f3f4f6;
  }

  .history-icon {
    width: 48px;
    height: 48px;
    background: #eff6ff;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .history-icon svg {
    color: #3b82f6;
  }

  .history-details {
    flex: 1;
  }

  .history-filename {
    font-weight: 600;
    color: #1a1a1a;
    margin: 0 0 0.25rem 0;
  }

  .history-date {
    color: #6b7280;
    font-size: 0.875rem;
    margin: 0;
  }

  .history-stats {
    display: flex;
    gap: 0.5rem;
  }

  .stat-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.875rem;
    font-weight: 500;
  }

  .stat-badge.success {
    background: #d1fae5;
    color: #065f46;
  }

  .stat-badge.warning {
    background: #fed7aa;
    color: #92400e;
  }
</style>
