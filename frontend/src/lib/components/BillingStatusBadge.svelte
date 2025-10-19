<script lang="ts">
  export let status: string;
  export let size: 'sm' | 'md' | 'lg' = 'md';
  
  const statusConfig = {
    completed: { 
      label: 'Completed', 
      color: 'bg-gray-100 text-gray-800 border-gray-200',
      icon: '✓'
    },
    documented: { 
      label: 'Documented', 
      color: 'bg-blue-100 text-blue-800 border-blue-200',
      icon: '📝'
    },
    ready_to_bill: { 
      label: 'Ready to Bill', 
      color: 'bg-yellow-100 text-yellow-800 border-yellow-200',
      icon: '💰'
    },
    submitted: { 
      label: 'Submitted', 
      color: 'bg-purple-100 text-purple-800 border-purple-200',
      icon: '📤'
    },
    pending: { 
      label: 'Pending', 
      color: 'bg-orange-100 text-orange-800 border-orange-200',
      icon: '⏳'
    },
    approved: { 
      label: 'Approved', 
      color: 'bg-green-100 text-green-800 border-green-200',
      icon: '✅'
    },
    paid: { 
      label: 'Paid', 
      color: 'bg-emerald-100 text-emerald-800 border-emerald-200',
      icon: '💵'
    },
    denied: { 
      label: 'Denied', 
      color: 'bg-red-100 text-red-800 border-red-200',
      icon: '❌'
    },
    appealing: { 
      label: 'Appealing', 
      color: 'bg-pink-100 text-pink-800 border-pink-200',
      icon: '🔄'
    }
  };
  
  const config = statusConfig[status] || statusConfig.completed;
  
  const sizeClasses = {
    sm: 'px-2 py-1 text-xs',
    md: 'px-3 py-1.5 text-sm',
    lg: 'px-4 py-2 text-base'
  };
</script>

<span class="inline-flex items-center rounded-full border font-medium {config.color} {sizeClasses[size]}">
  <span class="mr-1">{config.icon}</span>
  {config.label}
</span>
