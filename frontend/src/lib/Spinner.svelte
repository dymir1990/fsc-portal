<script lang="ts">
  export let size: number = 16;
  export let light = false;
</script>

<span
  class="inline-block animate-spin rounded-full border-2 border-current border-t-transparent"
  style={`width:${size}px;height:${size}px;`}
  class:opacity-70={light}
  aria-hidden="true"
></span>
