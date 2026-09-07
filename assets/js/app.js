// ── Minimal Drag-and-Drop Hook (no external deps) ──

let Hooks = {};

Hooks.SortableCards = {
  mounted() {
    this.el.addEventListener("dragstart", (e) => {
      const card = e.target.closest("[data-card-id]");
      if (!card) return;
      e.dataTransfer.setData("text/plain", JSON.stringify({
        cardId: card.dataset.cardId,
        fromColumnId: card.dataset.columnId,
      }));
      e.dataTransfer.effectAllowed = "move";
      card.classList.add("sortable-drag");
      setTimeout(() => card.classList.add("sortable-ghost"), 0);
    });

    this.el.addEventListener("dragend", (e) => {
      const card = e.target.closest("[data-card-id]");
      if (card) {
        card.classList.remove("sortable-drag", "sortable-ghost");
      }
    });

    this.el.addEventListener("dragover", (e) => {
      e.preventDefault();
      e.dataTransfer.dropEffect = "move";
    });

    this.el.addEventListener("drop", (e) => {
      e.preventDefault();
      const cardEl = this.el.querySelector(".sortable-drag");
      if (!cardEl) return;

      const dropTarget = e.target.closest("[data-card-id]");
      const columnEl = e.target.closest("[data-column-id]");
      if (!columnEl) return;

      const toColumnId = columnEl.dataset.columnId;
      const cardId = cardEl.dataset.cardId;

      // Compute new position
      const cards = Array.from(columnEl.querySelectorAll("[data-card-id]"));
      let newPosition = cards.length;
      if (dropTarget) {
        newPosition = cards.indexOf(dropTarget);
      }

      // Send event to LiveView
      this.pushEvent("move_card", {
        card_id: cardId,
        column_id: toColumnId,
        position: newPosition,
      });
    });
  },
};

Hooks.SortableBoard = {
  mounted() {
    // Board-level hook placeholder
  },
};

// ── Move buttons (click fallback for accessibility) ──
// Cards have data attributes that the LiveView uses for server-side moves
// The "phx-click" on move-left/move-right buttons triggers the move_card event

// ── LiveSocket ──

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  ?.getAttribute("content") || "";

let liveSocket = new window.LiveSocket("/live", window.Phoenix.Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

liveSocket.connect();
