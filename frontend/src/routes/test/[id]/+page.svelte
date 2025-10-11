<script>
  let { data } = $props();
</script>

<h1>Dynamic Route Test</h1>

<div style="background: #f0f0f0; padding: 20px; border-radius: 8px;">
  <h2>ID: {data.id}</h2>
  <p><strong>Message:</strong> {data.message}</p>
  <p><strong>Fun Fact:</strong> {data.funFact}</p>
  <p><strong>Loaded at:</strong> {data.timestamp}</p>
</div>

<div style="margin-top: 20px;">
  <p>Try these URLs:</p>
  <ul>
    <li><a href="/test/123">/test/123</a></li>
    <li><a href="/test/hello">/test/hello</a></li>
    <li><a href="/test/sveltekit">/test/sveltekit</a></li>
  </ul>
</div>