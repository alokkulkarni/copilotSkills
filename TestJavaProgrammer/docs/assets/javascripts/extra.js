// Custom JavaScript for MkDocs

// Add copy button functionality to code blocks (if not provided by theme)
document.addEventListener('DOMContentLoaded', function() {
  // Add any custom JavaScript functionality here
  
  // Example: Log page views (for analytics)
  console.log('Page loaded:', document.title);
  
  // Example: Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
});

// Add external link indicator
document.addEventListener('DOMContentLoaded', function() {
  const links = document.querySelectorAll('a[href^="http"]');
  links.forEach(link => {
    if (!link.hostname.includes(window.location.hostname)) {
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  });
});
