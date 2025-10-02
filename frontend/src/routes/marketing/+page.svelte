<script lang="ts">
  import Hero from '$lib/marketing/Hero.svelte';
</script>

<div class="min-h-screen bg-white">
  <Hero />
  <section class="mx-auto max-w-5xl px-6 pb-24">
    <div class="mt-16 grid gap-8 md:grid-cols-3">
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h3 class="text-sm font-semibold text-slate-900">Session Imports</h3>
        <p class="mt-2 text-sm text-slate-600">Upload SimplePractice exports and normalize sessions with duplicate detection.</p>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h3 class="text-sm font-semibold text-slate-900">Billing Routes</h3>
        <p class="mt-2 text-sm text-slate-600">Central payer directory surfaces correct submission portals & batching info.</p>
      </div>
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h3 class="text-sm font-semibold text-slate-900">Reporting (Soon)</h3>
        <p class="mt-2 text-sm text-slate-600">Track import velocity, flag rates, and payer distribution to guide staffing.</p>
      </div>
    </div>
  </section>
</div>
