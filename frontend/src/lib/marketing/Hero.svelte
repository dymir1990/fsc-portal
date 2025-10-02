<script lang="ts">
  export let eyebrow = 'Introducing';
  export let title = 'A clearer path to billing & reporting';
  export let subtitle = 'Bring SimplePractice session data, payer routes, and internal billing workflows into one focused internal portal.';
  export let ctaPrimary: { label: string; href: string } = { label: 'Get Started', href: '/login' };
  export let ctaSecondary: { label: string; href: string } = { label: 'Import a CSV', href: '/case-manager/import' };
</script>

<section class="relative overflow-hidden">
  <!-- background gradient / subtle pattern -->
  <div class="pointer-events-none absolute inset-0 -z-10 bg-gradient-to-b from-brand-50 via-white to-white"></div>
  <div class="mx-auto max-w-7xl px-6 pb-20 pt-24 sm:pt-28 lg:flex lg:items-center lg:gap-12 lg:pt-32">
    <div class="mx-auto max-w-2xl text-center lg:mx-0 lg:text-left">
      <p class="mb-4 inline-block rounded-full bg-brand-100 px-3 py-1 text-xs font-medium tracking-wide text-brand-700 ring-1 ring-inset ring-brand-200">{eyebrow}</p>
      <h1 class="text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">
        {title}
      </h1>
      <p class="mt-6 text-base leading-7 text-slate-600 sm:text-lg sm:leading-8">{subtitle}</p>
      <div class="mt-8 flex flex-col items-center gap-3 sm:flex-row lg:justify-start">
        <a href={ctaPrimary.href} class="inline-flex w-full items-center justify-center rounded-lg bg-brand-600 px-6 py-3 text-sm font-medium text-white shadow-sm transition hover:bg-brand-700 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 sm:w-auto">{ctaPrimary.label}</a>
        <a href={ctaSecondary.href} class="inline-flex w-full items-center justify-center rounded-lg border border-slate-300 bg-white px-6 py-3 text-sm font-medium text-slate-700 shadow-sm transition hover:bg-slate-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500 sm:w-auto">{ctaSecondary.label}</a>
      </div>
    </div>
  </div>
</section>

<style>
  /* The template uses layered gradients; we keep a light version here */
</style>
