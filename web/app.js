(() => {
  const STORAGE_KEY = "scrabble-score-v1";

  /** @typedef {{ id: string, name: string }} SavedPlayer */
  /** @typedef {{ id: string, name: string, score: number }} GamePlayer */
  /** @typedef {{ id: string, players: GamePlayer[], turns: { playerId: string, points: number, at: number }[], startedAt: number, endedAt: number | null, active: boolean }} Game */
  /** @typedef {{ savedPlayers: SavedPlayer[], games: Game[], activeGameId: string | null }} Store */

  const el = {
    splash: document.getElementById("splash"),
    app: document.getElementById("app"),
    screen: document.getElementById("screen"),
    screenTitle: document.getElementById("screenTitle"),
    backBtn: document.getElementById("backBtn"),
  };

  /** @type {{ name: string, params?: Record<string, string> }} */
  let route = { name: "home" };
  /** @type {Store} */
  let store = loadStore();
  /** @type {{ count: number, names: string[], saveFlags: boolean[] }} */
  let draft = defaultDraft();

  function uid() {
    return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
  }

  function defaultDraft() {
    return { count: 2, names: ["", ""], saveFlags: [true, true] };
  }

  /** @returns {Store} */
  function loadStore() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return { savedPlayers: [], games: [], activeGameId: null };
      const parsed = JSON.parse(raw);
      return {
        savedPlayers: Array.isArray(parsed.savedPlayers) ? parsed.savedPlayers : [],
        games: Array.isArray(parsed.games) ? parsed.games : [],
        activeGameId: parsed.activeGameId ?? null,
      };
    } catch {
      return { savedPlayers: [], games: [], activeGameId: null };
    }
  }

  function persist() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
  }

  function toast(message) {
    let node = document.querySelector(".toast");
    if (!node) {
      node = document.createElement("div");
      node.className = "toast";
      document.body.appendChild(node);
    }
    node.textContent = message;
    node.classList.add("is-on");
    clearTimeout(toast._t);
    toast._t = setTimeout(() => node.classList.remove("is-on"), 1800);
  }

  function formatDate(ms) {
    try {
      return new Intl.DateTimeFormat(undefined, {
        month: "short",
        day: "numeric",
        hour: "numeric",
        minute: "2-digit",
      }).format(new Date(ms));
    } catch {
      return new Date(ms).toLocaleString();
    }
  }

  function escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;");
  }

  function navigate(name, params = {}) {
    route = { name, params };
    render();
  }

  function activeGame() {
    return store.games.find((g) => g.id === store.activeGameId && g.active) || null;
  }

  function pastGames() {
    return store.games
      .filter((g) => !g.active)
      .sort((a, b) => (b.endedAt || b.startedAt) - (a.endedAt || a.startedAt));
  }

  function upsertSavedPlayer(name) {
    const trimmed = name.trim();
    if (!trimmed) return;
    const existing = store.savedPlayers.find(
      (p) => p.name.toLowerCase() === trimmed.toLowerCase()
    );
    if (existing) {
      existing.name = trimmed;
    } else {
      store.savedPlayers.push({ id: uid(), name: trimmed });
    }
  }

  function startGameFromDraft() {
    const names = draft.names.slice(0, draft.count).map((n) => n.trim());
    if (names.some((n) => !n)) {
      toast("Enter a name for each player");
      return;
    }
    names.forEach((name, i) => {
      if (draft.saveFlags[i]) upsertSavedPlayer(name);
    });
    const game = {
      id: uid(),
      players: names.map((name) => ({ id: uid(), name, score: 0 })),
      turns: [],
      startedAt: Date.now(),
      endedAt: null,
      active: true,
    };
    store.games.forEach((g) => {
      if (g.active) {
        g.active = false;
        g.endedAt = g.endedAt || Date.now();
      }
    });
    store.games.unshift(game);
    store.activeGameId = game.id;
    persist();
    draft = defaultDraft();
    navigate("game");
  }

  function resumeGame(id) {
    const game = store.games.find((g) => g.id === id);
    if (!game) return;
    store.games.forEach((g) => {
      if (g.active && g.id !== id) {
        g.active = false;
        g.endedAt = g.endedAt || Date.now();
      }
    });
    game.active = true;
    game.endedAt = null;
    store.activeGameId = game.id;
    persist();
    navigate("game");
  }

  function addTurn(playerId, points) {
    const game = activeGame();
    if (!game) return;
    const player = game.players.find((p) => p.id === playerId);
    if (!player) return;
    const value = Number(points);
    if (!Number.isFinite(value) || value < 0 || value > 999) {
      toast("Enter a valid turn total");
      return;
    }
    const pts = Math.round(value);
    player.score += pts;
    game.turns.push({ playerId, points: pts, at: Date.now() });
    persist();
    navigate("game");
    toast(`+${pts} for ${player.name}`);
  }

  function undoLastTurn() {
    const game = activeGame();
    if (!game || !game.turns.length) {
      toast("Nothing to undo");
      return;
    }
    const last = game.turns.pop();
    const player = game.players.find((p) => p.id === last.playerId);
    if (player) player.score = Math.max(0, player.score - last.points);
    persist();
    render();
    toast("Turn undone");
  }

  function endGame() {
    const game = activeGame();
    if (!game) return;
    game.active = false;
    game.endedAt = Date.now();
    store.activeGameId = null;
    persist();
    navigate("home");
    toast("Game saved to history");
  }

  function renderHome() {
    const current = activeGame();
    const history = pastGames();
    el.screenTitle.textContent = "Home";
    el.backBtn.hidden = true;

    const historyHtml = history.length
      ? history
          .map((g) => {
            const summary = g.players
              .map((p) => `${escapeHtml(p.name)} ${p.score}`)
              .join(" · ");
            return `
              <button class="game-row" type="button" data-action="open-game" data-id="${g.id}">
                <strong>${escapeHtml(summary)}</strong>
                <div class="meta">${formatDate(g.endedAt || g.startedAt)} · ${g.players.length} players</div>
              </button>`;
          })
          .join("")
      : `<p class="empty">No past games yet. Start one and it will show up here.</p>`;

    el.screen.innerHTML = `
      <section class="panel stack">
        <p class="hero-copy">Track turn totals for your table — saved only on this phone.</p>
        ${
          current
            ? `<button class="btn btn-primary" type="button" data-action="resume">Continue current game</button>`
            : ""
        }
        <button class="btn btn-primary" type="button" data-action="new-game">New Game</button>
      </section>
      <section class="panel stack">
        <p class="screen-title" style="margin:0">Past games</p>
        ${historyHtml}
      </section>`;
  }

  function renderNewGame() {
    el.screenTitle.textContent = "New Game";
    el.backBtn.hidden = false;

    const countChips = [1, 2, 3, 4]
      .map(
        (n) =>
          `<button class="chip ${draft.count === n ? "is-on" : ""}" type="button" data-action="set-count" data-count="${n}">${n}</button>`
      )
      .join("");

    const saved = store.savedPlayers
      .slice()
      .sort((a, b) => a.name.localeCompare(b.name));

    const savedChips = saved.length
      ? saved
          .map(
            (p) =>
              `<button class="chip" type="button" data-action="use-saved" data-name="${escapeHtml(p.name)}">${escapeHtml(p.name)}</button>`
          )
          .join("")
      : `<p class="meta" style="margin:0">No saved players yet.</p>`;

    const slots = Array.from({ length: draft.count }, (_, i) => {
      const name = draft.names[i] || "";
      const save = draft.saveFlags[i] !== false;
      return `
        <div class="player-setup">
          <div class="field">
            <label for="player-${i}">Player ${i + 1}</label>
            <input id="player-${i}" type="text" maxlength="24" autocomplete="off" value="${escapeHtml(name)}" data-action="name-input" data-index="${i}" placeholder="Name" />
          </div>
          <label class="check">
            <input type="checkbox" data-action="save-flag" data-index="${i}" ${save ? "checked" : ""} />
            Save this name for next time
          </label>
        </div>`;
    }).join("");

    el.screen.innerHTML = `
      <section class="panel stack">
        <p class="hero-copy">Choose 1–4 players. Tap a saved name to fill an empty slot.</p>
        <div class="field">
          <label>Players</label>
          <div class="chip-row">${countChips}</div>
        </div>
        <div class="field">
          <label>Recurring players</label>
          <div class="chip-row">${savedChips}</div>
        </div>
        ${slots}
        <button class="btn btn-primary" type="button" data-action="start-game">Start game</button>
      </section>`;
  }

  function renderGame() {
    const game = activeGame();
    if (!game) {
      navigate("home");
      return;
    }
    el.screenTitle.textContent = "Active game";
    el.backBtn.hidden = false;

    const rows = game.players
      .slice()
      .sort((a, b) => b.score - a.score)
      .map(
        (p) => `
        <button class="player-row" type="button" data-action="score-player" data-id="${p.id}">
          <span>
            <strong>${escapeHtml(p.name)}</strong>
            <div class="meta">Tap to add turn total</div>
          </span>
          <span class="score">${p.score}</span>
        </button>`
      )
      .join("");

    el.screen.innerHTML = `
      <section class="panel stack">
        ${rows}
        <div class="btn-row">
          <button class="btn btn-secondary" type="button" data-action="undo" ${game.turns.length ? "" : "disabled"}>Undo last turn</button>
          <button class="btn btn-danger" type="button" data-action="end-game">End &amp; save</button>
        </div>
      </section>`;
  }

  function renderScoreEntry() {
    const game = activeGame();
    const player = game?.players.find((p) => p.id === route.params.playerId);
    if (!game || !player) {
      navigate("game");
      return;
    }
    el.screenTitle.textContent = player.name;
    el.backBtn.hidden = false;

    el.screen.innerHTML = `
      <section class="panel score-entry">
        <p class="hero-copy">Enter this turn’s total for <strong>${escapeHtml(player.name)}</strong>.</p>
        <div class="field">
          <label for="points">Turn total</label>
          <input id="points" class="big-input" type="number" inputmode="numeric" min="0" max="999" step="1" placeholder="0" autofocus />
        </div>
        <button class="btn btn-primary" type="button" data-action="submit-score">Add to score</button>
      </section>`;

    const input = document.getElementById("points");
    input?.focus();
    input?.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        addTurn(player.id, input.value);
      }
    });
  }

  function renderHistoryDetail() {
    const game = store.games.find((g) => g.id === route.params.id);
    if (!game) {
      navigate("home");
      return;
    }
    el.screenTitle.textContent = "Past game";
    el.backBtn.hidden = false;
    const rows = game.players
      .slice()
      .sort((a, b) => b.score - a.score)
      .map(
        (p) => `
        <div class="player-row" style="cursor:default">
          <strong>${escapeHtml(p.name)}</strong>
          <span class="score">${p.score}</span>
        </div>`
      )
      .join("");

    el.screen.innerHTML = `
      <section class="panel stack">
        <p class="meta" style="margin:0">${formatDate(game.endedAt || game.startedAt)}</p>
        ${rows}
        <button class="btn btn-secondary" type="button" data-action="resume-past" data-id="${game.id}">Resume as current</button>
      </section>`;
  }

  function render() {
    if (route.name === "home") renderHome();
    else if (route.name === "new") renderNewGame();
    else if (route.name === "game") renderGame();
    else if (route.name === "score") renderScoreEntry();
    else if (route.name === "history") renderHistoryDetail();
    else renderHome();
  }

  function onBack() {
    if (route.name === "score") navigate("game");
    else if (route.name === "game" || route.name === "new" || route.name === "history")
      navigate("home");
  }

  el.backBtn.addEventListener("click", onBack);

  el.screen.addEventListener("click", (event) => {
    const target = event.target.closest("[data-action]");
    if (!target) return;
    const action = target.getAttribute("data-action");

    if (action === "new-game") {
      draft = defaultDraft();
      navigate("new");
    } else if (action === "resume") {
      navigate("game");
    } else if (action === "set-count") {
      const count = Number(target.getAttribute("data-count"));
      draft.count = count;
      while (draft.names.length < count) draft.names.push("");
      while (draft.saveFlags.length < count) draft.saveFlags.push(true);
      draft.names = draft.names.slice(0, count);
      draft.saveFlags = draft.saveFlags.slice(0, count);
      render();
    } else if (action === "use-saved") {
      const name = target.getAttribute("data-name") || "";
      const emptyIndex = draft.names.findIndex((n, i) => i < draft.count && !n.trim());
      const index = emptyIndex >= 0 ? emptyIndex : 0;
      draft.names[index] = name;
      draft.saveFlags[index] = true;
      render();
    } else if (action === "start-game") {
      startGameFromDraft();
    } else if (action === "score-player") {
      navigate("score", { playerId: target.getAttribute("data-id") });
    } else if (action === "submit-score") {
      const input = document.getElementById("points");
      addTurn(route.params.playerId, input?.value);
    } else if (action === "undo") {
      undoLastTurn();
    } else if (action === "end-game") {
      if (confirm("End this game and save it to history?")) endGame();
    } else if (action === "open-game") {
      navigate("history", { id: target.getAttribute("data-id") });
    } else if (action === "resume-past") {
      resumeGame(target.getAttribute("data-id"));
    }
  });

  el.screen.addEventListener("input", (event) => {
    const target = event.target;
    if (!(target instanceof HTMLElement)) return;
    const action = target.getAttribute("data-action");
    if (action === "name-input") {
      const index = Number(target.getAttribute("data-index"));
      draft.names[index] = /** @type {HTMLInputElement} */ (target).value;
    } else if (action === "save-flag") {
      const index = Number(target.getAttribute("data-index"));
      draft.saveFlags[index] = /** @type {HTMLInputElement} */ (target).checked;
    }
  });

  function registerServiceWorker() {
    if (!("serviceWorker" in navigator)) return;
    navigator.serviceWorker.register("./sw.js").catch(() => {});
  }

  function boot() {
    if (activeGame()) route = { name: "game" };
    else route = { name: "home" };
    el.app.hidden = false;
    render();
    registerServiceWorker();
    window.setTimeout(() => {
      el.splash.classList.add("is-done");
      el.splash.setAttribute("aria-hidden", "true");
    }, 700);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
