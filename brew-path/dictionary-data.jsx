// dictionary-data.jsx — Coffee Dictionary content model + helpers.
// Loaded after data.jsx, before dictionary.jsx / app.jsx.
//
// Term shape:
//   { id, term, pron?, cat, aliases?, short, deep?, example?,
//     related?:[ids], lesson?, sources?:[{label,note?}],
//     check?:{ q, choices:[{t,correct?}], explain } }
// "Full" terms carry deep + example + check + sources; stubs carry just short.

const DICT_CATEGORIES = [
  { id: 'beans',      label: 'Beans and Botany',     glyph: 'cherry',   short: 'The plant, the seed, where it grows.' },
  { id: 'processing', label: 'Processing',          glyph: 'cherry-section', short: 'How the fruit becomes a green bean.' },
  { id: 'roasting',   label: 'Roasting',            glyph: 'roast-curve',    short: 'Heat, time, and the colour of the cup.' },
  { id: 'brewing',    label: 'Brewing',             glyph: 'pour',     short: 'Water, grounds, and extraction.' },
  { id: 'espresso',   label: 'Espresso',            glyph: 'shot',     short: 'Pressure, crema, and small strong cups.' },
  { id: 'sensory',    label: 'Sensory Vocabulary',  glyph: 'taste-wheel',    short: 'The words for what you taste.' },
  { id: 'equipment',  label: 'Equipment',           glyph: 'gear',     short: 'The tools that make the cup.' },
  { id: 'trade',      label: 'Coffee Trade',        glyph: 'scales',         short: 'From farm to roaster, and who gets paid.' },
];

const DICT_TERMS = [
  // ── BEANS and BOTANY ───────────────────────────────────────
  { id: 'arabica', term: 'Arabica', pron: 'uh-RAB-ih-kuh', cat: 'beans',
    short: 'The coffee species behind most specialty coffee — sweeter, more aromatic, and more delicate to grow.',
    deep: 'Arabica accounts for roughly 60% of world coffee. It thrives at higher, cooler elevations, which slows the cherry’s growth and builds sugars and acidity. That nuance is also why it’s fussier: more vulnerable to heat, pests, and disease than robusta.',
    example: 'A bag that says “100% Arabica” is signalling a softer, more flavour-forward cup.',
    related: ['robusta', 'cultivar', 'single-origin'], lesson: 'm1l2',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }, { label: 'SCA — Coffee Basics', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'Compared with robusta, arabica usually has…',
      choices: [{ t: 'More caffeine' }, { t: 'More sweetness and acidity', correct: true }, { t: 'A heavier, more bitter body' }],
      explain: 'Arabica is prized for sweetness and bright acidity; robusta carries more caffeine and bitterness.' } },

  { id: 'robusta', term: 'Robusta', pron: 'roh-BUST-uh', cat: 'beans',
    short: 'A hardier coffee species with nearly double the caffeine — bolder, more bitter, and easier to farm.',
    deep: 'Coffea canephora (robusta) grows well at low elevations in hot, humid climates and resists disease, so it’s cheaper to produce. It brings heavy body and a grain-like bitterness, and shows up in espresso blends for crema and punch, and in instant coffee.',
    example: 'A little robusta in an espresso blend can deepen the crema and add a caffeine kick.',
    related: ['arabica', 'crema'], lesson: 'm1l2',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'Robusta is best known for…',
      choices: [{ t: 'About twice the caffeine of arabica', correct: true }, { t: 'The most delicate florals' }, { t: 'Growing only at high altitude' }],
      explain: 'Robusta carries ~2.4% caffeine vs arabica’s ~1.2%, and grows happily at low elevation.' } },

  { id: 'cultivar', term: 'Cultivar', pron: 'KUHL-tih-var', cat: 'beans',
    short: 'A cultivated variety of coffee plant, bred or selected for traits like flavour, yield, or disease resistance.',
    deep: 'Think of cultivars the way you think of apple varieties — Bourbon, Typica, Gesha and SL28 are all arabica, but each brings its own character. Some are chosen for cup quality, others for surviving leaf rust.',
    example: '“Gesha” on a label points to a prized cultivar famous for jasmine-like aromatics.',
    related: ['arabica', 'single-origin', 'terroir'], lesson: 'm1l3',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'A cultivar is best described as…',
      choices: [{ t: 'A brewing method' }, { t: 'A cultivated variety of the coffee plant', correct: true }, { t: 'A roast level' }],
      explain: 'A cultivar is a specific cultivated variety — like Bourbon or Gesha.' } },

  { id: 'cherry', term: 'Coffee Cherry', cat: 'beans', aliases: ['cherry', 'cherries', 'coffee cherry'],
    short: 'The fruit of the coffee plant. Each cherry holds two seeds — the “beans” we roast.',
    related: ['arabica', 'bean-belt'], lesson: 'm1l1' },
  { id: 'bean-belt', term: 'Bean Belt', cat: 'beans', aliases: ['bean belt'],
    short: 'The band around the equator, roughly 25°N to 25°S, where coffee grows best.',
    related: ['cherry', 'terroir'], lesson: 'm1l1' },
  { id: 'terroir', term: 'Terroir', pron: 'tair-WAHR', cat: 'beans',
    short: 'The sense of place in a cup — how soil, altitude and climate shape a coffee’s flavour.',
    related: ['single-origin', 'cultivar'], lesson: 'm1l3' },

  // ── PROCESSING ───────────────────────────────────────────
  { id: 'washed', term: 'Washed Process', cat: 'processing', aliases: ['washed process', 'washed'],
    short: 'The fruit is stripped and the seeds are fermented and rinsed clean before drying — giving a clean, bright cup.',
    deep: 'Also called the “wet” process. Removing the fruit early lets the bean’s own character and acidity shine, with less of the fruit’s influence. It needs plenty of water and careful fermentation control.',
    example: 'Washed Kenyans are famous for their crisp, almost blackcurrant-like acidity.',
    related: ['natural', 'honey', 'fermentation'], lesson: 'm2l1',
    sources: [{ label: 'Perfect Daily Grind — Processing 101', url: 'https://perfectdailygrind.com/2016/07/washed-natural-honey-coffee-processing-101/' }],
    check: { q: 'Washed coffees tend to taste…',
      choices: [{ t: 'Clean and bright', correct: true }, { t: 'Heavy and boozy' }, { t: 'Always decaffeinated' }],
      explain: 'Removing the fruit early gives washed coffees their signature clarity and acidity.' } },

  { id: 'natural', term: 'Natural Process', cat: 'processing', aliases: ['natural process', 'dry process'],
    short: 'The whole cherry is dried with the fruit still on, pushing fruity, sometimes wine-like sweetness into the bean.',
    deep: 'The oldest method: cherries dry in the sun for weeks before the dried fruit is removed. It uses little water but demands constant turning to avoid mould. Results are heavier-bodied and fruit-forward.',
    example: 'A natural Ethiopian can taste of blueberry and ripe strawberry.',
    related: ['washed', 'honey', 'fermentation'], lesson: 'm2l1',
    sources: [{ label: 'Perfect Daily Grind — Processing 101', url: 'https://perfectdailygrind.com/2016/07/washed-natural-honey-coffee-processing-101/' }],
    check: { q: 'In the natural process, the cherry is…',
      choices: [{ t: 'Dried whole, fruit and all', correct: true }, { t: 'Washed clean before drying' }, { t: 'Roasted while still wet' }],
      explain: 'Naturals dry with the fruit attached, which is where the bold fruity sweetness comes from.' } },

  { id: 'honey', term: 'Honey Process', cat: 'processing', aliases: ['honey process'],
    short: 'A middle path: some fruit pulp is left on the bean during drying, balancing sweetness and clarity.',
    related: ['washed', 'natural'], lesson: 'm2l1' },
  { id: 'fermentation', term: 'Fermentation', cat: 'processing',
    short: 'The controlled breakdown of the cherry’s sugars that develops flavour during processing.',
    related: ['washed', 'natural'], lesson: 'm2l2' },

  // ── ROASTING ─────────────────────────────────────────────
  { id: 'first-crack', term: 'First Crack', cat: 'roasting', aliases: ['first crack'],
    short: 'The audible pop during roasting when beans expand and steam escapes — the threshold of a drinkable roast.',
    deep: 'As beans heat, moisture turns to steam and pressure builds until the bean cracks open, like popcorn. First crack marks the start of light-roast territory; how far past it you go decides light, medium, or dark.',
    example: 'Pulling beans just after first crack gives a bright, light roast.',
    related: ['second-crack', 'roast-level', 'development'], lesson: 'm3l2',
    sources: [{ label: 'Scott Rao — The Coffee Roaster’s Companion' }],
    check: { q: 'First crack signals…',
      choices: [{ t: 'The beans are burnt' }, { t: 'The start of a drinkable roast', correct: true }, { t: 'The grinder is too fine' }],
      explain: 'First crack is the audible milestone where a roast becomes light-roast ready.' } },

  { id: 'roast-level', term: 'Roast Level', cat: 'roasting', aliases: ['roast level'],
    short: 'How far a coffee is roasted — light, medium, or dark — which shapes acidity, body and bitterness.',
    deep: 'Lighter roasts keep more origin character and acidity; darker roasts trade that for body, bitterness and roasty notes. Neither is “better” — it’s a flavour choice.',
    example: 'A light roast tastes of the bean; a dark roast tastes more of the roast.',
    related: ['first-crack', 'second-crack', 'roast-date'], lesson: 'm3l1',
    sources: [{ label: 'SCA — Coffee Standards', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'As roast level gets darker, acidity usually…',
      choices: [{ t: 'Increases' }, { t: 'Decreases', correct: true }, { t: 'Stays identical' }],
      explain: 'Darker roasting burns off acidity and adds bitterness and body.' } },

  { id: 'second-crack', term: 'Second Crack', cat: 'roasting', aliases: ['second crack'],
    short: 'A second, quieter cracking deeper into the roast that marks the edge of dark-roast territory.',
    related: ['first-crack', 'roast-level'], lesson: 'm3l2' },
  { id: 'development', term: 'Development Time', cat: 'roasting', aliases: ['development time', 'development'],
    short: 'The stretch after first crack that balances the inside and outside of the bean.',
    related: ['first-crack'], lesson: 'm3l2' },
  { id: 'roast-date', term: 'Roast Date', cat: 'roasting', aliases: ['roast date'],
    short: 'When the coffee was roasted — fresher is better; aim to brew within a few weeks.',
    related: ['roast-level'], lesson: 'm3l3' },

  // ── BREWING ──────────────────────────────────────────────
  { id: 'bloom', term: 'Bloom', cat: 'brewing',
    short: 'The first splash of water on fresh grounds, which releases trapped CO₂ and makes the bed swell and bubble.',
    deep: 'Fresh coffee is full of carbon dioxide. Wetting it for 30–45 seconds before the main pour lets that gas escape, so water can extract evenly instead of channelling around bubbles.',
    example: 'A vigorous bloom is a good sign your coffee is fresh.',
    related: ['extraction', 'brew-ratio', 'pour-over'], lesson: 'm5l1',
    sources: [{ label: 'James Hoffmann — Technique Guides' }],
    check: { q: 'The bloom releases…',
      choices: [{ t: 'Caffeine' }, { t: 'Trapped CO₂ gas', correct: true }, { t: 'Oils only' }],
      explain: 'Blooming lets built-up CO₂ escape so extraction is even.' } },

  { id: 'brew-ratio', term: 'Brew Ratio', cat: 'brewing', aliases: ['brew ratio'],
    short: 'The proportion of coffee to water — the single biggest lever on strength, often written like 1:16.',
    deep: 'A 1:16 ratio means 1 gram of coffee to 16 grams of water. Lower numbers (1:12) brew stronger; higher (1:18) brew lighter. Dial this to taste before fiddling with anything else.',
    example: '60 g of coffee to 1,000 g of water is a classic ~1:16 batch-brew ratio.',
    related: ['extraction', 'tds', 'bloom'], lesson: 'm5l1',
    sources: [{ label: 'SCA — Brewing Control Chart', url: 'https://sca.coffee/sca-news/25/issue-13/towards-a-new-brewing-chart' }],
    check: { q: 'A 1:12 ratio versus 1:18 will taste…',
      choices: [{ t: 'Stronger', correct: true }, { t: 'Weaker' }, { t: 'Identical' }],
      explain: 'Less water per gram of coffee (1:12) makes a stronger, more concentrated cup.' } },

  { id: 'extraction', term: 'Extraction', cat: 'brewing',
    short: 'How much flavour is dissolved out of the grounds — too little tastes sour, too much tastes bitter.',
    deep: 'Water pulls compounds out of coffee in an order: fruity acids first, sweetness next, bitter and dry notes last. The sweet spot — “even extraction” — is the goal of grinding, ratio and time.',
    example: 'Sour, weak coffee is usually under-extracted; harsh, dry coffee is over-extracted.',
    related: ['brew-ratio', 'tds', 'bloom'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Brewing Control Chart', url: 'https://sca.coffee/sca-news/25/issue-13/towards-a-new-brewing-chart' }],
    check: { q: 'A sour, thin cup is most likely…',
      choices: [{ t: 'Over-extracted' }, { t: 'Under-extracted', correct: true }, { t: 'Perfectly balanced' }],
      explain: 'Sourness usually means too little was extracted — grind finer or brew longer.' } },

  { id: 'tds', term: 'TDS', pron: 'T-D-S', cat: 'brewing',
    short: 'Total Dissolved Solids — a measured number for how strong a brew is.',
    related: ['extraction', 'brew-ratio'], lesson: 'm5l3' },
  { id: 'pour-over', term: 'Pour-Over', cat: 'brewing', aliases: ['pour-over', 'pour over'],
    short: 'Brewing by pouring hot water through grounds in a filter cone, like a V60 or Chemex.',
    related: ['bloom', 'immersion', 'gooseneck'], lesson: 'm5l1' },
  { id: 'immersion', term: 'Immersion', cat: 'brewing',
    short: 'Brewing by steeping grounds fully in water, like a French press, then separating them.',
    related: ['pour-over'], lesson: 'm5l1' },

  // ── ESPRESSO ─────────────────────────────────────────────
  { id: 'crema', term: 'Crema', pron: 'KREH-muh', cat: 'espresso',
    short: 'The reddish-brown foam on top of an espresso shot, made of emulsified oils and CO₂.',
    deep: 'Crema forms when pressurised water forces oils and gases into a fine emulsion. It’s a sign of fresh coffee and a well-pulled shot, though it isn’t the whole story of quality.',
    example: 'A thick, hazelnut-coloured crema usually means fresh beans and a good extraction.',
    related: ['portafilter', 'robusta', 'channeling'], lesson: 'm4l1',
    sources: [{ label: 'Perfect Daily Grind — Espresso Basics', url: 'https://perfectdailygrind.com/2020/04/crema-how-its-formed-what-it-tells-us-how-to-learn-from-it/' }],
    check: { q: 'Crema is mostly made of…',
      choices: [{ t: 'Milk foam' }, { t: 'Emulsified oils and CO₂', correct: true }, { t: 'Sugar' }],
      explain: 'Crema is an emulsion of coffee oils and dissolved gas, not milk.' } },

  { id: 'portafilter', term: 'Portafilter', pron: 'POR-tuh-fil-ter', cat: 'espresso',
    short: 'The handled basket that holds the coffee grounds and locks into an espresso machine.',
    deep: 'You grind into the portafilter, distribute and tamp the grounds level, then lock it into the group head. Even, well-tamped coffee in the basket is the key to an even shot.',
    example: 'Knocking the spent puck out of the portafilter is the satisfying clack you hear in cafés.',
    related: ['crema', 'tamp', 'channeling'], lesson: 'm4l1',
    sources: [{ label: 'Perfect Daily Grind — Espresso Basics', url: 'https://perfectdailygrind.com/2020/04/crema-how-its-formed-what-it-tells-us-how-to-learn-from-it/' }],
    check: { q: 'The portafilter…',
      choices: [{ t: 'Heats the water' }, { t: 'Holds the grounds and locks into the machine', correct: true }, { t: 'Grinds the beans' }],
      explain: 'It’s the basket-and-handle that carries the tamped coffee into the group head.' } },

  { id: 'cortado', term: 'Cortado', pron: 'kor-TAH-doh', cat: 'espresso',
    short: 'An espresso “cut” with a small, equal amount of warm milk to soften it.',
    related: ['crema'], lesson: 'm4l1' },
  { id: 'channeling', term: 'Channeling', cat: 'espresso',
    short: 'When water forces a path through cracks in the espresso puck, extracting unevenly.',
    related: ['portafilter', 'tamp', 'extraction'], lesson: 'm4l2' },
  { id: 'tamp', term: 'Tamp', cat: 'espresso',
    short: 'Pressing the espresso grounds flat and firm in the portafilter for an even shot.',
    related: ['portafilter', 'channeling'], lesson: 'm4l1' },

  // ── SENSORY VOCABULARY ───────────────────────────────────
  { id: 'acidity', term: 'Acidity', cat: 'sensory',
    short: 'The bright, tangy liveliness in coffee — pleasant acidity tastes crisp, like citrus or apple, not sour.',
    deep: 'Acidity is a positive quality in tasting language, distinct from “sour” (a fault of under-extraction). High-grown washed coffees tend to be the most acidic, in a sparkling, mouth-watering way.',
    example: 'A Kenyan’s juicy, blackcurrant acidity is what fans love about it.',
    related: ['body', 'balance', 'finish'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Flavor Wheel and Lexicon', url: 'https://sca.coffee/sca-news/how-to-use-the-flavor-wheel-in-eight-steps' }],
    check: { q: 'In tasting terms, pleasant acidity is…',
      choices: [{ t: 'A flaw to avoid' }, { t: 'A bright, lively quality', correct: true }, { t: 'The same as bitterness' }],
      explain: 'Acidity is prized brightness — different from the sour taste of under-extraction.' } },

  { id: 'body', term: 'Body', cat: 'sensory',
    short: 'How heavy or full a coffee feels in your mouth — from tea-like and light to syrupy and thick.',
    deep: 'Also called mouthfeel. Body comes from oils and fine particles suspended in the brew. A French press feels heavier than a paper-filtered pour-over because the filter holds less back.',
    example: 'Naturals and dark roasts often feel fuller-bodied.',
    related: ['mouthfeel', 'acidity', 'balance'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Flavor Wheel and Lexicon', url: 'https://sca.coffee/sca-news/how-to-use-the-flavor-wheel-in-eight-steps' }],
    check: { q: 'Body refers to…',
      choices: [{ t: 'The coffee’s weight and texture in the mouth', correct: true }, { t: 'Its temperature' }, { t: 'Its caffeine level' }],
      explain: 'Body is the tactile weight of the cup — light and tea-like to thick and syrupy.' } },

  { id: 'mouthfeel', term: 'Mouthfeel', cat: 'sensory',
    short: 'The texture and weight of coffee on your tongue — another word for body.',
    related: ['body'], lesson: 'm5l3' },
  { id: 'finish', term: 'Finish', cat: 'sensory', aliases: ['finish', 'aftertaste'],
    short: 'The flavour that lingers after you swallow — short and clean, or long and sweet.',
    related: ['acidity', 'balance'], lesson: 'm5l3' },
  { id: 'balance', term: 'Balance', cat: 'sensory',
    short: 'How well a coffee’s sweetness, acidity, body and bitterness fit together.',
    related: ['acidity', 'body', 'finish'], lesson: 'm5l3' },

  // ── EQUIPMENT ────────────────────────────────────────────
  { id: 'burr-grinder', term: 'Burr Grinder', cat: 'equipment', aliases: ['burr grinder'],
    short: 'A grinder that crushes beans between two burrs for an even, adjustable grind — the single best brewing upgrade.',
    deep: 'Unlike blade grinders that chop randomly, burrs produce uniform particles, which is essential for even extraction. The gap between the burrs sets how fine or coarse you grind.',
    example: 'Switching from a blade to a burr grinder is the upgrade most people notice first.',
    related: ['grind-size', 'extraction', 'scale'], lesson: 'm4l2',
    sources: [{ label: 'James Hoffmann — Gear Guides' }],
    check: { q: 'Burr grinders are better because they…',
      choices: [{ t: 'Grind more evenly', correct: true }, { t: 'Are always cheaper' }, { t: 'Add caffeine' }],
      explain: 'Even particle size from burrs gives more even, better-tasting extraction.' } },

  { id: 'gooseneck', term: 'Gooseneck Kettle', cat: 'equipment', aliases: ['gooseneck kettle', 'gooseneck'],
    short: 'A kettle with a long, curved spout that gives slow, precise control over your pour.',
    deep: 'The narrow spout lets you place water exactly where you want it and control the flow rate — important for even pour-over brewing and a controlled bloom.',
    example: 'A gooseneck makes it easy to pour in slow, steady spirals over the grounds.',
    related: ['pour-over', 'bloom', 'scale'], lesson: 'm5l1',
    sources: [{ label: 'James Hoffmann — Gear Guides' }],
    check: { q: 'A gooseneck kettle helps you…',
      choices: [{ t: 'Boil faster' }, { t: 'Pour slowly and precisely', correct: true }, { t: 'Grind finer' }],
      explain: 'Its curved spout is all about pour control, not speed.' } },

  { id: 'aeropress', term: 'AeroPress', pron: 'AIR-oh-press', cat: 'equipment',
    short: 'A compact plunger brewer that uses gentle pressure to make a quick, clean cup.',
    related: ['immersion', 'pour-over'], lesson: 'm5l1' },
  { id: 'chemex', term: 'Chemex', pron: 'CHEM-ex', cat: 'equipment',
    short: 'An hourglass-shaped pour-over brewer using thick filters for an exceptionally clean cup.',
    related: ['pour-over'], lesson: 'm5l1' },
  { id: 'scale', term: 'Scale', cat: 'equipment',
    short: 'A small kitchen scale lets you weigh coffee and water for a repeatable brew ratio.',
    related: ['brew-ratio', 'gooseneck'], lesson: 'm5l1' },
  { id: 'grind-size', term: 'Grind Size', cat: 'equipment', aliases: ['grind size'],
    short: 'How coarse or fine the coffee is ground — the main dial for matching your brew method.',
    related: ['burr-grinder', 'extraction'], lesson: 'm4l1' },

  // ── COFFEE TRADE ─────────────────────────────────────────
  { id: 'single-origin', term: 'Single Origin', cat: 'trade', aliases: ['single origin', 'single-origin'],
    short: 'Coffee from one place — a country, region, or even a single farm — rather than a blend.',
    deep: 'Single origins let you taste the character of a specific place and harvest. Blends mix origins for consistency or a target flavour; single origins celebrate difference.',
    example: '“Ethiopia Yirgacheffe” is a single origin; “House Blend” usually isn’t.',
    related: ['terroir', 'cultivar', 'traceability'], lesson: 'm1l3',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'A single-origin coffee comes from…',
      choices: [{ t: 'One defined place', correct: true }, { t: 'A mix of many countries' }, { t: 'A specific roast level' }],
      explain: 'Single origin means one source — country, region or farm — not a blend.' } },

  { id: 'fair-trade', term: 'Fair Trade', cat: 'trade', aliases: ['fair trade', 'fairtrade'],
    short: 'A certification that guarantees farmers a minimum price and community premiums for their coffee.',
    deep: 'Fair Trade sets a price floor to protect growers from volatile markets and adds a premium for community projects. It’s one of several models aiming to make the supply chain fairer.',
    example: 'A Fair Trade label means the co-op was paid at least the guaranteed minimum.',
    related: ['direct-trade', 'traceability', 'specialty'], lesson: 'm1l3',
    sources: [{ label: 'Fairtrade International — Standards', url: 'https://www.fairtrade.net/en/why-fairtrade/how-we-do-it/standards.html' }],
    check: { q: 'Fair Trade mainly guarantees…',
      choices: [{ t: 'A minimum price for farmers', correct: true }, { t: 'A darker roast' }, { t: 'Faster shipping' }],
      explain: 'Its core promise is a price floor plus a community premium for growers.' } },

  { id: 'direct-trade', term: 'Direct Trade', cat: 'trade', aliases: ['direct trade'],
    short: 'Roasters buying straight from farmers, often paying above market for quality and relationships.',
    related: ['fair-trade', 'traceability'], lesson: 'm1l3' },
  { id: 'traceability', term: 'Traceability', cat: 'trade',
    short: 'Knowing exactly where a coffee came from, down to the farm or washing station.',
    related: ['single-origin', 'direct-trade'], lesson: 'm1l3' },
  { id: 'specialty', term: 'Specialty Coffee', cat: 'trade', aliases: ['specialty coffee'],
    short: 'High-quality coffee scoring 80+ points on a 100-point scale, made with care at every step.',
    related: ['single-origin', 'arabica'], lesson: 'm1l1' },
];

// ── Lookups ─────────────────────────────────────────────────
const DICT_BY_ID = {};
DICT_TERMS.forEach(t => { DICT_BY_ID[t.id] = t; });

const DICT_CAT_BY_ID = {};
DICT_CATEGORIES.forEach(c => { DICT_CAT_BY_ID[c.id] = c; });

// Terms seeded as already "learned" for the prototype, so the status mechanic
// is visible on first run. The live set also unions in any terms whose related
// lesson sits in the user's completed set (see termLearned()).
const DICT_LEARNED_SEED = ['cherry', 'bean-belt', 'specialty', 'arabica', 'washed', 'bloom'];

// A term counts as learned if it's in the seed, or its lesson is completed.
function termLearned(term, completedSet) {
  if (!term) return false;
  if (DICT_LEARNED_SEED.indexOf(term.id) >= 0) return true;
  return !!(term.lesson && completedSet && completedSet.has(term.lesson));
}

// Build the set of learned term ids for a given completed-lessons set.
function learnedTermSet(completedSet) {
  const s = new Set(DICT_LEARNED_SEED);
  DICT_TERMS.forEach(t => { if (t.lesson && completedSet && completedSet.has(t.lesson)) s.add(t.id); });
  return s;
}

// "Term of the day" — deterministic pick among full terms, rotating by date.
function dictTermOfDay(date) {
  const full = DICT_TERMS.filter(t => t.check); // full entries only
  const d = date || new Date(2026, 5, 18); // frozen demo date
  const dayNum = Math.floor((Date.UTC(d.getFullYear(), d.getMonth(), d.getDate())) / 86400000);
  return full[((dayNum % full.length) + full.length) % full.length];
}

// Count terms per category.
function dictCatCounts() {
  const m = {};
  DICT_CATEGORIES.forEach(c => { m[c.id] = 0; });
  DICT_TERMS.forEach(t => { if (m[t.cat] != null) m[t.cat]++; });
  return m;
}

// Alias index for in-lesson term linking — [{ alias, id }] sorted longest-first
// so multi-word terms match before their fragments. Only terms with a short
// definition are linkable.
const GLOSSARY_INDEX = (() => {
  const out = [];
  DICT_TERMS.forEach(t => {
    const aliases = t.aliases && t.aliases.length ? t.aliases : [t.term.toLowerCase()];
    aliases.forEach(a => out.push({ alias: a.toLowerCase(), id: t.id }));
  });
  out.sort((a, b) => b.alias.length - a.alias.length);
  return out;
})();

window.DICT_CATEGORIES = DICT_CATEGORIES;
window.DICT_TERMS = DICT_TERMS;
window.DICT_BY_ID = DICT_BY_ID;
window.DICT_CAT_BY_ID = DICT_CAT_BY_ID;
window.DICT_LEARNED_SEED = DICT_LEARNED_SEED;
window.GLOSSARY_INDEX = GLOSSARY_INDEX;
window.termLearned = termLearned;
window.learnedTermSet = learnedTermSet;
window.dictTermOfDay = dictTermOfDay;
window.dictCatCounts = dictCatCounts;
