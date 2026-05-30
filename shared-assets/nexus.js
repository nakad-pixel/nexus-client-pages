/* ==============================================
   NEXUS WEB SYSTEMS — Shared JS Utilities
   ============================================== */

'use strict';

// ── Intersection Observer for fade-up animations ──
const nexusObserver = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.style.opacity = '1';
      e.target.style.transform = 'translateY(0)';
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('[data-nexus-reveal]').forEach(el => {
  el.style.opacity = '0';
  el.style.transform = 'translateY(30px)';
  el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
  nexusObserver.observe(el);
});

// ── Contact / Lead Form Handler ──
function nexusInitForm(formId, webhookUrl) {
  const form = document.getElementById(formId);
  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = form.querySelector('[type=submit]');
    const originalText = btn.textContent;
    btn.textContent = 'Sending...';
    btn.disabled = true;

    const data = Object.fromEntries(new FormData(form));
    data.page_url   = window.location.href;
    data.referrer   = document.referrer;
    data.timestamp  = new Date().toISOString();

    try {
      // Send to n8n webhook (replace webhookUrl per client)
      if (webhookUrl) {
        await fetch(webhookUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });
      }
      // WhatsApp fallback
      const phone   = form.dataset.whatsapp || '919999999999';
      const message = encodeURIComponent(`New inquiry from ${data.name || 'website'}\nEmail: ${data.email || '—'}\nPhone: ${data.phone || '—'}\nMessage: ${data.message || '—'}`);
      btn.textContent = '✅ Sent! Redirecting...';
      setTimeout(() => { window.open(`https://wa.me/${phone}?text=${message}`, '_blank'); btn.textContent = originalText; btn.disabled = false; }, 1500);
    } catch (err) {
      btn.textContent = '❌ Error — Try WhatsApp';
      setTimeout(() => { btn.textContent = originalText; btn.disabled = false; }, 3000);
    }
  });
}

// ── Smooth anchor scroll ──
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'));
    if (target) { e.preventDefault(); target.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
  });
});

// ── Simple Analytics ping (privacy-safe) ──
function nexusTrack(event, props = {}) {
  const payload = { event, props, url: location.href, t: Date.now() };
  // Swap with your preferred analytics endpoint
  if (navigator.sendBeacon) navigator.sendBeacon('/api/track', JSON.stringify(payload));
}

window.nexusTrack = nexusTrack;
window.nexusInitForm = nexusInitForm;
