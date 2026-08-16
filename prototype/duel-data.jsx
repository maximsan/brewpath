// duel-data.jsx — Coffee Duel content: duel types, 5-question banks,
// opponent personas, and demo duel records used by the live flow + gallery.

// ── Duel types ─────────────────────────────────────────────
// Five flavors of a short head-to-head. All share one play engine, so each is
// just a label + a 5-question bank. Icon keys map to DuelGlyph in duel.jsx.
const DUEL_TYPES = [
  { id: 'basics',     name: 'Coffee basics',      icon: 'cup',
    tag: 'WARM-UP',        blurb: 'The fundamentals — beans, species, where it grows.' },
  { id: 'origin',     name: 'Origin detective',   icon: 'globe',
    tag: 'GUESS THE CUP',  blurb: 'Read the tasting clues, name the country.' },
  { id: 'brew',       name: 'Brew order',         icon: 'route',
    tag: 'GET IT RIGHT',   blurb: 'Ratios, temps and the right step, in order.' },
  { id: 'taste',      name: 'Taste match',        icon: 'tiles',
    tag: 'FLAVOR',         blurb: 'Match the flavor to what put it in the cup.' },
  { id: 'processing', name: 'Processing',         icon: 'drop',
    tag: 'AFTER THE PICK', blurb: 'Washed, natural, honey — and why it matters.' },
];

// ── Question banks — 5 each, beginner-friendly ─────────────
const DUEL_QUESTIONS = {
  basics: [
    { q: 'What part of the coffee plant do we actually brew?',
      choices: [{ t: 'The seed', correct: true }, { t: 'The leaf' }, { t: 'The root' }, { t: 'The flower' }],
      explain: 'A coffee “bean” is the seed of the cherry — closer to a pit than a legume.' },
    { q: 'Which species is sweeter, more aromatic and more delicate?',
      choices: [{ t: 'Robusta' }, { t: 'Liberica' }, { t: 'Arabica', correct: true }, { t: 'Excelsa' }],
      explain: 'Arabica grows high and cool. It’s most specialty coffee — and more fragile.' },
    { q: 'Coffee grows in a band around the…',
      choices: [{ t: 'Coastline' }, { t: 'Poles' }, { t: 'Desert' }, { t: 'Equator', correct: true }],
      explain: 'The “bean belt” runs roughly 25°N to 25°S — high, mild and rainy.' },
    { q: 'Roughly what share of world coffee is Arabica?',
      choices: [{ t: '~10%' }, { t: '~60%', correct: true }, { t: '~90%' }, { t: '~30%' }],
      explain: 'About 60% Arabica, most of the rest Robusta.' },
    { q: 'Robusta has, versus Arabica, roughly…',
      choices: [{ t: 'Half the caffeine' }, { t: 'The same caffeine' }, { t: 'Twice the caffeine', correct: true }, { t: 'No caffeine' }],
      explain: 'Robusta is tougher and heavier, with about double the caffeine (~2.4%).' },
  ],
  origin: [
    { q: 'Bright, floral, tea-like, often washed. Famously from…',
      choices: [{ t: 'Brazil' }, { t: 'Vietnam' }, { t: 'Ethiopia', correct: true }, { t: 'Hawaii' }],
      explain: 'Ethiopia — coffee’s birthplace — is known for delicate, floral cups.' },
    { q: 'Balanced, nutty, chocolatey; the world’s largest producer?',
      choices: [{ t: 'Brazil', correct: true }, { t: 'Yemen' }, { t: 'Kenya' }, { t: 'Panama' }],
      explain: 'Brazil is the world’s largest producer by a wide margin — huge volumes of smooth, nutty, low-acid coffee.' },
    { q: 'Which country is the largest Robusta producer?',
      choices: [{ t: 'Colombia' }, { t: 'Kenya' }, { t: 'Guatemala' }, { t: 'Vietnam', correct: true }],
      explain: 'Vietnam is the Robusta giant — much of it goes to espresso and instant.' },
    { q: 'Juicy blackcurrant acidity, SL-28 variety, grown high. That’s…',
      choices: [{ t: 'Sumatra' }, { t: 'Kenya', correct: true }, { t: 'Mexico' }, { t: 'India' }],
      explain: 'Kenya is famous for bold, blackcurrant-bright washed coffees.' },
    { q: 'The “bean belt” countries all lie between…',
      choices: [{ t: '0° and 10°N' }, { t: '30°N and 60°N' }, { t: '25°N and 25°S', correct: true }, { t: '40°N and 40°S' }],
      explain: 'Almost all coffee grows in that equatorial band — the right climate.' },
  ],
  brew: [
    { q: 'For pour-over, what comes right after grinding?',
      choices: [{ t: 'Add all the water' }, { t: 'Rinse the filter' }, { t: 'Stir hard' }, { t: 'Bloom the grounds', correct: true }],
      explain: 'A short bloom lets fresh grounds release CO₂ so water can extract evenly.' },
    { q: 'A typical pour-over brew ratio (coffee : water) is about…',
      choices: [{ t: '1 : 2' }, { t: '1 : 16', correct: true }, { t: '1 : 50' }, { t: '1 : 4' }],
      explain: 'Roughly 1:16 is a reliable filter starting point — tune to taste.' },
    { q: 'Espresso is brewed at a ratio closer to…',
      choices: [{ t: '1 : 2', correct: true }, { t: '1 : 16' }, { t: '1 : 30' }, { t: '1 : 8' }],
      explain: 'Espresso is concentrated — about 1:2, in around 25–30 seconds.' },
    { q: 'Best water temperature for most pour-over?',
      choices: [{ t: '60 °C' }, { t: '75 °C' }, { t: '~93 °C', correct: true }, { t: '100 °C, rolling boil' }],
      explain: 'Around 90–96 °C. A rolling boil scorches; too cool under-extracts.' },
    { q: 'Which is the right pour-over order?',
      choices: [{ t: 'Pour → grind → bloom' }, { t: 'Grind → bloom → pour → drawdown', correct: true }, { t: 'Bloom → grind → pour' }, { t: 'Drawdown → pour → bloom' }],
      explain: 'Grind fresh, bloom, pour in stages, then let it draw down.' },
  ],
  taste: [
    { q: 'Heavy blueberry / fruity notes most often come from…',
      choices: [{ t: 'Washed process' }, { t: 'Dark roast' }, { t: 'Hard water' }, { t: 'Natural process', correct: true }],
      explain: 'Drying the bean inside the whole cherry (natural) amps up fruit.' },
    { q: 'A clean, bright, transparent cup usually signals…',
      choices: [{ t: 'Washed processing', correct: true }, { t: 'Stale beans' }, { t: 'Robusta' }, { t: 'Over-roasting' }],
      explain: 'Washed coffees strip the fruit before drying — clarity and acidity show.' },
    { q: 'The “crema” on an espresso is…',
      choices: [{ t: 'Added milk foam' }, { t: 'Burnt sugar' }, { t: 'Emulsified oils + CO₂', correct: true }, { t: 'Undissolved grounds' }],
      explain: 'Crema is a fragile emulsion of oils and gas pushed out under pressure.' },
    { q: 'Harsh bitterness most often comes from…',
      choices: [{ t: 'Under-extraction' }, { t: 'Too much fruit' }, { t: 'Cold water' }, { t: 'Over-extraction / dark roast', correct: true }],
      explain: 'Pull too much, or roast too dark, and bitterness dominates.' },
    { q: 'A sour, thin cup is usually a sign of…',
      choices: [{ t: 'Over-extraction' }, { t: 'Under-extraction', correct: true }, { t: 'Too fine a grind' }, { t: 'Too much coffee' }],
      explain: 'Sour + weak = under-extracted. Grind finer or brew hotter/longer.' },
  ],
  processing: [
    { q: 'In the washed process, the fruit is…',
      choices: [{ t: 'Left on through drying' }, { t: 'Dried on before hulling' }, { t: 'Removed before drying', correct: true }, { t: 'Rinsed off after roasting' }],
      explain: 'Washed coffees have the cherry pulped and rinsed off before drying.' },
    { q: 'The natural process dries the bean…',
      choices: [{ t: 'Inside the whole cherry', correct: true }, { t: 'After pulping' }, { t: 'In water' }, { t: 'In the roaster' }],
      explain: 'Natural = the bean dries inside the intact fruit. More body, more fruit.' },
    { q: 'The honey process leaves…',
      choices: [{ t: 'Nothing on the bean' }, { t: 'Some sticky mucilage on the bean', correct: true }, { t: 'Added honey' }, { t: 'The skin only' }],
      explain: 'Honey sits between washed and natural — some mucilage stays on.' },
    { q: 'Which process usually tastes cleanest and brightest?',
      choices: [{ t: 'Natural' }, { t: 'Honey' }, { t: 'Anaerobic natural' }, { t: 'Washed', correct: true }],
      explain: 'Washing strips the fruit, so origin and acidity read clearly.' },
    { q: 'Take one bean, process it three ways. You get…',
      choices: [{ t: 'The same cup' }, { t: 'Different only if the roast changes too' }, { t: 'Three different cups', correct: true }, { t: 'Three cups apart in body, not flavour' }],
      explain: 'Processing changes a coffee more than roast does — same bean, three cups.' },
  ],
};

const duelType = (id) => DUEL_TYPES.find(t => t.id === id) || DUEL_TYPES[0];

// ── Points reward model ────────────────────────────────────
// A duel is lightweight: a flat entry reward plus a small per-correct bonus.
function duelPoints(correct, total) {
  return 15 + correct * 4; // 15…35 for a 5-q duel
}

// ── Opponents / personas ───────────────────────────────────
// Friends already in your contacts (demo), plus Roasty as the always-available
// no-friends-needed opponent.
const DUEL_FRIENDS = {
  sam: { id: 'sam', name: 'Sam',  initial: 'S' },
  mia: { id: 'mia', name: 'Mia',  initial: 'M' },
  roasty: { id: 'roasty', name: 'Roasty', initial: 'R', isRoasty: true },
};

// A believable friend run for the canonical comparison demo (Coffee basics).
// answers[i] = index the friend picked for question i.
const DEMO_FRIEND_RUN = {
  type: 'basics',
  friend: DUEL_FRIENDS.sam,
  answers: [1, 1, 0, 0, 1],   // misses Q3 and Q4 → 3/5
  correct: 3,
  total: 5,
  timeSec: 51,
  perQ: [9.4, 11.2, 8.1, 14.0, 8.3],
};

// The "you" side of the canonical comparison demo.
const DEMO_YOU_RUN = {
  type: 'basics',
  answers: [1, 1, 1, 1, 0],   // misses Q5 (picked half the caffeine)
  correct: 4,
  total: 5,
  timeSec: 42,
  perQ: [7.1, 3.1, 9.4, 12.6, 9.8],
};

// A losing version of the comparison — you trail the friend on every stat.
const DEMO_YOU_LOSS = {
  type: 'basics',
  answers: [1, 1, 0, 0, 0],   // 2/5
  correct: 2,
  total: 5,
  timeSec: 58,
  perQ: [10.2, 9.0, 15.1, 13.4, 11.0],
};
const DEMO_FRIEND_WIN = {
  type: 'basics',
  friend: DUEL_FRIENDS.sam,
  answers: [1, 1, 1, 1, 0],   // 4/5
  correct: 4,
  total: 5,
  timeSec: 44,
  perQ: [6.2, 4.1, 7.3, 9.0, 8.4],
};

// ── Demo records for the populated hub ─────────────────────
const DUEL_RECORDS = {
  // Friends who challenged you — your turn to play.
  incoming: [
    { id: 'in1', type: 'basics', friend: DUEL_FRIENDS.sam, theirScore: 4, theirTime: 51, ago: '2h ago', expires: 'in 6 days' },
    { id: 'in2', type: 'taste',  friend: DUEL_FRIENDS.mia, theirScore: 5, theirTime: 38, ago: 'Yesterday', expires: 'in 5 days' },
  ],
  // Challenges you sent that are still open.
  outgoing: [
    { id: 'out1', type: 'origin', friend: null, yourScore: 5, yourTime: 47, ago: '1h ago', expires: 'in 7 days', shared: 'Shared via link' },
  ],
  // Finished duels.
  done: [
    { id: 'dn1', type: 'taste',      friend: DUEL_FRIENDS.mia, yourScore: 5, theirScore: 3, won: true,  when: 'Yesterday' },
    { id: 'dn2', type: 'brew',       friend: DUEL_FRIENDS.sam, yourScore: 2, theirScore: 4, won: false, when: '2 days ago' },
    { id: 'dn3', type: 'processing', friend: DUEL_FRIENDS.roasty, yourScore: 4, theirScore: 4, won: null, when: '3 days ago' },
  ],
};

window.DUEL_TYPES = DUEL_TYPES;
window.DUEL_QUESTIONS = DUEL_QUESTIONS;
window.duelType = duelType;
window.duelPoints = duelPoints;
window.DUEL_FRIENDS = DUEL_FRIENDS;
window.DEMO_FRIEND_RUN = DEMO_FRIEND_RUN;
window.DEMO_YOU_RUN = DEMO_YOU_RUN;
window.DEMO_YOU_LOSS = DEMO_YOU_LOSS;
window.DEMO_FRIEND_WIN = DEMO_FRIEND_WIN;
window.DUEL_RECORDS = DUEL_RECORDS;
