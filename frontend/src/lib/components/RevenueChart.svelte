<script lang="ts">
  type TrendData = {
    month: string;
    month_key: string;
    sessions: number;
    billed: number;
    collected: number;
  };

  type Props = {
    trends: TrendData[];
  };

  let { trends }: Props = $props();

  // Calculate max value for scaling
  const maxValue = $derived(
    Math.max(...trends.map(t => Math.max(t.billed, t.collected)), 1)
  );

  const getBarHeight = (value: number) => {
    return `${(value / maxValue) * 100}%`;
  };

  const formatCurrency = (value: number) => {
    return `$${value.toLocaleString(undefined, {minimumFractionDigits: 0, maximumFractionDigits: 0})}`;
  };
</script>

<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
  <div class="mb-6">
    <h3 class="text-lg font-semibold text-fsc-navy-900">Revenue Trends</h3>
    <p class="mt-1 text-sm text-slate-600">Monthly billing and collection performance</p>
  </div>

  {#if trends.length === 0}
    <div class="flex flex-col items-center justify-center py-12 text-center">
      <div class="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
        <svg class="h-8 w-8 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
      </div>
      <p class="text-slate-600">No revenue data yet</p>
      <p class="mt-1 text-sm text-slate-500">Data will appear after processing sessions</p>
    </div>
  {:else}
    <div class="space-y-4">
      <!-- Legend -->
      <div class="flex items-center justify-center gap-6 text-sm">
        <div class="flex items-center gap-2">
          <div class="h-3 w-3 rounded-full bg-blue-500"></div>
          <span class="text-slate-600">Billed</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="h-3 w-3 rounded-full bg-emerald-500"></div>
          <span class="text-slate-600">Collected</span>
        </div>
      </div>

      <!-- Chart -->
      <div class="flex items-end justify-between gap-2 h-64 px-2">
        {#each trends as trend}
          <div class="flex flex-1 flex-col items-center gap-2">
            <!-- Bars -->
            <div class="relative flex w-full items-end justify-center gap-1 h-52">
              <!-- Billed bar -->
              <div
                class="group relative w-full max-w-[32px] rounded-t-lg bg-blue-500 transition-all hover:bg-blue-600"
                style="height: {getBarHeight(trend.billed)}"
              >
                <div class="absolute bottom-full left-1/2 mb-2 hidden -translate-x-1/2 whitespace-nowrap rounded-lg bg-slate-900 px-2 py-1 text-xs text-white group-hover:block">
                  Billed: {formatCurrency(trend.billed)}
                </div>
              </div>
              <!-- Collected bar -->
              <div
                class="group relative w-full max-w-[32px] rounded-t-lg bg-emerald-500 transition-all hover:bg-emerald-600"
                style="height: {getBarHeight(trend.collected)}"
              >
                <div class="absolute bottom-full left-1/2 mb-2 hidden -translate-x-1/2 whitespace-nowrap rounded-lg bg-slate-900 px-2 py-1 text-xs text-white group-hover:block">
                  Collected: {formatCurrency(trend.collected)}
                </div>
              </div>
            </div>
            <!-- Month label -->
            <p class="text-xs font-medium text-slate-600 text-center">{trend.month}</p>
          </div>
        {/each}
      </div>

      <!-- Summary Stats -->
      <div class="grid grid-cols-3 gap-4 rounded-xl bg-slate-50 p-4">
        <div class="text-center">
          <p class="text-sm text-slate-600">Total Billed</p>
          <p class="mt-1 text-lg font-bold text-blue-600">
            {formatCurrency(trends.reduce((sum, t) => sum + t.billed, 0))}
          </p>
        </div>
        <div class="text-center">
          <p class="text-sm text-slate-600">Total Collected</p>
          <p class="mt-1 text-lg font-bold text-emerald-600">
            {formatCurrency(trends.reduce((sum, t) => sum + t.collected, 0))}
          </p>
        </div>
        <div class="text-center">
          <p class="text-sm text-slate-600">Collection Rate</p>
          <p class="mt-1 text-lg font-bold text-purple-600">
            {#if trends.reduce((sum, t) => sum + t.billed, 0) > 0}
              {Math.round((trends.reduce((sum, t) => sum + t.collected, 0) / trends.reduce((sum, t) => sum + t.billed, 0)) * 100)}%
            {:else}
              0%
            {/if}
          </p>
        </div>
      </div>
    </div>
  {/if}
</div>
