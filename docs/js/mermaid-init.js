// Initialize Mermaid diagrams on page load
document.addEventListener("DOMContentLoaded", function() {
  if (typeof mermaid !== "undefined") {
    mermaid.initialize({ 
      startOnLoad: false,
      theme: 'default',
      securityLevel: 'loose'
    });
    mermaid.run({
      querySelector: '.mermaid'
    });
  }
});
