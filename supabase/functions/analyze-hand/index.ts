import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Anthropic from "npm:@anthropic-ai/sdk@0.24.3";
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ── Types ────────────────────────────────────────────────────────────────────

interface HandAction {
  seat: number;
  type: string;
  amount?: number;
  allIn?: boolean;
  openingBet?: boolean;
}

interface StreetData {
  street: string;
  communityCards: string[];
  actions: HandAction[];
}

interface HandPlayer {
  seat: number;
  name: string;
  stack: number;
  isHero: boolean;
  holeCards?: string[];
}

interface TableSetup {
  numSeats: number;
  buttonSeat: number;
  heroSeat: number;
  smallBlind: number;
  bigBlind: number;
  straddle?: number;
}

interface PokerHand {
  id: string;
  tableSetup: TableSetup;
  players: HandPlayer[];
  streets: StreetData[];
  notes?: string;
}

interface PlayerRead {
  playerLabel: string;
  tags: string[];
  notes?: string;
}

// ── Tool definition ───────────────────────────────────────────────────────────

const streetFeedbackSchema = {
  anyOf: [
    { type: "null" },
    {
      type: "object",
      properties: {
        decision: { type: "string", description: "What hero actually did on this street" },
        optimal: { type: "string", description: "The optimal or better play against this opponent" },
        rationale: { type: "string", description: "Why that play is better, referencing opponent reads if available" },
        wasGto: { type: "boolean", description: "True if hero's play was GTO-aligned" },
      },
      required: ["decision", "optimal", "rationale", "wasGto"],
    },
  ],
};

// deno-lint-ignore no-explicit-any
const COACHING_TOOL: any = {
  name: "provide_hand_coaching",
  description: "Return detailed street-by-street coaching for a single recorded poker hand",
  input_schema: {
    type: "object",
    properties: {
      summary: {
        type: "string",
        description: "Brief hand label e.g. 'AKo 3-bet pot, BTN vs CO open' or 'Flopped top pair vs aggressor'",
      },
      verdict: {
        type: "string",
        enum: ["highEV", "neutral", "leakDetected"],
        description: "Overall assessment of hero's play across all streets",
      },
      keyMistake: {
        anyOf: [{ type: "null" }, { type: "string" }],
        description: "The single biggest error hero made, written in 1-2 sentences. Set to null if the hand was played well.",
      },
      preflop: streetFeedbackSchema,
      flop: streetFeedbackSchema,
      turn: streetFeedbackSchema,
      river: streetFeedbackSchema,
    },
    required: ["summary", "verdict", "keyMistake", "preflop", "flop", "turn", "river"],
  },
};

// ── Helpers ───────────────────────────────────────────────────────────────────

function positionName(seat: number, setup: TableSetup): string {
  const off = (seat - setup.buttonSeat + setup.numSeats) % setup.numSeats;
  if (setup.straddle != null && off === 3) return "STR";
  if (setup.numSeats <= 6) {
    const n = ["BTN", "SB", "BB", "UTG", "HJ", "CO"];
    return off < n.length ? n[off] : `P${seat + 1}`;
  }
  const n = ["BTN", "SB", "BB", "UTG", "UTG+1", "UTG+2", "MP", "HJ", "CO"];
  return off < n.length ? n[off] : `P${seat + 1}`;
}

function formatAction(a: HandAction, playerName: string, pos: string): string {
  const who = `${playerName}(${pos})`;
  switch (a.type) {
    case "fold": return `${who} folds`;
    case "check": return `${who} checks`;
    case "call": return `${who} calls ${a.amount ?? 0}`;
    case "raise": return a.openingBet
      ? `${who} bets ${a.amount ?? 0}`
      : `${who} raises to ${a.amount ?? 0}${a.allIn ? " (all-in)" : ""}`;
    case "allIn": return `${who} all-in for ${a.amount ?? 0}`;
    case "post": return `${who} posts ${a.amount ?? 0}`;
    case "postStraddle": return `${who} straddles ${a.amount ?? 0}`;
    default: return `${who} ${a.type}`;
  }
}

function buildPrompt(hand: PokerHand, reads: PlayerRead[]): string {
  const { tableSetup: ts, players, streets } = hand;
  const seatMap = new Map(players.map((p) => [p.seat, p]));
  const readMap = new Map(reads.map((r) => [r.playerLabel.toLowerCase(), r]));

  const hero = players.find((p) => p.isHero);
  const heroPos = hero ? positionName(hero.seat, ts) : "?";
  const heroCards = hero?.holeCards?.join(" ") ?? "??";
  const board = streets.flatMap((s) => s.communityCards);

  const lines: string[] = [
    "HAND TO ANALYZE:",
    `Hero: [${heroCards}] in ${heroPos} | ${ts.numSeats}-handed | $${ts.smallBlind}/$${ts.bigBlind}${ts.straddle ? `/$${ts.straddle}` : ""} blinds | Starting stack $${hero?.stack ?? "?"}`,
  ];

  // Opponents — show reads where available
  const opponents = players.filter((p) => !p.isHero);
  if (opponents.length > 0) {
    lines.push("Opponents:");
    for (const p of opponents) {
      const pos = positionName(p.seat, ts);
      const r = readMap.get(p.name.toLowerCase());
      if (r) {
        const tagStr = r.tags.length ? ` [${r.tags.join(", ")}]` : "";
        const noteStr = r.notes ? ` — "${r.notes}"` : "";
        lines.push(`  ${p.name}(${pos}) — $${p.stack} stack${tagStr}${noteStr}`);
      } else {
        lines.push(`  ${p.name}(${pos}) — $${p.stack} stack — no read, use GTO defaults`);
      }
    }
  }

  if (board.length) lines.push(`Final board: ${board.join(" ")}`);

  // Street-by-street action log
  for (const street of streets) {
    const label = street.street.toUpperCase();
    const cc = street.communityCards.length
      ? ` [${street.communityCards.join(" ")}]`
      : "";
    const actionStr = street.actions
      .map((a) => {
        const p = seatMap.get(a.seat);
        if (!p) return "";
        return formatAction(a, p.isHero ? "Hero" : p.name, positionName(a.seat, ts));
      })
      .filter(Boolean)
      .join("; ");
    lines.push(`${label}${cc}: ${actionStr}`);
  }

  if (hand.notes) lines.push(`Hand note: "${hand.notes}"`);

  lines.push(
    "",
    "Analyze each street hero reached. When a read or tag exists for an opponent, base optimal play on that player profile (exploit accordingly). When no read exists, use GTO population defaults and state this. Use null for streets not reached.",
  );

  return lines.join("\n");
}

// ── System prompt (cached) ────────────────────────────────────────────────────

const SYSTEM_PROMPT =
  `You are an expert poker coach with deep knowledge of No-Limit Hold'em strategy at all stakes. Your coaching philosophy blends GTO foundations with practical exploitation of opponent tendencies.

EXPERTISE AREAS:
1. Preflop ranges: opening, 3-betting, 4-betting, defending from all positions in 6-max and full-ring. Know solver-approved frequencies and adjust for live players who deviate from GTO.
2. Postflop: c-bet frequencies by board texture (dry/wet/paired/monotone), probe bets, check-raises, pot control, thin value, bluff selection. Think in ranges.
3. Opponent exploitation: when reads or tags exist, shift from GTO toward exploitative plays — size up vs calling stations, bluff less vs stations, 3-bet wider vs nits, etc.
4. Bet sizing: pot geometry, SPR, protection, polarisation vs merged ranges, sizing tells.

COACHING PRINCIPLES:
- Be specific. Reference actual cards, board texture, stack depth, position, and opponent tags in every coaching point.
- When a read exists: always name the player and tag ("Justin is tagged Calling Station — bluffing river is -EV, valuebet thin instead").
- When no read exists: state you are using GTO population defaults.
- keyMistake must be the single highest-impact error in the hand, written in 1-2 sentences. If the hand was played well, set keyMistake to null.

ACCURACY RULES:
1. CARD ACCURACY: Reproduce hole cards and board cards exactly as given. Never alter rank or suit.
2. BET-COUNTING: BB post is not a raise. Open-raise = 2-bet, re-raise = 3-bet, re-raise over 3-bet = 4-bet, jam or raise over 4-bet = 5-bet. Never miscategorise.
3. TEXT FORMATTING: Plain prose only. No escape characters (\\n, \\t), no markdown, no bullet symbols inside string fields.
4. HAND READING — silently work through these steps before writing any output field. Never include this reasoning in your output — only state the conclusions:

   STEP 1 — LIST CARDS: State hero's two hole cards and the current board cards with their exact ranks and suits as given. Never alter or infer any rank or suit.

   STEP 2 — STRAIGHT DRAW CHECK: Collect all ranks present (hole cards + board). Find every 5-consecutive-rank window that contains 4 or more of those ranks:
   • All 5 present → STRAIGHT (made hand).
   • Exactly 4 present AND those 4 are fully consecutive (no internal gap) → OPEN-ENDED STRAIGHT DRAW (OESD, 8 outs): two different ranks (one at each end) complete it.
   • Exactly 4 present AND there is exactly one rank missing inside the sequence → GUTSHOT (4 outs): only one specific rank completes it. A gutshot is NOT an OESD — do not confuse them.
   Worked example: hero 7h8h on board 4c5dTh — ranks present: 4,5,7,8,T. Window 4-5-6-7-8: four ranks present (4,5,7,8), gap at 6 which is internal → GUTSHOT needing a 6 (4 outs). Window 6-7-8-9-T: only three ranks present → not a draw. Correct answer: GUTSHOT, not OESD.
   Counterexample: hero 7h8h on board 5c6dTh — ranks present: 5,6,7,8,T. Window 5-6-7-8-9: four ranks present (5,6,7,8), all consecutive with no gap → OESD needing a 4 or 9 (8 outs).

   STEP 3 — FLUSH DRAW CHECK: For each suit, count cards of that suit across hero's two hole cards plus current board cards:
   • 5 of same suit → FLUSH (made).
   • 4 of same suit → FLUSH DRAW (9 outs).
   • 3 of same suit → BACKDOOR FLUSH DRAW only, not an immediate draw.
   • 2 or fewer → no flush relevance.
   Worked example: hero 7h8h on board 4c5dTh — hearts: 7h + 8h + Th = 3 hearts → BACKDOOR flush draw only, NOT a flush draw.

   STEP 4 — MADE HAND: Identify the best made hand using hole cards + board: high card, one pair (top/middle/bottom pair by board rank), two pair, set (pocket pair matching board card), trips (one hole card + two board cards of same rank), straight, flush, full house, quads, straight flush.

   STEP 5 — NEVER invent draws or made hands not supported by the cards listed in steps 1–4.`;

// ── Entry point ───────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { ...cors, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: { user }, error: authErr } = await supabase.auth.getUser();
    if (authErr || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...cors, "Content-Type": "application/json" },
      });
    }

    const body = await req.json() as {
      hand: PokerHand;
      reads?: PlayerRead[];
      forceRefresh?: boolean;
    };

    const { hand, reads = [], forceRefresh = false } = body;

    // Only pass reads for opponents actually in this hand
    const opponentNames = new Set(
      hand.players.filter((p) => !p.isHero).map((p) => p.name.toLowerCase()),
    );
    const relevantReads = reads.filter((r) =>
      opponentNames.has(r.playerLabel.toLowerCase())
    );

    // ── Cache check ──────────────────────────────────────────────────────────
    if (!forceRefresh) {
      const { data: cached } = await supabase
        .from("ai_hand_analyses")
        .select("analysis_json")
        .eq("hand_id", hand.id)
        .maybeSingle();

      if (cached) {
        return new Response(JSON.stringify(cached.analysis_json), {
          headers: { ...cors, "Content-Type": "application/json" },
        });
      }
    }

    // ── Call Claude ──────────────────────────────────────────────────────────
    const anthropic = new Anthropic({
      apiKey: Deno.env.get("ANTHROPIC_API_KEY")!,
    });

    const message = await anthropic.messages.create({
      model: "claude-sonnet-4-6",
      max_tokens: 2000,
      system: [
        {
          type: "text",
          text: SYSTEM_PROMPT,
          // @ts-ignore — cache_control valid but not in SDK types
          cache_control: { type: "ephemeral" },
        },
      ],
      tools: [COACHING_TOOL],
      // @ts-ignore — tool_choice valid but may not be in SDK v0.24.3 types
      tool_choice: { type: "tool", name: "provide_hand_coaching" },
      messages: [{ role: "user", content: buildPrompt(hand, relevantReads) }],
    });

    const toolBlock = message.content.find((c) => c.type === "tool_use");
    if (!toolBlock || toolBlock.type !== "tool_use") {
      throw new Error("Model did not return coaching tool call");
    }
    // deno-lint-ignore no-explicit-any
    const analysis = (toolBlock as any).input as Record<string, unknown>;

    // ── Cache result ─────────────────────────────────────────────────────────
    await supabase.from("ai_hand_analyses").upsert(
      {
        user_id: user.id,
        hand_id: hand.id,
        analysis_json: analysis,
        model_used: "claude-sonnet-4-6",
        tokens_used: message.usage.input_tokens + message.usage.output_tokens,
      },
      { onConflict: "user_id,hand_id" },
    );

    return new Response(JSON.stringify(analysis), {
      headers: { ...cors, "Content-Type": "application/json" },
    });
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error("analyze-hand error:", msg);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }
});
