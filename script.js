/* BookBazaar Landing Page — minimal interactivity only */

(function () {
  'use strict';

  // Smooth scroll for any in-page anchor links
  document.addEventListener('click', function (e) {
    var target = e.target.closest('a[href^="#"]');
    if (!target) return;
    var id = target.getAttribute('href').slice(1);
    var el = document.getElementById(id);
    if (el) {
      e.preventDefault();
      el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });

  // Add a subtle scroll shadow to the nav
  var nav = document.querySelector('.nav');
  if (nav) {
    window.addEventListener('scroll', function () {
      if (window.scrollY > 10) {
        nav.style.boxShadow = '0 2px 8px rgb(0 0 0 / 0.08)';
      } else {
        nav.style.boxShadow = 'none';
      }
    }, { passive: true });
  }
})();
