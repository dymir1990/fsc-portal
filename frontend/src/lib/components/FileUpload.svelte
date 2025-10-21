<script lang="ts">
  import { env } from '$env/dynamic/public';
  import { supabase } from '$lib/supabaseClient';

  type Props = {
    onUploadComplete?: (result: any) => void;
    onError?: (error: string) => void;
  };

  let { onUploadComplete, onError }: Props = $props();

  let isDragging = $state(false);
  let isUploading = $state(false);
  let uploadProgress = $state(0);
  let selectedFile = $state<File | null>(null);
  let uploadResult = $state<any>(null);
  let uploadError = $state<string | null>(null);

  const handleDragOver = (e: DragEvent) => {
    e.preventDefault();
    isDragging = true;
  };

  const handleDragLeave = (e: DragEvent) => {
    e.preventDefault();
    isDragging = false;
  };

  const handleDrop = (e: DragEvent) => {
    e.preventDefault();
    isDragging = false;

    const files = e.dataTransfer?.files;
    if (files && files.length > 0) {
      const file = files[0];
      if (file.name.toLowerCase().endsWith('.csv')) {
        selectedFile = file;
        uploadError = null;
      } else {
        uploadError = 'Please select a CSV file';
        if (onError) onError('Please select a CSV file');
      }
    }
  };

  const handleFileSelect = (e: Event) => {
    const target = e.target as HTMLInputElement;
    const files = target.files;
    if (files && files.length > 0) {
      const file = files[0];
      if (file.name.toLowerCase().endsWith('.csv')) {
        selectedFile = file;
        uploadError = null;
      } else {
        uploadError = 'Please select a CSV file';
        if (onError) onError('Please select a CSV file');
      }
    }
  };

  const uploadFile = async () => {
    if (!selectedFile) return;

    isUploading = true;
    uploadProgress = 0;
    uploadError = null;
    uploadResult = null;

    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session?.access_token) {
        throw new Error('Not authenticated');
      }

      const formData = new FormData();
      formData.append('file', selectedFile);

      // Simulate progress
      const progressInterval = setInterval(() => {
        uploadProgress = Math.min(uploadProgress + 10, 90);
      }, 200);

      const response = await fetch(`${env.PUBLIC_API_BASE}/api/imports/simplepractice`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${session.access_token}`
        },
        body: formData
      });

      clearInterval(progressInterval);
      uploadProgress = 100;

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({ detail: 'Upload failed' }));
        throw new Error(errorData.detail || 'Upload failed');
      }

      const result = await response.json();
      uploadResult = result;

      if (onUploadComplete) {
        onUploadComplete(result);
      }

      // Reset after successful upload
      setTimeout(() => {
        selectedFile = null;
        uploadProgress = 0;
        isUploading = false;
      }, 2000);

    } catch (error: any) {
      uploadError = error.message || 'Upload failed';
      if (onError) onError(uploadError);
      uploadProgress = 0;
      isUploading = false;
    }
  };

  const clearFile = () => {
    selectedFile = null;
    uploadError = null;
    uploadResult = null;
  };
</script>

<div class="space-y-4">
  <!-- Drop Zone -->
  <div
    class="relative rounded-2xl border-2 border-dashed transition-all {isDragging ? 'border-blue-500 bg-blue-50' : selectedFile ? 'border-emerald-500 bg-emerald-50' : 'border-slate-300 bg-white hover:border-slate-400'}"
    ondragover={handleDragOver}
    ondragleave={handleDragLeave}
    ondrop={handleDrop}
  >
    <div class="p-8">
      {#if selectedFile}
        <!-- Selected File -->
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <div class="flex h-14 w-14 items-center justify-center rounded-xl bg-emerald-100">
              <svg class="h-7 w-7 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <div>
              <p class="font-semibold text-slate-900">{selectedFile.name}</p>
              <p class="text-sm text-slate-500">{(selectedFile.size / 1024).toFixed(1)} KB</p>
            </div>
          </div>
          <button
            onclick={clearFile}
            class="rounded-lg p-2 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-600"
            disabled={isUploading}
          >
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      {:else}
        <!-- Drop Zone Content -->
        <div class="flex flex-col items-center text-center">
          <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
            <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
            </svg>
          </div>
          <p class="mb-2 text-lg font-semibold text-slate-900">
            Drop your CSV file here
          </p>
          <p class="mb-4 text-sm text-slate-500">
            or click to browse
          </p>
          <label class="cursor-pointer rounded-lg bg-blue-600 px-6 py-2.5 text-sm font-semibold text-white transition-all hover:bg-blue-700">
            Select File
            <input
              type="file"
              accept=".csv"
              class="hidden"
              onchange={handleFileSelect}
              disabled={isUploading}
            />
          </label>
        </div>
      {/if}
    </div>

    <!-- Drag Overlay -->
    {#if isDragging}
      <div class="absolute inset-0 flex items-center justify-center rounded-2xl bg-blue-500 bg-opacity-10">
        <p class="text-lg font-semibold text-blue-700">Drop file to upload</p>
      </div>
    {/if}
  </div>

  <!-- Upload Button -->
  {#if selectedFile && !isUploading && !uploadResult}
    <button
      onclick={uploadFile}
      class="w-full rounded-xl bg-gradient-to-r from-blue-600 to-teal-600 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:shadow-xl hover:scale-[1.02]"
    >
      Upload and Process
    </button>
  {/if}

  <!-- Progress Bar -->
  {#if isUploading}
    <div class="space-y-2">
      <div class="flex items-center justify-between text-sm">
        <span class="font-medium text-slate-700">Uploading...</span>
        <span class="text-slate-500">{uploadProgress}%</span>
      </div>
      <div class="h-2 overflow-hidden rounded-full bg-slate-200">
        <div
          class="h-full rounded-full bg-gradient-to-r from-blue-600 to-teal-600 transition-all duration-300"
          style="width: {uploadProgress}%"
        ></div>
      </div>
    </div>
  {/if}

  <!-- Success Message -->
  {#if uploadResult}
    <div class="rounded-xl border border-emerald-200 bg-emerald-50 p-4">
      <div class="flex items-start gap-3">
        <div class="flex h-6 w-6 items-center justify-center rounded-full bg-emerald-100">
          <svg class="h-4 w-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <div class="flex-1">
          <h4 class="font-semibold text-emerald-900">Upload Successful!</h4>
          <div class="mt-2 grid grid-cols-2 gap-2 text-sm text-emerald-700 sm:grid-cols-4">
            <div>
              <span class="font-medium">Total:</span> {uploadResult.total}
            </div>
            <div>
              <span class="font-medium">Inserted:</span> {uploadResult.inserted}
            </div>
            <div>
              <span class="font-medium">Updated:</span> {uploadResult.updated}
            </div>
            <div>
              <span class="font-medium">Flagged:</span> {uploadResult.flagged}
            </div>
          </div>
        </div>
      </div>
    </div>
  {/if}

  <!-- Error Message -->
  {#if uploadError}
    <div class="rounded-xl border border-red-200 bg-red-50 p-4">
      <div class="flex items-start gap-3">
        <div class="flex h-6 w-6 items-center justify-center rounded-full bg-red-100">
          <svg class="h-4 w-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </div>
        <div class="flex-1">
          <h4 class="font-semibold text-red-900">Upload Failed</h4>
          <p class="mt-1 text-sm text-red-700">{uploadError}</p>
        </div>
      </div>
    </div>
  {/if}
</div>
