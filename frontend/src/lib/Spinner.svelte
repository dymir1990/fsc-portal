<script lang="ts">
  export let size = 20;
</script>

<div class="spinner" style={`width:${size}px;height:${size}px`}></div>

<style>
  .spinner {
    border: 2px solid rgba(99, 102, 241, 0.25);
    border-top-color: rgba(79, 70, 229, 1);
    border-radius: 9999px;
    animation: spin 0.6s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>
