/* PERPAKSINAS – animasi situs: Lenis (scroll halus), GSAP + ScrollTrigger (reveal & hitung angka), Motion (menu & tombol).
   Dimuat setelah assets/vendor/*. Dimatikan otomatis bila pengguna memilih prefers-reduced-motion. */
(function () {
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var hasGsap = !!window.gsap && !!window.ScrollTrigger;
  var M = window.Motion;

  // 1. Scroll halus dengan Lenis, disinkronkan ke ticker GSAP.
  if (!reduce && window.Lenis && hasGsap) {
    var lenis = new Lenis({ duration: 1.1, smoothWheel: true, anchors: true });
    lenis.on('scroll', ScrollTrigger.update);
    gsap.ticker.add(function (time) { lenis.raf(time * 1000); });
    gsap.ticker.lagSmoothing(0);
    // Area yang punya scroll horizontal sendiri tidak boleh dibajak Lenis.
    document.querySelectorAll('.news-list, .kat-tabs, .ad-toc').forEach(function (el) {
      el.setAttribute('data-lenis-prevent', '');
    });
  }

  if (reduce || !hasGsap) return;
  gsap.registerPlugin(ScrollTrigger);

  // 2. Intro header.
  gsap.from('header.site', { y: -16, opacity: 0, duration: 0.6, ease: 'power3.out', clearProps: 'transform,opacity' });

  // 3. Reveal bagian dan kartu saat masuk layar.
  var groups = ['section.block', '.hero-grid > *', '.timeline > *', '.grid > *', '.pengurus-grid > *', '.layanan-grid > *', '.values > *', 'article.pasal'];
  groups.forEach(function (sel) {
    document.querySelectorAll(sel).forEach(function (el) {
      if (el.closest('.news-list')) return;
      gsap.fromTo(el,
        { opacity: 0, y: 28 },
        {
          opacity: 1, y: 0, duration: 0.8, ease: 'power3.out', clearProps: 'transform,opacity',
          scrollTrigger: { trigger: el, start: 'top 88%', once: true }
        });
    });
  });

  // 4. Angka statistik berhitung naik saat terlihat.
  document.querySelectorAll('.stat .num').forEach(function (el) {
    var raw = el.textContent.trim();
    if (!/^[\d.]+$/.test(raw)) return;
    var target = parseInt(raw.replace(/\./g, ''), 10);
    if (!isFinite(target)) return;
    var obj = { v: 0 };
    gsap.to(obj, {
      v: target, duration: 1.4, ease: 'power2.out',
      scrollTrigger: { trigger: el, start: 'top 90%', once: true },
      onUpdate: function () { el.textContent = Math.round(obj.v).toLocaleString('id-ID'); }
    });
  });

  // 5. Motion: menu mobile masuk dengan animasi.
  var nav = document.getElementById('nav-main');
  if (M && nav) {
    new MutationObserver(function () {
      if (nav.classList.contains('open')) {
        M.animate(nav, { opacity: [0, 1], transform: ['translateY(-8px)', 'translateY(0px)'] }, { duration: 0.25 });
      }
    }).observe(nav, { attributes: true, attributeFilter: ['class'] });
  }

  // 6. Motion: tombol memberi respons tekan.
  if (M) {
    document.addEventListener('pointerdown', function (e) {
      var el = e.target.closest && e.target.closest('.btn-light, .btn-ghost, .btn-src, .news-nav button');
      if (el) M.animate(el, { transform: ['scale(0.96)', 'scale(1)'] }, { duration: 0.2 });
    });
  }
})();
