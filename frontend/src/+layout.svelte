<script lang="ts">
  // simple layout shell; we’ll plug real links later
  const nav = [
    { name: 'Dashboard', href: '/dashboard' },
    { name: 'Import CSV', href: '/case-manager/import' },
    { name: 'Sessions', href: '/sessions' },
    { name: 'Payers', href: '/payers' }
  ];
</script>

<div class="min-h-screen bg-slate-50 flex">
  <!-- Sidebar -->
  <aside class="w-64 bg-white border-r hidden md:block">
    <div class="p-4 font-semibold text-slate-800">Fresh Start</div>
    <nav class="px-2 space-y-1">
      {#each nav as item}
        <a class="block rounded px-3 py-2 hover:bg-slate-100" href={item.href}>{item.name}</a>
      {/each}
    </nav>
  </aside>

  <!-- Main -->
  <div class="flex-1 flex flex-col">
    <!-- Topbar -->
    <header class="h-14 bg-white border-b flex items-center justify-between px-4">
      <div class="font-medium text-slate-700">FSC Portal</div>
      <div class="text-sm text-slate-500">Signed in</div>
    </header>

    <!-- Page content -->
    <main class="p-4">
      <slot />
    </main>
  </div>
</div>