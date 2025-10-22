<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabaseClient';

  type NavItem = {
    label: string;
    href: string;
    icon: string;
    roles: string[];
  };

  let { userRole = 'admin', isMobileMenuOpen = false } = $props<{ userRole?: string; isMobileMenuOpen?: boolean }>();

  // Nordic Clean Navigation - 4 Items Only
  const allNavItems: NavItem[] = [
    {
      label: 'Revenue',
      href: '/billing/revenue',
      icon: 'dollar',
      roles: ['admin', 'director', 'billing']
    },
    {
      label: 'Sessions',
      href: '/sessions',
      icon: 'clipboard',
      roles: ['admin', 'director', 'billing']
    },
    {
      label: 'Insurance',
      href: '/settings/payers',
      icon: 'building',
      roles: ['admin', 'director', 'billing']
    },
    {
      label: 'Settings',
      href: '/settings',
      icon: 'cog',
      roles: ['admin', 'director', 'billing']
    }
  ];

  const navItems = $derived(
    allNavItems.filter(item => item.roles.includes(userRole))
  );

  const isActive = (href: string) => {
    return $page.url.pathname === href || $page.url.pathname.startsWith(href + '/');
  };

  const handleNavClick = () => {
    // Close mobile menu when navigating
    if (typeof window !== 'undefined' && window.innerWidth < 1024) {
      isMobileMenuOpen = false;
    }
  };

  const getIcon = (iconName: string) => {
    const icons: Record<string, string> = {
      home: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
      clipboard: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2',
      upload: 'M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12',
      inbox: 'M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4',
      checklist: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4',
      dollar: 'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
      chart: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
      building: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4',
      wallet: 'M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z',
      users: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z',
      cog: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z'
    };
    return icons[iconName] || icons.home;
  };

  async function handleLogout() {
    await supabase.auth.signOut();
    window.location.href = '/login';
  }
</script>

<aside class="flex h-screen w-64 flex-col border-r border-slate-200 bg-white lg:translate-x-0 {isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'} fixed inset-y-0 left-0 z-50 lg:static lg:inset-auto transition-transform duration-300 ease-in-out">
  <!-- Logo -->
  <div class="flex h-16 items-center gap-3 border-b border-slate-200 px-6">
    <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-lg overflow-hidden">
      <img src="/400PngdpiLogo.png" alt="FSC Logo" class="h-8 w-8 object-contain" />
    </div>
    <div>
      <div class="text-sm font-bold text-fsc-navy-900">FSC Portal</div>
      <div class="text-xs text-slate-500 capitalize">{userRole}</div>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="flex-1 space-y-1 overflow-y-auto p-4">
    {#each navItems as item}
      <a
        href={item.href}
        onclick={handleNavClick}
        class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all {isActive(item.href)
          ? 'bg-gradient-to-r from-blue-50 to-purple-50 text-blue-700 shadow-sm'
          : 'text-slate-700 hover:bg-slate-50'}"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getIcon(item.icon)} />
        </svg>
        <span>{item.label}</span>
      </a>
    {/each}
  </nav>

  <!-- User Section -->
  <div class="border-t border-slate-200 p-4">
    <button
      onclick={handleLogout}
      class="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-slate-700 transition-all hover:bg-red-50 hover:text-red-700"
    >
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
      </svg>
      <span>Sign Out</span>
    </button>
  </div>
</aside>
