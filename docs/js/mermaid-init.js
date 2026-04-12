// Initialize Mermaid diagrams on page load
document.addEventListener("DOMContentLoaded", function() {
  if (typeof mermaid !== "undefined") {
    mermaid.contentLoaded();
    mermaid.initialize({ 
      startOnLoad: true,
      theme: 'default',
      securityLevel: 'loose'
    });
  }
});
