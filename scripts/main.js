/* ============================================
   Dispatch QA Reports — Interactivity
   Pure vanilla JS. No frameworks.
   ============================================ */

(function () {
  "use strict";

  // ── Lightbox ──────────────────────────────
  function initLightbox() {
    const lightbox = document.getElementById("lightbox");
    if (!lightbox) return;

    const lightboxImg = lightbox.querySelector("img");
    const closeBtn = lightbox.querySelector(".lightbox__close");

    // Click any gallery image → open lightbox
    document.querySelectorAll(".gallery__item img").forEach(function (img) {
      img.addEventListener("click", function (e) {
        e.preventDefault();
        const src = img.dataset.full || img.src;
        lightboxImg.src = src;
        lightboxImg.alt = img.alt || "";
        lightbox.classList.add("active");
        document.body.style.overflow = "hidden";
      });
    });

    // Close lightbox on overlay click
    lightbox.addEventListener("click", function (e) {
      if (e.target === lightbox || e.target === closeBtn) {
        closeLightbox();
      }
    });

    // Close on Escape
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && lightbox.classList.contains("active")) {
        closeLightbox();
      }
    });

    function closeLightbox() {
      lightbox.classList.remove("active");
      document.body.style.overflow = "";
      lightboxImg.src = "";
    }
  }

  // ── Timestamp Formatting ──────────────────
  function initTimestamps() {
    document.querySelectorAll("[data-timestamp]").forEach(function (el) {
      var ts = el.dataset.timestamp;
      if (!ts) return;
      try {
        var date = new Date(ts);
        el.textContent = date.toLocaleString("en-US", {
          timeZone: "America/Toronto",
          year: "numeric",
          month: "short",
          day: "numeric",
          hour: "2-digit",
          minute: "2-digit",
          hour12: true,
          timeZoneName: "short",
        });
      } catch (e) {
        // leave original text
      }
    });
  }

  // ── Expand/Collapse All ───────────────────
  function initExpandCollapse() {
    var expandBtn = document.getElementById("expand-all");
    var collapseBtn = document.getElementById("collapse-all");

    if (expandBtn) {
      expandBtn.addEventListener("click", function () {
        document.querySelectorAll(".test-section details").forEach(function (d) {
          d.open = true;
        });
      });
    }

    if (collapseBtn) {
      collapseBtn.addEventListener("click", function () {
        document.querySelectorAll(".test-section details").forEach(function (d) {
          d.open = false;
        });
      });
    }
  }

  // ── Smooth Anchor Scrolling ───────────────
  function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(function (a) {
      a.addEventListener("click", function (e) {
        var target = document.querySelector(a.getAttribute("href"));
        if (target) {
          e.preventDefault();
          target.scrollIntoView({ behavior: "smooth", block: "start" });
        }
      });
    });
  }

  // ── Init ──────────────────────────────────
  function init() {
    initLightbox();
    initTimestamps();
    initExpandCollapse();
    initSmoothScroll();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
