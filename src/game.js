const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");

const FORMATS = [
  { id: "T20", label: "T20", overs: 20, powerplay: 6, deathStart: 16 },
  { id: "ODI", label: "ODI", overs: 50, powerplay: 10, deathStart: 41 },
  { id: "TEST", label: "Test", overs: 90, powerplay: 18, deathStart: 80 },
];

const PLAYER_POOL = [
  "A. Sharma", "V. Rao", "R. Khan", "S. Iyer", "K. Nair", "M. Ali", "D. Patel", "Y. Singh",
  "N. Das", "T. Joseph", "H. Verma", "P. Gill", "C. Menon", "Z. Ahmed", "I. Malik", "B. Roy",
];

const ROLE_POOL = ["Opener", "Anchor", "Finisher", "All-Rounder", "Pacer", "Spinner"];

const state = {
  mode: "start",
  formatIndex: 0,
  match: null,
  scouting: [],
  economy: {
    cashCrore: 100,
    fans: 64000,
    sponsorLevel: 1,
    infraLevel: 1,
  },
};

function rand(min, max) {
  return min + Math.random() * (max - min);
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function pick(list) {
  return list[Math.floor(Math.random() * list.length)];
}

function createPlayer(name) {
  return {
    name,
    role: pick(ROLE_POOL),
    hitting: Math.round(rand(45, 92)),
    anchoring: Math.round(rand(42, 90)),
    pressure: Math.round(rand(45, 95)),
    form: Math.round(rand(45, 96)),
    fitness: Math.round(rand(55, 99)),
    wicketRisk: rand(0.75, 1.35),
  };
}

function createSquad() {
  const shuffled = [...PLAYER_POOL].sort(() => Math.random() - 0.5).slice(0, 11);
  return shuffled.map(createPlayer);
}

function createScoutingBoard() {
  return Array.from({ length: 6 }, () => ({
    name: pick(PLAYER_POOL),
    role: pick(ROLE_POOL),
    basePrice: Math.round(rand(0.3, 2.2) * 10) / 10,
    potential: Math.round(rand(62, 96)),
  }));
}

function createMatch() {
  const format = FORMATS[state.formatIndex];
  const squad = createSquad();
  return {
    format,
    squad,
    runs: 0,
    wickets: 0,
    balls: 0,
    maxBalls: format.overs * 6,
    striker: 0,
    nonStriker: 1,
    nextBatter: 2,
    aggression: 0.5,
    auto: false,
    autoAccumulator: 0,
    autoBallEverySec: 0.32,
    inningDone: false,
    lastEvent: "Press Space to simulate first ball.",
    commentary: [],
    overRuns: 0,
    bowlers: [
      { name: "Left-arm Pacer", control: 78, wicketSkill: 81, deathSkill: 83 },
      { name: "Leg Spinner", control: 74, wicketSkill: 76, deathSkill: 68 },
      { name: "Swing Bowler", control: 80, wicketSkill: 74, deathSkill: 79 },
      { name: "Off Spinner", control: 72, wicketSkill: 72, deathSkill: 65 },
      { name: "Seam Bowler", control: 76, wicketSkill: 77, deathSkill: 75 },
    ],
  };
}

function resetGameState() {
  state.match = createMatch();
  state.scouting = createScoutingBoard();
}

function currentOver() {
  const m = state.match;
  return Math.floor(m.balls / 6);
}

function overAsText() {
  const m = state.match;
  return `${Math.floor(m.balls / 6)}.${m.balls % 6}`;
}

function getPhase(match) {
  const over = currentOver() + 1;
  if (over <= match.format.powerplay) return "powerplay";
  if (over >= match.format.deathStart) return "death";
  return "middle";
}

function activeBowler(match) {
  const over = currentOver();
  return match.bowlers[over % match.bowlers.length];
}

function computeBallProbabilities(match, batter, bowler) {
  const phase = getPhase(match);
  const skill = batter.hitting * 0.48 + batter.anchoring * 0.22 + batter.form * 0.15 + batter.pressure * 0.15;
  const bowlSkill = bowler.control * 0.47 + bowler.wicketSkill * 0.35 + bowler.deathSkill * 0.18;
  const aggression = match.aggression;

  const phaseBoundaryBoost = phase === "powerplay" ? 0.03 : phase === "death" ? 0.08 : 0.0;
  const phaseWicketBoost = phase === "powerplay" ? 0.008 : phase === "death" ? 0.026 : 0.0;

  let wicketProb =
    0.018 +
    aggression * 0.052 +
    (bowlSkill - skill) / 1400 +
    phaseWicketBoost +
    (batter.wicketRisk - 1) * 0.03;
  wicketProb = clamp(wicketProb, 0.01, 0.33);

  let w0 = 0.28 - aggression * 0.14 + bowlSkill * 0.0014 - skill * 0.0007;
  let w1 = 0.33 - aggression * 0.05 + batter.anchoring * 0.0006;
  let w2 = 0.14 - aggression * 0.01;
  let w3 = 0.025;
  let w4 = 0.14 + aggression * 0.11 + phaseBoundaryBoost + batter.hitting * 0.0009 - bowlSkill * 0.0007;
  let w6 = 0.085 + aggression * 0.09 + phaseBoundaryBoost * 0.6 + batter.hitting * 0.0007 - bowlSkill * 0.0005;

  const outcomes = [w0, w1, w2, w3, w4, w6].map((v) => Math.max(0.01, v));
  const sum = outcomes.reduce((a, b) => a + b, 0);
  const normalized = outcomes.map((v) => v / sum);

  return {
    phase,
    wicketProb,
    runWeights: normalized,
  };
}

function chooseRuns(weights) {
  const outcomes = [0, 1, 2, 3, 4, 6];
  const r = Math.random();
  let acc = 0;
  for (let i = 0; i < weights.length; i += 1) {
    acc += weights[i];
    if (r <= acc) return outcomes[i];
  }
  return 1;
}

function monteCarloDecision(match, batter, bowler) {
  // Run a short Monte Carlo burst so each ball is influenced by sampled trajectories.
  const samples = 96;
  let wicketCount = 0;
  const runHistogram = new Map([[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [6, 0]]);

  for (let i = 0; i < samples; i += 1) {
    const { wicketProb, runWeights } = computeBallProbabilities(match, batter, bowler);
    if (Math.random() < wicketProb) {
      wicketCount += 1;
      continue;
    }
    const run = chooseRuns(runWeights);
    runHistogram.set(run, (runHistogram.get(run) || 0) + 1);
  }

  const wicketChance = wicketCount / samples;
  let likelyRun = 1;
  let best = -1;
  for (const [run, count] of runHistogram.entries()) {
    if (count > best) {
      best = count;
      likelyRun = run;
    }
  }

  return { wicketChance, likelyRun };
}

function pushCommentary(line) {
  const m = state.match;
  m.commentary.unshift(line);
  if (m.commentary.length > 8) m.commentary.pop();
}

function rotateStrikeIfNeeded() {
  const m = state.match;
  if (m.balls % 6 === 0) {
    const tmp = m.striker;
    m.striker = m.nonStriker;
    m.nonStriker = tmp;
    m.overRuns = 0;
  }
}

function updateEconomyAtEnd() {
  const m = state.match;
  const performanceBand = clamp(m.runs / (m.format.id === "T20" ? 170 : m.format.id === "ODI" ? 285 : 320), 0.5, 1.45);
  const crowdBoost = Math.round(3500 * performanceBand);
  state.economy.fans += crowdBoost;
  const ticketRevenue = performanceBand * 2.1;
  const sponsorRevenue = state.economy.sponsorLevel * 0.7 * performanceBand;
  const infraCost = state.economy.infraLevel * 0.45;
  const wages = 1.9;
  const net = ticketRevenue + sponsorRevenue - infraCost - wages;
  state.economy.cashCrore = Math.round((state.economy.cashCrore + net) * 100) / 100;
}

function finishInnings(reason) {
  const m = state.match;
  m.inningDone = true;
  m.auto = false;
  m.lastEvent = reason;
  pushCommentary(reason);
  updateEconomyAtEnd();
}

function simulateBall() {
  const m = state.match;
  if (!m || m.inningDone) return;

  const striker = m.squad[m.striker];
  const bowler = activeBowler(m);
  const decision = monteCarloDecision(m, striker, bowler);
  const phase = getPhase(m);

  const wicketHappened = Math.random() < decision.wicketChance;
  if (wicketHappened) {
    m.wickets += 1;
    m.balls += 1;
    m.overRuns += 0;
    const line = `${overAsText()} WICKET! ${striker.name} c&b ${bowler.name}.`;
    m.lastEvent = line;
    pushCommentary(line);
    if (m.wickets >= 10 || m.nextBatter > 10 || m.balls >= m.maxBalls) {
      finishInnings("Innings closed: all out.");
      return;
    }
    m.striker = m.nextBatter;
    m.nextBatter += 1;
    rotateStrikeIfNeeded();
  } else {
    const run = decision.likelyRun;
    m.runs += run;
    m.balls += 1;
    m.overRuns += run;
    const batText = run === 0 ? "dot ball" : `${run} run${run > 1 ? "s" : ""}`;
    const line = `${overAsText()} ${batText} (${phase}) by ${striker.name}.`;
    m.lastEvent = line;
    pushCommentary(line);
    if (run % 2 === 1) {
      const tmp = m.striker;
      m.striker = m.nonStriker;
      m.nonStriker = tmp;
    }
    rotateStrikeIfNeeded();
  }

  if (m.balls >= m.maxBalls) {
    finishInnings("Innings closed: overs completed.");
  }
}

function cycleFormat() {
  state.formatIndex = (state.formatIndex + 1) % FORMATS.length;
  resetGameState();
}

function toggleFullscreen() {
  if (!document.fullscreenElement) {
    canvas.requestFullscreen?.();
  } else {
    document.exitFullscreen?.();
  }
}

function drawRoundedRect(x, y, w, h, r, fill, stroke) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  if (fill) {
    ctx.fillStyle = fill;
    ctx.fill();
  }
  if (stroke) {
    ctx.strokeStyle = stroke;
    ctx.stroke();
  }
}

function drawStartScreen() {
  ctx.fillStyle = "#f8fcff";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  drawRoundedRect(120, 90, 720, 420, 18, "#ffffff", "#1f4f74");
  ctx.fillStyle = "#16364f";
  ctx.font = "bold 46px Trebuchet MS";
  ctx.fillText("Cricket Simulator MVP", 220, 170);
  ctx.font = "24px Trebuchet MS";
  ctx.fillText("Ball-by-ball strategy with economy loop", 250, 214);

  ctx.font = "20px Trebuchet MS";
  ctx.fillStyle = "#28597f";
  ctx.fillText("Enter: Start", 240, 300);
  ctx.fillText("M: Change format", 240, 336);
  ctx.fillText("ArrowUp/ArrowDown: Aggression", 240, 372);
  ctx.fillText("Space: Next ball  |  A: Autoplay  |  R: Reset", 240, 408);
  ctx.fillText("F: Fullscreen", 240, 444);
}

function drawPitchAndPlayers(match) {
  const pitch = { x: 130, y: 110, w: 460, h: 380 };
  drawRoundedRect(pitch.x, pitch.y, pitch.w, pitch.h, 22, "#8fcf8b", "#3a8048");
  drawRoundedRect(pitch.x + 190, pitch.y + 40, 80, 300, 12, "#d4b78a", "#906b3d");

  const strikerPos = { x: pitch.x + 220, y: pitch.y + 300, r: 14 };
  const nonStrikerPos = { x: pitch.x + 240, y: pitch.y + 100, r: 13 };
  const bowlerPos = { x: pitch.x + 230, y: pitch.y + 60, r: 12 };

  ctx.fillStyle = "#0f3050";
  ctx.beginPath();
  ctx.arc(strikerPos.x, strikerPos.y, strikerPos.r, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(nonStrikerPos.x, nonStrikerPos.y, nonStrikerPos.r, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = "#a0322b";
  ctx.beginPath();
  ctx.arc(bowlerPos.x, bowlerPos.y, bowlerPos.r, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = "#ffffff";
  ctx.font = "bold 13px Trebuchet MS";
  ctx.fillText("S", strikerPos.x - 4, strikerPos.y + 5);
  ctx.fillText("N", nonStrikerPos.x - 5, nonStrikerPos.y + 5);
  ctx.fillText("B", bowlerPos.x - 5, bowlerPos.y + 5);

  return { strikerPos, nonStrikerPos, bowlerPos, pitch };
}

function drawMatchScreen() {
  const m = state.match;
  const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
  gradient.addColorStop(0, "#d9efff");
  gradient.addColorStop(1, "#f4e8d4");
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  const entities = drawPitchAndPlayers(m);

  drawRoundedRect(620, 36, 314, 528, 14, "#ffffff", "#28597f");
  ctx.fillStyle = "#173a55";
  ctx.font = "bold 28px Trebuchet MS";
  ctx.fillText(`${m.format.label} Match`, 645, 74);
  ctx.font = "bold 34px Trebuchet MS";
  ctx.fillText(`${m.runs}/${m.wickets}`, 645, 120);
  ctx.font = "20px Trebuchet MS";
  ctx.fillText(`Overs: ${overAsText()} / ${m.format.overs}`, 645, 152);

  const striker = m.squad[m.striker];
  const nonStriker = m.squad[m.nonStriker];
  ctx.font = "18px Trebuchet MS";
  ctx.fillText(`Striker: ${striker.name}`, 645, 190);
  ctx.fillText(`Non-striker: ${nonStriker.name}`, 645, 216);
  ctx.fillText(`Phase: ${getPhase(m)}`, 645, 242);
  ctx.fillText(`Autoplay: ${m.auto ? "ON" : "OFF"}`, 645, 268);

  drawRoundedRect(645, 286, 260, 18, 9, "#dce7f2", "#97adc4");
  drawRoundedRect(645, 286, 260 * m.aggression, 18, 9, "#f29545", null);
  ctx.font = "15px Trebuchet MS";
  ctx.fillStyle = "#21384c";
  ctx.fillText(`Aggression ${Math.round(m.aggression * 100)}%`, 645, 323);

  ctx.fillStyle = "#173a55";
  ctx.font = "bold 19px Trebuchet MS";
  ctx.fillText("Economy", 645, 356);
  ctx.font = "16px Trebuchet MS";
  ctx.fillText(`Cash: ₹${state.economy.cashCrore.toFixed(2)} Cr`, 645, 381);
  ctx.fillText(`Fans: ${state.economy.fans.toLocaleString()}`, 645, 403);
  ctx.fillText(`Sponsor lvl: ${state.economy.sponsorLevel}`, 645, 425);
  ctx.fillText(`Infra lvl: ${state.economy.infraLevel}`, 645, 447);

  ctx.fillStyle = "#173a55";
  ctx.font = "bold 19px Trebuchet MS";
  ctx.fillText("Scouting Watchlist", 645, 482);
  ctx.font = "14px Trebuchet MS";
  for (let i = 0; i < Math.min(3, state.scouting.length); i += 1) {
    const p = state.scouting[i];
    ctx.fillText(`${p.name} (${p.role}) ₹${p.basePrice}Cr POT:${p.potential}`, 645, 504 + i * 20);
  }

  drawRoundedRect(36, 505, 556, 68, 12, "#ffffffd9", "#2d5d84");
  ctx.fillStyle = "#173a55";
  ctx.font = "16px Trebuchet MS";
  ctx.fillText(m.lastEvent, 52, 545, 530);

  ctx.font = "13px Trebuchet MS";
  ctx.fillStyle = "#1f4f74";
  ctx.fillText("Space ball | A autoplay | ↑/↓ aggression | M format | R reset | F fullscreen", 38, 588);

  if (m.inningDone) {
    drawRoundedRect(175, 230, 380, 120, 16, "#0f2f49de", "#f6f8fb");
    ctx.fillStyle = "#f6f8fb";
    ctx.font = "bold 28px Trebuchet MS";
    ctx.fillText("Innings Complete", 245, 280);
    ctx.font = "18px Trebuchet MS";
    ctx.fillText("Press R to restart this format", 247, 314);
  }

  return entities;
}

function render() {
  if (state.mode === "start") {
    drawStartScreen();
    return;
  }
  drawMatchScreen();
}

function update(dt) {
  if (state.mode !== "match") return;
  const m = state.match;
  if (!m || m.inningDone || !m.auto) return;
  m.autoAccumulator += dt;
  while (m.autoAccumulator >= m.autoBallEverySec && !m.inningDone) {
    simulateBall();
    m.autoAccumulator -= m.autoBallEverySec;
  }
}

function renderGameToText() {
  const payload = {
    coordinate_system: {
      origin: "top-left of canvas",
      x_axis: "increases to the right",
      y_axis: "increases downward",
      canvas: { width: canvas.width, height: canvas.height },
    },
    mode: state.mode,
    format: FORMATS[state.formatIndex].id,
    economy: state.economy,
  };

  if (state.mode === "match" && state.match) {
    const m = state.match;
    const pitch = { x: 130, y: 110, w: 460, h: 380 };
    payload.match = {
      score: `${m.runs}/${m.wickets}`,
      runs: m.runs,
      wickets: m.wickets,
      overs: overAsText(),
      balls_total: m.balls,
      balls_remaining: Math.max(0, m.maxBalls - m.balls),
      aggression: m.aggression,
      autoplay: m.auto,
      inning_done: m.inningDone,
      phase: getPhase(m),
      last_event: m.lastEvent,
      striker: m.squad[m.striker].name,
      non_striker: m.squad[m.nonStriker].name,
      commentary: m.commentary,
    };
    payload.entities = [
      { id: "striker", type: "batter", x: pitch.x + 220, y: pitch.y + 300, r: 14 },
      { id: "non_striker", type: "batter", x: pitch.x + 240, y: pitch.y + 100, r: 13 },
      { id: "bowler", type: "bowler", x: pitch.x + 230, y: pitch.y + 60, r: 12 },
    ];
    payload.scouting = state.scouting.slice(0, 3);
  }

  return JSON.stringify(payload);
}

window.render_game_to_text = renderGameToText;
window.advanceTime = (ms) => {
  const steps = Math.max(1, Math.round(ms / (1000 / 60)));
  for (let i = 0; i < steps; i += 1) update(1 / 60);
  render();
};

window.addEventListener("keydown", (event) => {
  if (event.key === "f" || event.key === "F") toggleFullscreen();
  if (event.key === "Escape" && document.fullscreenElement) document.exitFullscreen?.();

  if (state.mode === "start") {
    if (event.key === "Enter") {
      state.mode = "match";
      event.preventDefault();
      return;
    }
    if (event.key === "m" || event.key === "M") cycleFormat();
    return;
  }

  const m = state.match;
  if (!m) return;

  if (event.key === " ") {
    simulateBall();
    event.preventDefault();
  } else if (event.key === "a" || event.key === "A") {
    m.auto = !m.auto;
  } else if (event.key === "ArrowUp") {
    m.aggression = clamp(m.aggression + 0.05, 0.05, 0.95);
    event.preventDefault();
  } else if (event.key === "ArrowDown") {
    m.aggression = clamp(m.aggression - 0.05, 0.05, 0.95);
    event.preventDefault();
  } else if (event.key === "r" || event.key === "R") {
    resetGameState();
    state.mode = "match";
  } else if (event.key === "m" || event.key === "M") {
    cycleFormat();
    state.mode = "match";
  }
});

resetGameState();

let lastTs = performance.now();
function gameLoop(ts) {
  const dt = clamp((ts - lastTs) / 1000, 0, 0.1);
  lastTs = ts;
  update(dt);
  render();
  requestAnimationFrame(gameLoop);
}
requestAnimationFrame(gameLoop);
