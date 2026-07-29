// Sample content for the BrewPath prototype.

const MODULES = [
  {
    id: 'm1', n: 1, label: 'BEANS', title: 'Beans', glyph: 'beans',
    locked: false,
    lessons: [
      { id: 'm1l1', title: 'What coffee actually is', xp: 10, time: 3, status: 'complete' },
      { id: 'm1l2', title: 'Arabica vs Robusta',     xp: 10, time: 3, status: 'current' },
      { id: 'm1l3', title: 'What origin means',      xp: 10, time: 4, status: 'locked' },
    ],
  },
  {
    id: 'm2', n: 2, label: 'PROCESSING', title: 'Processing', glyph: 'processing',
    locked: true,
    lessons: [
      { id: 'm2l1', title: 'Washed, natural, honey', xp: 10, time: 4, status: 'locked' },
      { id: 'm2l2', title: 'Why processing matters', xp: 10, time: 4, status: 'locked' },
      { id: 'm2l3', title: 'Reading a bag label',    xp: 10, time: 3, status: 'locked' },
    ],
  },
  { id: 'm3', n: 3, label: 'ROASTING',  title: 'Roasting',  glyph: 'roasting', locked: true, lessons: [
      { id: 'm3l1', title: 'Light, medium, dark', xp: 10, time: 4, status: 'locked' },
      { id: 'm3l2', title: 'First and second crack', xp: 10, time: 5, status: 'locked' },
      { id: 'm3l3', title: 'Reading a roast date',   xp: 10, time: 3, status: 'locked' },
  ]},
  { id: 'm4', n: 4, label: 'GRIND',     title: 'Grind',     glyph: 'grind', locked: true, lessons: [
      { id: 'm4l1', title: 'Particle size, in plain English', xp: 10, time: 4, status: 'locked' },
      { id: 'm4l2', title: 'Burr vs blade',                   xp: 10, time: 4, status: 'locked' },
      { id: 'm4l3', title: 'Dialing in by taste',             xp: 10, time: 5, status: 'locked' },
  ]},
  { id: 'm5', n: 5, label: 'BREW',      title: 'Brew',      glyph: 'brewing', locked: true, lessons: [
      { id: 'm5l1', title: 'The brew ratio',     xp: 10, time: 5, status: 'locked' },
      { id: 'm5l2', title: 'Water, the variable', xp: 10, time: 4, status: 'locked' },
      { id: 'm5l3', title: 'Tasting your cup',   xp: 10, time: 5, status: 'locked' },
  ]},
];

// Lessons with full card payloads. All 15 lessons across the five modules are authored.
const LESSONS = {
  m1l1: {
    moduleLabel: 'MODULE 1 · BEANS',
    title: 'What coffee actually is',
    xp: 10, time: 3,
    cards: [
      { kind: 'predict', label: 'LESSON 1', title: 'What coffee actually is',
        body: 'Coffee starts on a tree, inside something that looks like a small red cherry. Before we get into it — one guess.',
        question: 'A coffee bean is really the ___ of that fruit.',
        options: ['Seed', 'Skin'],
        a: 'Seed',
        hold: 'Hold that thought. You’ll know for certain in about three minutes.' },
      { kind: 'concept', label: 'CONCEPT', title: 'The cherry, the seed',
        fill: ['A coffee ', { a: 'bean', o: ['bean', 'berry'], label: 'What we call it' }, ' is really the ', { a: 'seed', o: ['seed', 'skin'], label: 'What it is' }, ' of a fruit.'],
        paragraphs: [
          'A coffee plant grows small red cherries. Inside each cherry sit two flat-faced seeds, pressed against each other.',
          'Those seeds are what we roast and brew. \u201CBean\u201D is a misnomer — they\u2019re seeds of a fruit, closer to a pit than a legume.',
        ],
        meta: [['LOOKS LIKE', 'cherry'], ['ACTUALLY IS', 'seed']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'The bean belt',
        fill: ['Coffee grows in a band around the ', { a: 'equator', o: ['equator', 'poles'], label: 'Where' }, ', where the air stays ', { a: 'mild', o: ['mild', 'freezing'], label: 'Climate' }, ' and rain is reliable.'],
        paragraphs: [
          'Coffee grows in a band around the equator: roughly 25° north to 25° south. High elevation, mild temperatures, reliable rain.',
          'Different geography puts different things in the cup. That\u2019s why origin matters.',
        ],
        meta: [['COMMON IN', 'Ethiopia, Kenya'], ['ALSO', 'Colombia, Brazil']],
      },
      { kind: 'mcq',
        prompt: 'What part of the coffee plant do we drink?',
        choices: [
          { t: 'Leaf' },
          { t: 'Seed', correct: true },
          { t: 'Root' },
          { t: 'Flower' },
        ],
        explain: 'A coffee bean is the seed of the cherry. Always has been.',
      },
      { kind: 'mcq',
        prompt: 'How many seeds sit inside a typical coffee cherry?',
        choices: [
          { t: 'One' },
          { t: 'Two', correct: true },
          { t: 'Five' },
          { t: 'A dozen' },
        ],
        explain: 'Two flat-faced seeds sit pressed together inside each cherry.',
      },
      { kind: 'mcq',
        prompt: 'Where does coffee grow best?',
        choices: [
          { t: 'In a band around the equator', correct: true },
          { t: 'Only near the poles' },
          { t: 'In dry lowland deserts' },
          { t: 'Below sea level' },
        ],
        explain: 'The "bean belt" runs roughly 25° N to 25° S — high, mild and rainy.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Fresh beans do most of the work',
        scenario: 'Your coffee has tasted flat and lifeless all week. In the cupboard: your usual bag, opened two months ago. On the shelf at the shop: the same coffee, roasted three days ago.',
        question: 'What do you change first?',
        options: [
          { t: 'Buy the freshly roasted bag', sub: 'Roasted 3 days ago', correct: true },
          { t: 'Keep the old bag, grind finer', sub: 'Opened 2 months ago' },
        ],
        right: 'Coffee is fruit, and fruit goes stale. Fresh beans do more for a flat cup than any adjustment you can make to the brew.',
        wrong: 'Grinding finer can’t put back aromatics that have already faded. You’ll extract harder from tired coffee and get bitterness instead of life.',
        note: 'If your coffee tastes flat and lifeless, the beans may be old. Changing grind size won’t fully fix stale beans.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A friend calls coffee a bean, like a kidney bean. What’s the accurate correction?',
        choices: [
          { t: 'It’s the seed of a fruit — a coffee cherry', correct: true },
          { t: 'It’s the dried leaf of the coffee plant' },
          { t: 'It’s a true bean, just grown in the tropics' },
        ],
        explain: 'It looks and cooks like a bean, but botanically it’s a seed from a fruit. That single fact explains why freshness, origin and processing all matter.',
        line: 'Coffee is fruit. Everything else follows from that.' },
    ],
    reward: {
      title: 'The Coffee Cherry',
      summary: 'The fruit of the coffee plant. Two seeds inside each one.',
      fact: 'Cherries ripen unevenly on the same branch — pickers return three or four times.',
      meta: [
        ['FAMILY', 'Rubiaceae'],
        ['ORIGIN', 'Ethiopia, ~9th c.'],
        ['FRUIT', 'Drupe / cherry'],
      ],
    },
  },

  m1l2: {
    moduleLabel: 'MODULE 1 · BEANS',
    title: 'Arabica vs Robusta',
    xp: 10, time: 3,
    cards: [
      { kind: 'predict', label: 'LESSON 2', title: 'Arabica vs Robusta',
        body: 'Two species do almost all of the world\u2019s coffee. Before we start — one guess.',
        question: 'Which one carries nearly twice the caffeine?',
        options: ['Arabica', 'Robusta'],
        a: 'Robusta',
        hold: 'No peeking — you’ll know for certain in about three minutes.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Arabica',
        fill: ['Arabica grows at ', { a: 'higher', o: ['lower', 'higher'], label: 'Elevation' }, ' elevations and carries ', { a: 'less', o: ['less', 'more'], label: 'Caffeine' }, ' caffeine than Robusta.'],
        paragraphs: [
          'About 60% of world coffee. Higher elevations, cooler air, more delicate. Sweeter, more aromatic, more acidity.',
          'Most specialty coffee is arabica. It\u2019s also more fragile to grow.',
        ],
        meta: [['ELEVATION', '900–2000m'], ['CAFFEINE', '~1.2%']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Robusta',
        fill: ['Robusta grows at ', { a: 'lower', o: ['lower', 'higher'], label: 'Elevation' }, ' elevations and carries ', { a: 'more', o: ['more', 'less'], label: 'Caffeine' }, ' caffeine than Arabica.'],
        paragraphs: [
          'Hardier, lower-elevation, almost twice the caffeine. Heavier-bodied, more bitter, more grain-like.',
          'Common in espresso blends for crema and punch, and in instant coffee.',
        ],
        meta: [['ELEVATION', '0–900m'], ['CAFFEINE', '~2.4%']],
      },
      { kind: 'match',
        prompt: 'Match each trait to its species.',
        pairs: [
          { l: 'Higher elevations',  r: 'Arabica' },
          { l: 'More caffeine',      r: 'Robusta' },
          { l: 'Sweeter, aromatic',  r: 'Arabica' },
          { l: 'Hardier to grow',    r: 'Robusta' },
        ],
      },
      { kind: 'multi',
        prompt: 'Which of these are true of Arabica? Select all that apply.',
        choices: [
          { t: 'Grows at higher elevations', correct: true },
          { t: 'Sweeter and more aromatic', correct: true },
          { t: 'About 60% of world coffee', correct: true },
          { t: 'Nearly twice the caffeine' },
          { t: 'Hardier and easier to grow' },
        ],
        explain: 'Arabica is the high-grown, sweeter, more aromatic species — about 60% of world coffee. The extra caffeine and hardiness belong to Robusta.',
      },
      { kind: 'slider',
        prompt: 'How fine should you grind for a V60?',
        leftLabel: 'FINER', rightLabel: 'COARSER',
        target: 55, tolerance: 12,
        scale: [
          'Flour — espresso',
          'Table salt — moka pot',
          'Kosher salt — pour-over',
          'Coarse sand — French press',
          'Peppercorns — cold brew',
        ],
        feedback: 'Aim for medium — somewhere between table salt and kosher salt.',
      },
      { kind: 'sequence',
        prompt: 'Order these by typical caffeine, lowest to highest.',
        items: [
          { label: 'Decaf', order: 1 },
          { label: 'Arabica', order: 2 },
          { label: 'Robusta', order: 3 },
        ],
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Choosing beans by taste',
        scenario: 'A friend tried your coffee last week and said it tasted harsh and bitter to them. You’re buying a bag to brew for them again.',
        question: 'Which bag do you reach for?',
        options: [
          { t: '100% Arabica', sub: 'Colombia · medium roast', correct: true },
          { t: '80/20 Arabica–Robusta', sub: 'Espresso blend · dark roast' },
        ],
        right: 'Arabica leans sweeter, brighter and more delicate. It sets a lower ceiling on bitterness before you touch grind or water.',
        wrong: 'That Robusta share is exactly what adds the heavy, bitter, grain-like edge. It earns its place in espresso for crema and punch — but not for the friend who found your last cup harsh.',
        note: 'Bean choice sets the ceiling on bitterness, acidity and body before grind or water ever come into play.' },
      { kind: 'tastefix',
        tags: ['HARSH', 'RUBBERY'],
        prompt: 'Your espresso still tastes off. What would you try first?',
        scenario: 'Grind’s dialled in and the beans are fresh.',
        choices: [
          { t: 'Switch to a 100% Arabica bean', correct: true },
          { t: 'Add more coffee' },
          { t: 'Use hotter water' },
          { t: 'Stir in sugar' },
        ],
        explain: 'A harsh, rubbery edge often comes from a Robusta-heavy blend. Trying a 100% Arabica bean is the cleanest first move — no dial-in can fully remove it.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A café menu says the house espresso is an 80/20 Arabica–Robusta blend. What should you expect?',
        choices: [
          { t: 'Heavier body, more bitterness, thicker crema', correct: true },
          { t: 'Brighter acidity and delicate florals' },
          { t: 'Less caffeine than a 100% Arabica shot' },
        ],
        explain: 'The Robusta fifth is doing exactly what it’s there for — body, crema and punch, at the cost of brightness. And more caffeine, not less.',
        line: 'Arabica for nuance. Robusta for power.' },
    ],
    reward: {
      title: 'Arabica',
      summary: 'The species behind most specialty coffee. Sweet, nuanced, fragile.',
      fact: 'Every arabica plant traces back to a small founding population in Ethiopia — the genetic diversity is unusually narrow.',
      meta: [
        ['SPECIES', 'Coffea arabica'],
        ['SHARE',   '~60% world'],
        ['CAFFEINE','~1.2%'],
      ],
    },
  },

  m1l3: {
    moduleLabel: 'MODULE 1 · BEANS',
    title: 'What origin means',
    xp: 10, time: 4,
    cards: [
      { kind: 'predict', label: 'LESSON 3', title: 'What origin means',
        body: 'Two bags of the same variety can taste worlds apart. Before we explain why — one guess.',
        question: 'Same variety, same roast, two different mountains. What decides the difference?',
        options: ['Where it grew', 'How dark it was roasted'],
        a: 'Where it grew',
        hold: 'Keep that. The answer lands before the end of the lesson.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Origin is a place',
        fill: ['Origin can be as broad as a ', { a: 'country', o: ['country', 'continent'], label: 'Broadest' }, ' or as narrow as a single ', { a: 'farm', o: ['farm', 'shelf'], label: 'Narrowest' }, '.'],
        paragraphs: [
          'Origin is where a coffee was grown — and it gets specific. It can mean a country, a region within it, or a single farm or washing station.',
          'The more precisely a bag names its origin, the more the roaster is telling you they know exactly where it came from.',
        ],
        meta: [['BROADEST', 'Country'], ['NARROWEST', 'Single farm']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Why altitude matters',
        fill: ['Higher, cooler slopes ripen cherries ', { a: 'slowly', o: ['slowly', 'quickly'], label: 'Ripening' }, ', building ', { a: 'brighter', o: ['brighter', 'duller'], label: 'In the cup' }, ', more complex cups.'],
        paragraphs: [
          'High, cool slopes make cherries ripen slowly. Slow ripening builds denser seeds with more sugar and acidity — brighter, more complex cups.',
          'Lower, warmer ground ripens fast: softer, heavier, less lively. Same species, different mountain, different cup.',
        ],
        meta: [['HIGHER', 'Brighter, complex'], ['LOWER', 'Softer, heavier']],
      },
      { kind: 'mcq',
        prompt: 'Why can the same variety taste different from two countries?',
        choices: [
          { t: 'The place it grew — soil, altitude, climate', correct: true },
          { t: 'One is arabica, one is robusta' },
          { t: 'The bag colour' },
          { t: 'Nothing — it tastes the same' },
        ],
        explain: 'Terroir — soil, altitude and climate — shapes the cup even when the variety is identical.',
      },
      { kind: 'multi',
        prompt: 'Which of these are part of a coffee\u2019s origin? Select all that apply.',
        choices: [
          { t: 'Country it was grown in', correct: true },
          { t: 'Region or farm', correct: true },
          { t: 'Altitude it grew at', correct: true },
          { t: 'How dark it was roasted' },
          { t: 'How you brewed it' },
        ],
        explain: 'Origin is about place: country, region, farm and altitude. Roast and brew happen later, far from the farm.',
      },
      { kind: 'match',
        prompt: 'Match each origin to its classic flavour signature.',
        pairs: [
          { l: 'Ethiopia',  r: 'Floral, citrus' },
          { l: 'Colombia',  r: 'Balanced, caramel' },
          { l: 'Sumatra',   r: 'Earthy, herbal' },
          { l: 'Kenya',     r: 'Blackcurrant, bright' },
        ],
      },
      { kind: 'sequence',
        prompt: 'Order these from broadest to most specific.',
        items: [
          { label: 'Country',      order: 1 },
          { label: 'Region',       order: 2 },
          { label: 'Single farm',  order: 3 },
        ],
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Use origin, don’t obsess over it',
        scenario: 'You’re buying beans for tomorrow’s pour-over. One bag names a famous Ethiopian farm but was roasted four months ago. The other just says “Colombia” — roasted last week.',
        question: 'Which bag makes the better cup tomorrow?',
        options: [
          { t: 'Colombia, roasted last week', sub: 'Broad origin · fresh', correct: true },
          { t: 'The single Ethiopian farm', sub: 'Famous origin · 4 months old' },
        ],
        right: 'Origin is a useful hint, but freshness decides whether the cup is actually good. A modest coffee roasted last week wins easily.',
        wrong: 'A famous farm on a four-month-old bag is a faded coffee. Origin shapes flavour; it can’t replace freshness.',
        note: 'Origin shapes flavour, but freshness and brewing decide whether your cup is actually good.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A bag names the country, the region and a single washing station. What is that telling you?',
        choices: [
          { t: 'The roaster knows exactly where it came from', correct: true },
          { t: 'It will definitely taste better than any other bag' },
          { t: 'It was roasted more recently than vaguer bags' },
        ],
        explain: 'Precision about origin is a traceability claim, not a quality guarantee — and it says nothing at all about freshness.',
        line: 'Origin is place. And place is what you taste.' },
    ],
    reward: {
      title: 'The Bean Belt',
      summary: 'The equatorial band where coffee grows — and why place ends up in the cup.',
      fact: 'The same variety planted in two countries can taste completely different. Origin does the talking.',
      meta: [
        ['LATITUDE',    '25\u00B0N \u2013 25\u00B0S'],
        ['SHAPED BY',   'Soil, altitude, climate'],
        ['GRANULARITY', 'Country \u2192 farm'],
      ],
    },
  },

  m2l1: {
    moduleLabel: 'MODULE 2 · PROCESSING',
    title: 'Washed, natural, honey',
    xp: 10, time: 4,
    cards: [
      { kind: 'predict', label: 'LESSON 1', title: 'Washed, natural, honey',
        body: 'Once a cherry is picked, someone has to get the seed out of the fruit. That’s processing — and one guess before we start.',
        question: 'Which process tends to give the fruitiest cup?',
        options: ['Washed', 'Natural'],
        a: 'Natural',
        hold: 'Sealed. You’ll see whether that holds up in a couple of minutes.' },
      { kind: 'concept', label: 'CONCEPT', title: 'The job of processing',
        fill: ['Processing removes the ', { a: 'fruit', o: ['fruit', 'roast'], label: 'Removes' }, ' and dries the ', { a: 'seed', o: ['seed', 'leaf'], label: 'Keeps' }, ' \u2014 a flavour decision, not just a chore.'],
        paragraphs: [
          'Inside every cherry, the seed is wrapped in sweet, sticky pulp. Processing is simply how a farm removes that fruit and dries the seed for storage and shipping.',
          'But the pulp doesn\u2019t leave quietly. How long it stays in contact with the seed while drying steers the final flavour \u2014 so processing is a flavour decision, not just a chore.',
        ],
        meta: [['STARTS WITH', 'Ripe cherry'], ['ENDS WITH', 'Dry green seed']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Three ways to do it',
        fill: ['The ', { a: 'washed', o: ['washed', 'natural'], label: 'Cleanest' }, ' process tastes cleanest and brightest; the ', { a: 'natural', o: ['natural', 'washed'], label: 'Fruitiest' }, ' process tastes fruitiest.'],
        paragraphs: [
          'Washed removes the fruit first, then dries the clean seed \u2014 clean, bright, origin-forward. Natural dries the whole cherry intact \u2014 fruity, heavy, sweet.',
          'Honey sits between them: some sticky pulp is left on during drying, for body and rounded sweetness without going full fruit-bomb.',
        ],
        meta: [['CLEANEST', 'Washed'], ['FRUITIEST', 'Natural']],
      },
      { kind: 'match',
        prompt: 'Match each method to how it treats the fruit.',
        pairs: [
          { l: 'Washed',  r: 'Fruit removed first' },
          { l: 'Natural', r: 'Dried whole in the cherry' },
          { l: 'Honey',   r: 'Some pulp left on' },
        ],
      },
      { kind: 'mcq',
        prompt: 'Which method usually gives the cleanest, brightest cup?',
        choices: [
          { t: 'Natural' },
          { t: 'Washed', correct: true },
          { t: 'Honey' },
          { t: 'None \u2014 process doesn\u2019t affect taste' },
        ],
        explain: 'Removing the fruit before drying lets the origin\u2019s own acidity and clarity come through.',
      },
      { kind: 'multi',
        prompt: 'Which of these are true of natural processing? Select all that apply.',
        choices: [
          { t: 'The cherry dries whole', correct: true },
          { t: 'Tends to taste fruity and sweet', correct: true },
          { t: 'Fruit is stripped off first' },
          { t: 'Often heavier in body', correct: true },
          { t: 'Always the cheapest method' },
        ],
        explain: 'Natural means drying the intact cherry \u2014 fruity, sweet and full-bodied. Stripping the fruit first is the washed method.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Where those “funky” notes come from',
        scenario: 'A friend tells you they don’t like “weird, fermented-tasting” coffee. You’re buying a bag to brew for them.',
        question: 'Which process line do you look for?',
        options: [
          { t: 'Washed', sub: 'Ethiopia · lemon, tea', correct: true },
          { t: 'Natural', sub: 'Ethiopia · blueberry, jam' },
        ],
        right: 'Washed strips the fruit before drying, so there’s little sugar left to ferment. Clean and bright is exactly the safe bet here.',
        wrong: 'Natural dries the whole cherry — that long fruit contact is precisely where the winey, fermented character comes from.',
        note: 'Fruity or fermented notes usually come from processing, not from added flavouring.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A bag reads “honey process.” What should you expect in the cup?',
        choices: [
          { t: 'Rounded sweetness and body — between clean and fruity', correct: true },
          { t: 'Actual honey added to the beans' },
          { t: 'The cleanest, brightest cup of the three' },
        ],
        explain: 'Honey leaves some sticky pulp on during drying: body and rounded sweetness without going full fruit bomb. Nothing is added to the beans.',
        line: 'Washed for clarity. Natural for fruit. Honey splits the difference.' },
    ],
    reward: {
      title: 'The Drying Bed',
      summary: 'Where the choice gets made \u2014 fruit on, fruit off, or somewhere between.',
      fact: 'On a raised bed, cherries are turned by hand every few hours so they dry evenly and never ferment too far.',
      meta: [
        ['METHODS',  'Washed / natural / honey'],
        ['CONTROLS', 'Fruit contact time'],
        ['DECIDES',  'Clarity vs fruit'],
      ],
    },
  },

  m2l2: {
    moduleLabel: 'MODULE 2 · PROCESSING',
    title: 'Why processing matters',
    xp: 10, time: 4,
    cards: [
      { kind: 'predict', label: 'LESSON 2', title: 'Why processing matters',
        body: 'The same bean, from the same farm, can land in your cup as two completely different coffees. One guess why.',
        question: 'Which usually changes a coffee more — the roast, or the processing?',
        options: ['The roast', 'The processing'],
        a: 'The processing',
        hold: 'Noted. We’ll settle it with two bags from one farm.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Sugar meets time',
        fill: ['More fruit contact means ', { a: 'more', o: ['more', 'less'], label: 'Fermented flavour' }, ' fruity, fermented flavour; less contact keeps the cup ', { a: 'cleaner', o: ['cleaner', 'sweeter'], label: 'Less contact' }, '.'],
        paragraphs: [
          'While a seed dries, natural sugars and microbes in the leftover fruit slowly ferment. That fermentation is where fruity, boozy, wine-like notes are born.',
          'More fruit contact and more time means more of those flavours. Less contact keeps things clean and lets the origin speak for itself.',
        ],
        meta: [['MORE FRUIT', 'More ferment'], ['LESS FRUIT', 'More clarity']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'It can outweigh origin',
        fill: ['Washed coffees lean toward ', { a: 'lemon', o: ['lemon', 'berry'], label: 'Washed' }, ' and tea; naturals lean toward ', { a: 'berry', o: ['berry', 'lemon'], label: 'Natural' }, ' and jam.'],
        paragraphs: [
          'A natural Ethiopian and a washed Ethiopian share a farm and a variety \u2014 yet one tastes of blueberry jam and the other of lemon and tea.',
          'That\u2019s why two bags with identical origin lines can taste worlds apart. Sometimes processing does more talking than the mountain did.',
        ],
        meta: [['WASHED', 'Lemon, tea, clean'], ['NATURAL', 'Berry, jam, sweet']],
      },
      { kind: 'slider',
        prompt: 'More fruit contact during drying pushes flavour toward\u2026',
        leftLabel: 'CLEANER', rightLabel: 'FRUITIER',
        target: 78, tolerance: 15,
        scale: [
          'Crisp and clean \u2014 fully washed',
          'Bright with a little body',
          'Rounded, sweet \u2014 honey',
          'Juicy and jammy',
          'Wild, boozy \u2014 long natural',
        ],
        feedback: 'The longer the fruit stays on, the fruitier and heavier the cup gets.',
      },
      { kind: 'mcq',
        prompt: 'Two bags say \u201CEthiopia, Yirgacheffe.\u201D Why might they taste so different?',
        choices: [
          { t: 'One is fake' },
          { t: 'Different processing methods', correct: true },
          { t: 'Different roast dates only' },
          { t: 'They can\u2019t \u2014 origin fixes the taste' },
        ],
        explain: 'Same origin, different processing. Fermentation during drying can reshape the cup entirely.',
      },
      { kind: 'sequence',
        prompt: 'Order these by fruitiness, cleanest to most fruit-forward.',
        items: [
          { label: 'Washed',  order: 1 },
          { label: 'Honey',   order: 2 },
          { label: 'Natural', order: 3 },
        ],
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'What this means when you shop',
        scenario: 'You want a bright, clean, tea-like cup for your morning filter. Two Ethiopians sit on the shelf — same farm, same roast level.',
        question: 'Which do you buy?',
        options: [
          { t: 'Washed', sub: 'Same farm · lemon, tea', correct: true },
          { t: 'Natural', sub: 'Same farm · blueberry, jam' },
        ],
        right: 'Short fruit contact keeps fermentation low, so clarity and acidity come through. That’s the cup you asked for.',
        wrong: 'The natural will be sweet and jammy — a fine coffee, just not a clean, tea-like one. And no grind change will brew the fruit back out.',
        note: 'Pick the process to match the cup you want — you can’t brew fruitiness into a clean washed coffee.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Two bags both read “Ethiopia · Yirgacheffe,” yet one tastes of blueberry jam and the other of lemon and tea. What most likely differs?',
        choices: [
          { t: 'The processing method', correct: true },
          { t: 'One of the bags is mislabelled' },
          { t: 'Only the roast date' },
        ],
        explain: 'Fermentation during drying can reshape a cup entirely — sometimes doing more talking than the mountain did.',
        line: 'Processing can change a coffee more than the roast ever will.' },
    ],
    reward: {
      title: 'Fermentation',
      summary: 'The quiet chemistry that turns leftover fruit sugar into flavour.',
      fact: 'A few extra hours of fermentation can be the difference between clean citrus and full-on blueberry.',
      meta: [
        ['DRIVEN BY', 'Sugar + microbes + time'],
        ['MORE OF IT', 'Fruit, funk, body'],
        ['CAN BEAT',  'Origin itself'],
      ],
    },
  },

  m2l3: {
    moduleLabel: 'MODULE 2 · PROCESSING',
    title: 'Reading a bag label',
    xp: 10, time: 3,
    cards: [
      { kind: 'predict', label: 'LESSON 3', title: 'Reading a bag label',
        body: 'You now know enough to decode a bag of specialty coffee before you buy it. One guess first.',
        question: 'The notes on a bag — “blueberry, cocoa” — are…',
        options: ['Flavours the roaster added', 'What the roaster tasted'],
        a: 'What the roaster tasted',
        hold: 'Hold it there. The label is about to tell on itself.' },
      { kind: 'concept', label: 'CONCEPT', title: 'What the label tells you',
        fill: ['A good bag names the origin, variety, process and a ', { a: 'roast', o: ['roast', 'harvest'], label: 'The date to check' }, ' date \u2014 each line a promise the roaster can back up.'],
        paragraphs: [
          'A good bag names the origin (country, region, sometimes farm), the variety, the process, and a roast date. Each line is a promise the roaster can back up.',
          'The process line is the one you just learned to read \u2014 \u201Cwashed,\u201D \u201Cnatural,\u201D or \u201Choney\u201D tells you roughly how the cup will taste before you brew it.',
        ],
        meta: [['LOOK FOR', 'Origin \u00B7 variety \u00B7 process'], ['ALSO', 'Roast date']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Tasting notes are a forecast',
        fill: ['Jammy, fruity notes usually mean ', { a: 'natural', o: ['natural', 'washed'], label: 'Berry / jam' }, '; clean, citrus notes usually mean ', { a: 'washed', o: ['washed', 'natural'], label: 'Citrus / floral' }, '.'],
        paragraphs: [
          'The \u201Cnotes\u201D on a bag \u2014 \u201Cblueberry, cocoa, syrupy\u201D \u2014 aren\u2019t added flavours. They\u2019re what the roaster tasted, and a hint at the processing behind it.',
          'Fruity, jammy notes usually mean natural. Clean, citrusy, floral notes usually mean washed. The label is telling on itself.',
        ],
        meta: [['BERRY/JAM', 'Likely natural'], ['CITRUS/FLORAL', 'Likely washed']],
      },
      { kind: 'match',
        prompt: 'Match each label clue to what it most likely means.',
        pairs: [
          { l: '\u201CNatural\u201D',          r: 'Fruity, sweet cup' },
          { l: '\u201CWashed\u201D',           r: 'Clean, bright cup' },
          { l: 'Recent roast date',   r: 'Fresh, at its best' },
          { l: 'Single farm named',   r: 'Very specific origin' },
        ],
      },
      { kind: 'multi',
        prompt: 'Which lines actually help you predict the taste? Select all that apply.',
        choices: [
          { t: 'Process (washed / natural / honey)', correct: true },
          { t: 'Origin and altitude', correct: true },
          { t: 'Tasting notes', correct: true },
          { t: 'The bag\u2019s colour' },
          { t: 'The price sticker' },
        ],
        explain: 'Process, origin and tasting notes all forecast the cup. Bag colour and price don\u2019t.',
      },
      { kind: 'mcq',
        prompt: 'A bag reads \u201CEthiopia \u00B7 Natural \u00B7 blueberry, cocoa.\u201D Expect\u2026',
        choices: [
          { t: 'A clean, lemony, tea-like cup' },
          { t: 'A fruity, sweet, jam-like cup', correct: true },
          { t: 'No flavour at all' },
          { t: 'A savoury, salty cup' },
        ],
        explain: 'Natural process plus berry notes points straight at a sweet, fruit-forward cup.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Read the label like a forecast',
        scenario: 'You want something sweet and fruity for a slow weekend brew. Two bags, both roasted last week.',
        question: 'Which label matches what you want?',
        options: [
          { t: 'Ethiopia · Natural', sub: 'blueberry, cocoa, syrupy', correct: true },
          { t: 'Kenya · Washed', sub: 'blackcurrant, lemon, tea' },
        ],
        right: 'Natural process plus berry-and-cocoa notes forecasts exactly the sweet, jammy cup you’re after.',
        wrong: 'That’s a lovely bag, but washed plus lemon-and-tea notes points at a clean, bright cup — not a sweet, fruity one.',
        note: 'A recent roast date plus a process you recognise is a better buy than a famous origin on a stale bag.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A bag says only “Blend · Dark Roast · best by June 2027.” What does that label tell you?',
        choices: [
          { t: 'Very little — no origin, no process, no roast date', correct: true },
          { t: 'That it was roasted recently' },
          { t: 'That it will taste fruity and sweet' },
        ],
        explain: 'All four useful lines are missing, and a far-off best-by usually hides how long the bag has already been sitting.',
        line: 'A label is a forecast. You can now read it.' },
    ],
    reward: {
      title: 'Field Guide \u00B7 The Label',
      summary: 'Origin, variety, process, roast date \u2014 four lines that predict your cup.',
      fact: 'Read enough labels and you\u2019ll guess the taste before the first sip more often than not.',
      meta: [
        ['READS', 'Origin \u00B7 variety \u00B7 process'],
        ['FORECASTS', 'Clarity vs fruit'],
        ['SKILL',  'Buy with intent'],
      ],
    },
  },

  // ── Roasting (Module 3) ──
  m3l1: {
    moduleLabel: 'MODULE 3 \u00b7 ROASTING',
    title: 'Light, medium, dark',
    xp: 10, time: 4,
    cards: [
      { kind: 'predict', label: 'LESSON 1', title: 'Light, medium, dark',
        body: 'Green coffee tastes of almost nothing. Roasting is the heat that makes it drinkable — one guess before we start.',
        question: 'Which roast tastes more like the place the coffee grew?',
        options: ['Light', 'Dark'],
        a: 'Light',
        hold: 'Sealed. Watch what the heat trades away.' },
      { kind: 'concept', label: 'CONCEPT', title: 'How far the roast goes',
        fill: ['A lighter roast keeps more ', { a: 'acidity', o: ['acidity', 'bitterness'], label: 'Lighter' }, ' and origin character; a darker roast brings more ', { a: 'body', o: ['body', 'brightness'], label: 'Darker' }, ' and roast flavour.'],
        paragraphs: [
          'Roast level is simply how long and how hot the beans are cooked. A light roast stops early, keeping the bean\u2019s original acidity and fruit. A dark roast goes further, trading that brightness for body, bitterness and smoky, roasty flavour.',
          'Medium sits in between \u2014 balanced and sweet, which is why it\u2019s the easiest place for a beginner to start.',
        ],
        meta: [['LIGHT', 'Bright \u00b7 acidic'], ['DARK', 'Bitter \u00b7 smoky']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'Light to dark', variant: 'roast',
        caption: 'The further the roast goes, the more the bean tastes of roast \u2014 and the less of where it grew.' },
      { kind: 'match',
        prompt: 'Match each roast level to how it tends to taste.',
        pairs: [
          { l: 'Light',  r: 'Bright, fruity, acidic' },
          { l: 'Medium', r: 'Balanced, sweet' },
          { l: 'Dark',   r: 'Bitter, smoky, bold' },
        ],
      },
      { kind: 'mcq',
        prompt: 'Which roast keeps the most of a coffee\u2019s original origin character?',
        choices: [
          { t: 'Dark' },
          { t: 'Light', correct: true },
          { t: 'The roast doesn\u2019t affect it' },
          { t: 'Only espresso roast' },
        ],
        explain: 'A lighter roast stops before roast flavour takes over, so more of the bean\u2019s own acidity and fruit survive.',
      },
      { kind: 'multi',
        prompt: 'Which of these are true of a dark roast? Select all that apply.',
        choices: [
          { t: 'More bitter, smoky flavour', correct: true },
          { t: 'Less bright acidity', correct: true },
          { t: 'Tastes more of where it grew' },
          { t: 'Fuller, heavier body', correct: true },
          { t: 'Always has more caffeine' },
        ],
        explain: 'Darker roasts trade origin acidity for body and roast flavour. Caffeine barely changes with roast level.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Start at medium, then lean',
        scenario: 'A friend is buying their first bag of specialty coffee and has no idea yet what they like.',
        question: 'What do you tell them to buy?',
        options: [
          { t: 'A medium roast', sub: 'Balanced · forgiving to brew', correct: true },
          { t: 'The lightest roast on the shelf', sub: 'Bright · unforgiving' },
        ],
        right: 'Medium is sweet and balanced, and forgiving if the grind or ratio is a little off — the easiest place to learn what you like.',
        wrong: 'Light roasts can be gorgeous, but they’re the fussiest to brew. Easy to make sour and thin on a first attempt.',
        note: 'Not sure what you like? Buy a medium roast first, then lean lighter or darker from there.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Someone says they switched to dark roast for the caffeine kick. What’s the accurate correction?',
        choices: [
          { t: 'Roast level barely changes caffeine — it trades acidity for body', correct: true },
          { t: 'Dark roast has far less caffeine' },
          { t: 'They’re right — dark roast is much stronger in caffeine' },
        ],
        explain: 'Roast level mostly moves flavour, not caffeine. What actually changes is how much origin acidity survives.',
        line: 'Light for brightness, dark for boldness, medium to begin.' },
    ],
    reward: {
      title: 'The Roast Spectrum',
      summary: 'Light to dark \u2014 how far the heat goes, and what it trades away.',
      fact: 'Roast level barely changes caffeine \u2014 it mostly trades origin acidity for roast flavour.',
      meta: [
        ['LIGHT',  'Bright \u00b7 acidic'],
        ['MEDIUM', 'Balanced \u00b7 sweet'],
        ['DARK',   'Bitter \u00b7 bold'],
      ],
    },
  },

  m3l2: {
    moduleLabel: 'MODULE 3 \u00b7 ROASTING',
    title: 'First and second crack',
    xp: 10, time: 5,
    cards: [
      { kind: 'predict', label: 'LESSON 2', title: 'First and second crack',
        body: 'Roasters don’t just watch a clock. Coffee tells them how far it has roasted — one guess how.',
        question: 'How does a roaster know when to stop?',
        options: ['They listen for it', 'They weigh the beans'],
        a: 'They listen for it',
        hold: 'Keep that. In a minute you’ll know what they’re listening for.' },
      { kind: 'concept', label: 'CONCEPT', title: 'The beans crack twice',
        fill: ['First crack marks the start of a drinkable ', { a: 'light', o: ['light', 'dark'], label: 'First crack' }, ' roast; pushing on to second crack takes it into ', { a: 'dark', o: ['dark', 'light'], label: 'Second crack' }, ' roast territory.'],
        paragraphs: [
          'As beans heat, moisture inside turns to steam and pressure builds until they pop \u2014 an audible \u201Cfirst crack,\u201D like faint popcorn. That\u2019s the earliest a roast is drinkable: light roasts are pulled here.',
          'Keep going and oils and gases build again into a sharper \u201Csecond crack.\u201D Pull between the two for medium; into or past second crack for dark.',
        ],
        meta: [['FIRST CRACK', 'Light roast'], ['SECOND CRACK', 'Dark roast']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Heat and time, together',
        fill: ['Roasting drives ', { a: 'out', o: ['out', 'in'], label: 'Moisture' }, ' moisture and browns the bean\u2019s ', { a: 'sugars', o: ['sugars', 'water'], label: 'Flavour from' }, ' into the flavours we taste.'],
        paragraphs: [
          'The heat drives water out of the bean and browns its sugars \u2014 the same reaction that browns toast or seared food. That browning is where most roast flavour comes from.',
          'Too fast and the outside scorches before the inside develops; too slow and it bakes flat. Good roasting is heat and time balanced.',
        ],
        meta: [['DRIVES OUT', 'Moisture'], ['DEVELOPS', 'Sugars \u2192 flavour']],
      },
      { kind: 'sequence',
        prompt: 'Order these roasting stages from start to finish.',
        items: [
          { label: 'Green bean', order: 1 },
          { label: 'First crack', order: 2 },
          { label: 'Second crack', order: 3 },
        ],
      },
      { kind: 'mcq',
        prompt: 'A roaster pulls the beans just after first crack. That\u2019s likely a\u2026',
        choices: [
          { t: 'Light roast', correct: true },
          { t: 'Very dark roast' },
          { t: 'Burnt batch' },
          { t: 'Green, unroasted bean' },
        ],
        explain: 'First crack is the earliest a roast is drinkable \u2014 stopping just after it gives a light roast.',
      },
      { kind: 'decision', label: 'AT THE ROASTER', title: 'Why this shows up in your cup',
        scenario: 'Two bags of the exact same green coffee. One roaster pulled just after first crack; the other pushed into second crack. You want the fruit and acidity of the origin.',
        question: 'Which bag do you buy?',
        options: [
          { t: 'Pulled just after first crack', sub: 'Light roast', correct: true },
          { t: 'Pushed into second crack', sub: 'Dark roast' },
        ],
        right: 'Stopping early keeps the bean’s own acidity and fruit intact — the origin is still doing the talking.',
        wrong: 'Past second crack, roast flavour takes over: more body and bitterness, far less of the mountain it grew on.',
        note: 'Roast level is really just where the roaster stopped between the two cracks.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A roaster says they pull this coffee “between the cracks.” That’s a…',
        choices: [
          { t: 'Medium roast', correct: true },
          { t: 'Light roast' },
          { t: 'Very dark, oily roast' },
        ],
        explain: 'First crack is where a roast becomes drinkable and second crack begins dark territory. Between the two is medium.',
        line: 'Two cracks mark the map from light to dark.' },
    ],
    reward: {
      title: 'First & Second Crack',
      summary: 'The two sounds that tell a roaster how far a roast has gone.',
      fact: 'First crack sounds like faint popcorn; second crack is sharper, like crackling.',
      meta: [
        ['FIRST',   'Light roast begins'],
        ['SECOND',  'Dark roast begins'],
        ['BETWEEN', 'Medium'],
      ],
    },
  },

  m3l3: {
    moduleLabel: 'MODULE 3 \u00b7 ROASTING',
    title: 'Reading a roast date',
    xp: 10, time: 3,
    cards: [
      { kind: 'predict', label: 'LESSON 3', title: 'Reading a roast date',
        body: 'Coffee is fresh food, and freshness has a window. One guess before we open it.',
        question: 'When is coffee at its best?',
        options: ['The day it’s roasted', 'A few days to a few weeks after'],
        a: 'A few days to a few weeks after',
        hold: 'Sealed. There’s a reason it isn’t day one.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Fresh, but not too fresh',
        fill: ['Coffee is usually best from about ', { a: 'a few days', o: ['a few days', 'a few months'], label: 'From' }, ' to a few ', { a: 'weeks', o: ['weeks', 'years'], label: 'Until' }, ' after roasting.'],
        paragraphs: [
          'Right after roasting, beans release carbon dioxide \u2014 a few days\u2019 rest lets that settle so the coffee brews evenly. From there it\u2019s at its best for roughly a month.',
          'Past that it doesn\u2019t spoil, but the aromatics fade and the cup goes flat and dull. Fresh matters more than famous.',
        ],
        meta: [['REST', 'A few days'], ['BEST BY', '~4 weeks'], ['THEN', 'Flat, dull']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Roast date beats \u201Cbest by\u201D',
        fill: ['A ', { a: 'roast', o: ['roast', 'best-by'], label: 'The useful date' }, ' date tells you when the coffee was made; a ', { a: 'best-by', o: ['best-by', 'roast'], label: 'The vague one' }, ' date can be a year away and tells you little.'],
        paragraphs: [
          'A printed roast date is a sign of a roaster who cares \u2014 you can work out exactly how fresh the bag is. A far-off \u201Cbest by\u201D date usually hides how long it\u2019s already been sitting.',
          'If a bag shows no roast date at all, assume it\u2019s been on the shelf a while.',
        ],
        meta: [['ROAST DATE', 'When it was made'], ['BEST-BY', 'Tells you little']],
      },
      { kind: 'mcq',
        prompt: 'You find two bags. Which is the better bet?',
        choices: [
          { t: 'Roasted 5 days ago', correct: true },
          { t: '\u201CBest by\u201D in 9 months, no roast date' },
          { t: 'Roasted 4 months ago' },
          { t: 'Whichever is darker' },
        ],
        explain: 'A recent roast date beats a vague best-by every time \u2014 five days\u2019 rest is right in the sweet spot.',
      },
      { kind: 'multi',
        prompt: 'Which are good signs of a fresh, well-labelled bag? Select all that apply.',
        choices: [
          { t: 'A clear roast date', correct: true },
          { t: 'Roasted within the last few weeks', correct: true },
          { t: 'Only a far-off \u201Cbest by\u201D date' },
          { t: 'A one-way valve on the bag', correct: true },
          { t: 'No date anywhere' },
        ],
        explain: 'A printed roast date, recent roasting and a degassing valve all point to fresh coffee. A lone best-by date or no date do not.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'What to do at the shelf',
        scenario: 'You drink about one 250g bag a month. There’s a deal on: three bags of a coffee roasted two days ago, for the price of two.',
        question: 'Do you take the deal?',
        options: [
          { t: 'Buy one bag', sub: 'Finish it inside the window', correct: true },
          { t: 'Buy all three', sub: 'Two will sit for months' },
        ],
        right: 'Buy what you’ll finish in about a month. The third bag would be flat and dull long before you reached it.',
        wrong: 'It’s a good price on coffee that will go stale on your shelf. The saving disappears into a dull cup.',
        note: 'Buy what you\u2019ll finish in about a month \u2014 fresh coffee you\u2019ll drink beats a hoard that goes stale.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A bag has no roast date — just “best by” in nine months. What’s the safe assumption?',
        choices: [
          { t: 'It has already been sitting a while', correct: true },
          { t: 'It was roasted in the last few days' },
          { t: 'It will stay at its best for nine months' },
        ],
        explain: 'A far-off best-by hides how long the bag has been around. Coffee doesn’t spoil, but aromatics fade in weeks, not months.',
        line: 'Find the roast date. Fresh beats famous.' },
    ],
    reward: {
      title: 'The Roast Date',
      summary: 'The one number that tells you whether a bag is worth buying.',
      fact: 'Most coffee is at its best from a few days to about a month after roasting.',
      meta: [
        ['LOOK FOR',   'A roast date'],
        ['SWEET SPOT', '~4 weeks'],
        ['BUY',        'A month\u2019s worth'],
      ],
    },
  },

  // ── Grind (Module 4) — practical intensity: very high ──
  m4l1: {
    moduleLabel: 'MODULE 4 \u00b7 GRIND',
    title: 'Particle size, in plain English',
    xp: 10, time: 4,
    cards: [
      { kind: 'predict', label: 'LESSON 1', title: 'Particle size, in plain English',
        body: 'Grinding isn’t just about making beans small enough to brew. The size of the pieces quietly controls the cup — one guess how.',
        question: 'Grind the same beans finer. The flavour comes out…',
        options: ['Faster', 'Slower'],
        a: 'Faster',
        hold: 'Hold that. It’s the whole idea behind grind size.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Smaller means more surface',
        fill: ['Smaller particles expose ', { a: 'more', o: ['more', 'less'], label: 'Surface area' }, ' surface to the water, so they give up their flavour ', { a: 'faster', o: ['faster', 'slower'], label: 'Extraction' }, '.'],
        paragraphs: [
          'Water can only pull flavour from the surface of a coffee particle. Grind the same bean finer and you create far more surface area, so extraction happens faster.',
          'That\u2019s the whole idea behind grind size: it\u2019s a speed dial for how quickly water gets the flavour out.',
        ],
        meta: [['FINER', 'More surface \u00b7 faster'], ['COARSER', 'Less surface \u00b7 slower']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'Coarse to fine', variant: 'grind',
        caption: 'Each brewer has a grind range that lets water move through at the right speed.' },
      { kind: 'match',
        prompt: 'Match each brewer to the grind it usually wants.',
        pairs: [
          { l: 'French press', r: 'Coarse' },
          { l: 'Pour-over',    r: 'Medium' },
          { l: 'Espresso',     r: 'Fine' },
        ],
      },
      { kind: 'mcq',
        prompt: 'Why does a finer grind extract faster?',
        choices: [
          { t: 'It exposes more surface area to the water', correct: true },
          { t: 'It contains more caffeine' },
          { t: 'It makes the water hotter' },
          { t: 'It has nothing to do with speed' },
        ],
        explain: 'Finer particles mean more total surface for water to work on, so flavour comes out faster.',
      },
      { kind: 'decision', label: 'IN THE KITCHEN', title: 'Match the grind to the brewer first',
        scenario: 'You’ve just bought a French press, and your grinder is still set where it was for espresso. The first cup is bitter and muddy.',
        question: 'What do you change first?',
        options: [
          { t: 'Grind much coarser', sub: 'Into French press range', correct: true },
          { t: 'Nudge it one step coarser', sub: 'Still near espresso' },
        ],
        right: 'An espresso grind in a French press is wildly out of range. Make the big move first, then fine-tune by taste.',
        wrong: 'One step won’t cross the gap between espresso and French press. Get into the right range before you start nudging.',
        note: 'Get the grind into the right range for your brewer before adjusting anything else.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Why does the same dose of coffee, ground finer, extract faster?',
        choices: [
          { t: 'Finer particles expose far more surface to the water', correct: true },
          { t: 'Finer grounds hold more caffeine' },
          { t: 'Finer grounds make the water hotter' },
        ],
        explain: 'Water can only work on the surface of a particle. More surface means flavour comes out faster — that’s the speed dial.',
        line: 'Grind size is a speed dial: finer is faster, coarser is slower.' },
    ],
    reward: {
      title: 'Particle Size',
      summary: 'How coarse or fine you grind \u2014 the speed dial for extraction.',
      fact: 'Halving particle size roughly doubles the surface water can reach.',
      meta: [
        ['FINER',   'More surface \u00b7 faster'],
        ['COARSER', 'Less surface \u00b7 slower'],
        ['SET BY',  'Your brewer'],
      ],
    },
  },

  m4l2: {
    moduleLabel: 'MODULE 4 \u00b7 GRIND',
    title: 'Burr vs blade',
    xp: 10, time: 4,
    cards: [
      { kind: 'predict', label: 'LESSON 2', title: 'Burr vs blade',
        body: 'Some gear matters far more than the rest. One guess before we get into why.',
        question: 'Which single upgrade improves a beginner’s coffee most?',
        options: ['A better brewer', 'A burr grinder'],
        a: 'A burr grinder',
        hold: 'Sealed. The reason is evenness, and it’s about to make sense.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Even beats uneven',
        fill: ['A burr grinder crushes beans into ', { a: 'even', o: ['even', 'uneven'], label: 'Burr' }, ' particles; a blade grinder chops them into ', { a: 'uneven', o: ['uneven', 'even'], label: 'Blade' }, ' ones.'],
        paragraphs: [
          'Burr grinders crush beans between two ridged surfaces set a fixed distance apart, so every particle comes out roughly the same size. Blade grinders just chop with a spinning blade, leaving a mix of dust and boulders.',
          'That evenness is the whole point \u2014 it\u2019s why burr grinders are worth the upgrade.',
        ],
        meta: [['BURR', 'Even particles'], ['BLADE', 'Uneven particles']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Why evenness matters',
        fill: ['Uneven grounds extract ', { a: 'unevenly', o: ['unevenly', 'perfectly'], label: 'The problem' }, ', so one cup can taste ', { a: 'sour and bitter', o: ['sour and bitter', 'clean and sweet'], label: 'The result' }, ' at once.'],
        paragraphs: [
          'When particles are all different sizes, the small ones over-extract while the big ones under-extract \u2014 in the very same brew. You get sourness and bitterness together, and no single fix helps.',
          'Even grounds extract at one rate, so you can actually dial the cup in.',
        ],
        meta: [['UNEVEN', 'Sour + bitter at once'], ['EVEN', 'Dial-able']],
      },
      { kind: 'mcq',
        prompt: 'What\u2019s the main advantage of a burr grinder?',
        choices: [
          { t: 'It produces evenly sized particles', correct: true },
          { t: 'It adds flavour to the beans' },
          { t: 'It removes caffeine' },
          { t: 'It grinds without any heat, always' },
        ],
        explain: 'Burrs make uniform particles, which extract evenly \u2014 the foundation of a balanced cup.',
      },
      { kind: 'multi',
        prompt: 'What tends to happen with a blade grinder? Select all that apply.',
        choices: [
          { t: 'A mix of dust and large chunks', correct: true },
          { t: 'Uneven extraction', correct: true },
          { t: 'Perfectly repeatable grind size' },
          { t: 'Harder to dial a cup in', correct: true },
          { t: 'Guaranteed espresso-fine grind' },
        ],
        explain: 'Blades chop unevenly, giving inconsistent particles and extraction that\u2019s hard to control. They can\u2019t reliably hit a target size.',
      },
      { kind: 'decision', label: 'AT THE SHOP', title: 'The upgrade that pays off',
        scenario: 'You have about $80 to spend. Right now you buy pre-ground coffee and make it in a drip machine.',
        question: 'Where does the money go?',
        options: [
          { t: 'A modest burr grinder', sub: 'Even grounds · fresh', correct: true },
          { t: 'A nicer pour-over kit', sub: 'Still pre-ground coffee' },
        ],
        right: 'Fresh, evenly ground coffee is the biggest single step up for most beginners. A brewer can’t fix uneven grounds.',
        wrong: 'Lovely kit, same muddy grounds. Even the best brewer can’t extract evenly from dust and boulders.',
        note: 'A modest burr grinder improves your coffee more than a fancy brewer paired with a blade grinder.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A cup tastes sour and bitter at the same time, and nothing you change fixes it. Most likely cause?',
        choices: [
          { t: 'Uneven grounds — the small bits over-extract while the big ones under-extract', correct: true },
          { t: 'Water that’s too hot' },
          { t: 'Beans that are too fresh' },
        ],
        explain: 'That double fault is the signature of an uneven grind. When particles are all different sizes, no single adjustment can dial the cup in.',
        line: 'Even grounds, even extraction \u2014 that\u2019s what burrs buy you.' },
    ],
    reward: {
      title: 'Burr vs Blade',
      summary: 'Why an even grind \u2014 not a fancy brewer \u2014 is the upgrade that counts.',
      fact: 'Blade grinders make dust and boulders at once; burrs make one even size.',
      meta: [
        ['BURR',  'Even \u00b7 dial-able'],
        ['BLADE', 'Uneven \u00b7 muddy'],
        ['BUY',   'A burr, any size'],
      ],
    },
  },

  m4l3: {
    moduleLabel: 'MODULE 4 \u00b7 GRIND',
    title: 'Dialing in by taste',
    xp: 10, time: 5,
    cards: [
      { kind: 'predict', label: 'LESSON 3', title: 'Dialing in by taste',
        body: 'You don’t need a fancy setup to fix a bad cup. One guess where to start.',
        question: 'Your cup tastes off. What should you reach for first?',
        options: ['The grinder', 'New beans'],
        a: 'The grinder',
        hold: 'Keep that. It’s the dial baristas reach for too.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Grind is your main dial',
        fill: ['Finer grinds extract ', { a: 'faster', o: ['faster', 'slower'], label: 'Finer' }, '; coarser grinds extract ', { a: 'slower', o: ['slower', 'faster'], label: 'Coarser' }, '.'],
        paragraphs: [
          'Grind size decides how fast water pulls flavour out of the coffee. Finer grinds extract faster; coarser grinds extract slower.',
          'That makes grind the single most useful thing to change when a cup tastes off \u2014 more powerful, day to day, than switching beans or water.',
        ],
        meta: [['FINER', 'Extracts faster'], ['COARSER', 'Extracts slower']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'The grind spectrum', variant: 'grind',
        caption: 'Match the grind to the brewer first \u2014 then nudge from there by taste.' },
      { kind: 'decision', label: 'AT THE BREWER', title: 'Change one click at a time',
        scenario: 'Your pour-over is sour. You grind three steps finer, tighten the ratio and raise the water temperature all at once. The next cup is bitter.',
        question: 'What do you do now?',
        options: [
          { t: 'Go back to the original recipe, change grind alone', sub: 'One variable at a time', correct: true },
          { t: 'Keep adjusting all three until it lands', sub: 'Faster, in theory' },
        ],
        right: 'With three variables moving, neither cup taught you anything. Reset, change grind only, and compare.',
        wrong: 'You’ll wander between sour and bitter without ever learning which lever did what. Small steps, one variable.',
        note: 'Adjust grind in small steps and taste after each one. One change, then compare.' },
      { kind: 'tastefix',
        tags: ['SOUR', 'WEAK'],
        prompt: 'Your pour-over came out off. What would you try first?',
        scenario: 'Same beans, same ratio as usual.',
        choices: [
          { t: 'Grind finer', correct: true },
          { t: 'Grind coarser' },
          { t: 'Use less coffee' },
          { t: 'Use cooler water' },
        ],
        explain: 'Sour and weak usually means the water rushed through and under-extracted. A finer grind slows it down and pulls more sweetness out.',
      },
      { kind: 'mcq',
        prompt: 'Finer grind generally makes a cup\u2026',
        choices: [
          { t: 'Extract faster \u2014 stronger, more bitter if overdone', correct: true },
          { t: 'Extract slower \u2014 weaker every time' },
          { t: 'Taste exactly the same' },
          { t: 'Contain far more caffeine' },
        ],
        explain: 'Finer means faster extraction. Helpful when a cup is sour and weak \u2014 but push too far and it turns bitter.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'You grind finer and the cup goes from sour straight to bitter. What does that tell you?',
        choices: [
          { t: 'You overshot — come back part of the way, not all of it', correct: true },
          { t: 'The beans are stale' },
          { t: 'A finer grind always makes coffee bitter' },
        ],
        explain: 'Sour and bitter sit on opposite sides of balanced. Overshooting proves the dial works — you just turned it too far in one go.',
        line: 'When in doubt, reach for the grinder first.' },
    ],
    reward: {
      title: 'The Grinder',
      summary: 'Your first and best dial for fixing a cup that tastes off.',
      fact: 'Baristas change grind before almost anything else \u2014 it moves the cup more than any other single tweak.',
      meta: [
        ['CONTROLS', 'Extraction speed'],
        ['FINER',    'Faster \u00b7 stronger'],
        ['COARSER',  'Slower \u00b7 lighter'],
      ],
    },
  },

  // ── Brew (Module 5) — practical intensity: very high ──
  m5l1: {
    moduleLabel: 'MODULE 5 \u00b7 BREW',
    title: 'The brew ratio',
    xp: 10, time: 5,
    cards: [
      { kind: 'predict', label: 'LESSON 1', title: 'The brew ratio',
        body: 'Before grind, before water — one guess about what sets the strength of a cup.',
        question: 'What decides how strong your coffee tastes?',
        options: ['How much coffee versus water', 'How hot the water is'],
        a: 'How much coffee versus water',
        hold: 'Sealed. It’s the simplest thing in the lesson, and the most useful.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Strength is a ratio',
        fill: ['More coffee per cup of water makes a ', { a: 'stronger', o: ['stronger', 'weaker'], label: 'More coffee' }, ' brew; more water makes a ', { a: 'weaker', o: ['weaker', 'stronger'], label: 'More water' }, ' one.'],
        paragraphs: [
          'The brew ratio is just coffee weight to water weight. More coffee per cup of water makes a stronger brew; more water makes a weaker one.',
          'It\u2019s the easiest thing to keep consistent \u2014 weigh both, and your coffee stops being a lottery.',
        ],
        meta: [['MORE COFFEE', 'Stronger'], ['MORE WATER', 'Weaker']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'Weak to strong', variant: 'ratio',
        caption: 'Ratio moves strength first \u2014 grind and water decide whether that strength tastes good.' },
      { kind: 'decision', label: 'AT THE BREWER', title: 'Start at 1:16, then adjust',
        scenario: 'You brewed 20g of coffee with 320g of water. The cup is clean and pleasant but thin — like it needs more of everything.',
        question: 'What do you change for the next brew?',
        options: [
          { t: 'Go to 23g of coffee, same water', sub: 'Ratio ≈ 1:14', correct: true },
          { t: 'Grind two steps finer', sub: 'Same 1:16 ratio' },
        ],
        right: 'Thin but not sour is a strength problem, not an extraction one. Move the ratio and leave grind alone.',
        wrong: 'Grinding finer extracts harder from too little coffee — you can end up thin and bitter at once. Fix strength with the ratio first.',
        note: 'Dial strength with the ratio first. Only reach for grind once the strength feels right.' },
      { kind: 'tastefix',
        tags: ['WEAK', 'WATERY'],
        prompt: 'Your coffee tastes weak and watery, but not sour. What first?',
        scenario: 'It\u2019s pleasant, just thin \u2014 like it needs more of everything.',
        choices: [
          { t: 'Use more coffee (or less water)', correct: true },
          { t: 'Brew for much longer' },
          { t: 'Switch to a darker roast' },
          { t: 'Add hot water to the cup' },
        ],
        explain: 'Thin but not sour points at strength, not extraction. Nudge the ratio \u2014 more coffee per cup \u2014 before you change anything else.',
      },
      { kind: 'mcq',
        prompt: 'A 1:16 ratio means\u2026',
        choices: [
          { t: '1 gram of coffee to 16 grams of water', correct: true },
          { t: '16 grams of coffee to 1 gram of water' },
          { t: '16 scoops per cup' },
          { t: 'A grind setting of 16' },
        ],
        explain: 'Ratio is coffee : water by weight. 1:16 is one gram of coffee for every sixteen of water \u2014 a solid beginner baseline.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A recipe calls for 1:16 and you’re brewing 350g of water. How much coffee?',
        choices: [
          { t: 'About 22g', correct: true },
          { t: 'About 16g' },
          { t: 'About 56g' },
        ],
        explain: 'Ratio is coffee to water by weight: one gram of coffee for every sixteen of water. 350 ÷ 16 is about 22g.',
        line: 'Weigh it, and strength stops being luck.' },
    ],
    reward: {
      title: 'The Brew Ratio',
      summary: 'Coffee to water, by weight \u2014 the dial that sets your cup\u2019s strength.',
      fact: 'Most filter recipes live between 1:15 and 1:17. Pick one, weigh it, and stay consistent.',
      meta: [
        ['BASELINE', '1:16'],
        ['STRONGER', 'More coffee'],
        ['WEAKER',   'More water'],
      ],
    },
  },

  m5l2: {
    moduleLabel: 'MODULE 5 \u00b7 BREW',
    title: 'Water, the variable',
    xp: 10, time: 4,
    cards: [
      { kind: 'predict', label: 'LESSON 2', title: 'Water, the variable',
        body: 'A cup of coffee is mostly one ingredient, and it isn’t the beans. One guess.',
        question: 'Roughly how much of a brewed cup is water?',
        options: ['About 80%', 'About 98%'],
        a: 'About 98%',
        hold: 'Hold that number. It changes what you should fix first.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Mostly water',
        fill: ['Brewed coffee is about ', { a: '98% water', o: ['98% water', '50% water'], label: 'Made of' }, ', so the water you use ', { a: 'matters', o: ['matters', 'is irrelevant'], label: 'Which means it' }, ' as much as the beans.'],
        paragraphs: [
          'Brewed coffee is roughly 98% water. If your tap water tastes bad on its own, it will taste bad in the cup \u2014 the beans can\u2019t hide it.',
          'Filtered water with a clean, neutral taste is a simple, cheap upgrade most beginners overlook.',
        ],
        meta: [['COFFEE IS', '~98% water'], ['SO USE', 'Clean, filtered']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Temperature sets the speed',
        fill: ['Hotter water extracts ', { a: 'faster', o: ['faster', 'slower'], label: 'Hotter' }, '; water that\u2019s too cool leaves the cup ', { a: 'sour', o: ['sour', 'bitter'], label: 'Too cool' }, ' and underdone.'],
        paragraphs: [
          'Hotter water pulls flavour out faster. Just off the boil \u2014 around 90\u201396\u00b0C \u2014 is the usual target for filter coffee.',
          'Too cool and the brew under-extracts, tasting sour and weak; boiling-hot on a dark roast can scorch it toward bitter. Most of the time, a short rest off the boil is all you need.',
        ],
        meta: [['TARGET', '~90\u201396\u00b0C'], ['TOO COOL', 'Sour, weak']],
      },
      { kind: 'slider',
        prompt: 'As water gets hotter, extraction tends to\u2026',
        leftLabel: 'SLOWER', rightLabel: 'FASTER',
        target: 80, tolerance: 15,
        scale: [
          'Cool \u2014 sour, underdone',
          'Warm \u2014 still weak',
          'Just off boil \u2014 balanced',
          'Very hot \u2014 quick, strong',
          'Boiling \u2014 risk of scorching',
        ],
        feedback: 'Hotter water extracts faster \u2014 which is why just off the boil is the usual sweet spot.',
      },
      { kind: 'mcq',
        prompt: 'A rough target temperature for brewing filter coffee is\u2026',
        choices: [
          { t: 'About 90\u201396\u00b0C \u2014 just off the boil', correct: true },
          { t: 'Room temperature' },
          { t: 'Exactly 100\u00b0C, always boiling' },
          { t: 'As cold as possible' },
        ],
        explain: 'Just off the boil \u2014 around 90 to 96\u00b0C \u2014 extracts well without scorching. A short rest after boiling gets you there.',
      },
      { kind: 'tastefix',
        tags: ['SOUR', 'UNDERDONE'],
        prompt: 'Your cup is sour and weak, and the water had cooled a while before you poured. What first?',
        scenario: 'Grind and ratio were your usual.',
        choices: [
          { t: 'Use hotter water, just off the boil', correct: true },
          { t: 'Use even cooler water' },
          { t: 'Add more water to the cup' },
          { t: 'Switch beans entirely' },
        ],
        explain: 'Sour and weak from cool water is under-extraction. Hotter water \u2014 just off the boil \u2014 speeds extraction back up before you touch anything else.',
      },
      { kind: 'decision', label: 'IN THE KITCHEN', title: 'Fix the water first',
        scenario: 'Your tap water tastes faintly of chlorine. You’ve been blaming your beans for a dull, slightly off cup.',
        question: 'What do you fix first?',
        options: [
          { t: 'Brew with filtered water', sub: 'Cheap · removes the off taste', correct: true },
          { t: 'Buy a more expensive bag of beans', sub: 'Same water' },
        ],
        right: 'The cup is almost entirely water. If the water tastes off on its own, no bean can hide it.',
        wrong: 'Better beans brewed in chlorinated water still taste of chlorine. You’d be paying more to mask the same problem.',
        note: 'Clean, filtered water just off the boil removes two hidden causes of a bad cup.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Your kettle boiled twenty minutes ago, and the cup came out sour and weak. Most likely cause?',
        choices: [
          { t: 'The water had cooled too far — under-extraction', correct: true },
          { t: 'The water was too hot and scorched the coffee' },
          { t: 'The beans were too fresh' },
        ],
        explain: 'Cool water extracts slowly, leaving the cup sour and thin. Just off the boil — around 90–96°C — is the usual target.',
        line: 'Good water, just off the boil \u2014 the beans can only be as good as it.' },
    ],
    reward: {
      title: 'Water',
      summary: 'The invisible 98% \u2014 temperature and quality shape every cup.',
      fact: 'Brewed coffee is about 98% water; filtered and just off the boil is the easy target.',
      meta: [
        ['COFFEE IS', '~98% water'],
        ['TARGET',    '~90\u201396\u00b0C'],
        ['USE',       'Clean, filtered'],
      ],
    },
  },

  m5l3: {
    moduleLabel: 'MODULE 5 \u00b7 BREW',
    title: 'Tasting your cup',
    xp: 10, time: 5,
    cards: [
      { kind: 'predict', label: 'LESSON 3', title: 'Tasting your cup',
        body: 'Everything so far comes down to this: taste a cup and name what’s off. One guess to start.',
        question: 'A cup tastes sour and thin. Was too much or too little flavour pulled out?',
        options: ['Too little', 'Too much'],
        a: 'Too little',
        hold: 'Sealed. Two words are about to cover most bad cups.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Sour vs bitter',
        fill: ['Sour and thin means the cup is ', { a: 'under', o: ['under', 'over'], label: 'Sour + thin' }, '-extracted; bitter and dry means it is ', { a: 'over', o: ['over', 'under'], label: 'Bitter + dry' }, '-extracted.'],
        paragraphs: [
          'Two problems cover most bad cups. Sour and thin means you pulled too little flavour out \u2014 under-extracted. Bitter and dry means you pulled too much \u2014 over-extracted.',
          'Learn to tell those two apart and you can fix almost anything, because they point in opposite directions.',
        ],
        meta: [['SOUR + THIN', 'Under-extracted'], ['BITTER + DRY', 'Over-extracted']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'The extraction spectrum', variant: 'extraction',
        caption: 'Almost every fix is just moving your cup back toward the middle of this line.' },
      { kind: 'decision', label: 'AT THE BREWER', title: 'Change one thing at a time',
        scenario: 'Your cup is bitter and drying, and you’d like it fixed for tomorrow morning.',
        question: 'What’s the move?',
        options: [
          { t: 'Grind one step coarser, change nothing else', sub: 'One variable', correct: true },
          { t: 'Coarser grind, cooler water, wider ratio', sub: 'Three variables' },
        ],
        right: 'Bitter and dry means over-extracted. Ease off with a coarser grind alone and you’ll know exactly what the change did.',
        wrong: 'Three changes at once might land a better cup, but you won’t know which one helped — or how to repeat it.',
        note: 'If your coffee tastes sour, don\u2019t change ratio, grind and temperature at once. Change one variable first, then compare.' },
      { kind: 'tastefix',
        tags: ['SOUR', 'THIN'],
        prompt: 'Your coffee came out off. What would you try first?',
        choices: [
          { t: 'Grind finer', correct: true },
          { t: 'Grind coarser' },
          { t: 'Use colder water' },
          { t: 'Brew for less time' },
        ],
        explain: 'Sour and thin coffee is usually under-extracted. A finer grind pulls out more flavour and rounds the cup toward balanced.',
      },
      { kind: 'tastefix',
        tags: ['BITTER', 'DRY'],
        prompt: 'Now it’s off the other way. What would you try first?',
        choices: [
          { t: 'Grind coarser', correct: true },
          { t: 'Grind even finer' },
          { t: 'Use much hotter water' },
          { t: 'Brew for much longer' },
        ],
        explain: 'Bitter and dry means over-extracted \u2014 you pulled too much. A coarser grind slows things down and eases the cup back to balanced.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Which pair of symptoms means you should extract less?',
        choices: [
          { t: 'Bitter and dry', correct: true },
          { t: 'Sour and thin' },
          { t: 'Sweet and rounded' },
        ],
        explain: 'Bitter and dry is over-extraction, so pull back. Sour and thin is the opposite, and sweet and rounded means you’re already there.',
        line: 'Sour, add extraction. Bitter, ease off. That\u2019s the whole game.' },
    ],
    reward: {
      title: 'Sour vs Bitter',
      summary: 'The two-word diagnosis behind almost every cup you\u2019ll fix.',
      fact: 'Sour and thin means too little extraction; bitter and dry means too much. Everything else is a nudge back to the middle.',
      meta: [
        ['SOUR + THIN', 'Extract more'],
        ['BITTER + DRY', 'Extract less'],
        ['GOLDEN RULE', 'One change at a time'],
      ],
    },
  },
};

// Earned + locked cards (collection). `unlock` links a card to the lesson or
// module that grants it; window.syncCollection() flips `earned` from live
// progress. `earned` here is only a first-paint seed — sync owns it after.
const COLLECTION = [
  { id: 'c1', earned: true, unlock: { lesson: 'm1l1' }, kind: 'botanical', title: 'The Coffee Cherry',
    summary: 'The fruit of the coffee plant.',
    fact: 'Cherries ripen unevenly — pickers return three or four times.',
    meta: [['FAMILY', 'Rubiaceae'], ['FRUIT', 'Drupe / cherry']] },
  { id: 'c2', earned: false, unlock: { lesson: 'm1l3' }, kind: 'map', title: 'The Bean Belt',
    summary: 'The equatorial band where coffee grows.',
    fact: 'Almost all coffee is grown between 25°N and 25°S.',
    meta: [['LATITUDE', '25°N – 25°S'], ['ELEVATION', '500–2000m']] },
  { id: 'c3', earned: false, unlock: { lesson: 'm1l2' }, kind: 'specimen', title: 'Arabica',
    summary: 'Sweeter, more aromatic. Grown high.',
    fact: 'Genetic diversity is unusually narrow — most plants are close cousins.',
    meta: [['SPECIES', 'C. arabica'], ['SHARE', '~60%']] },
  { id: 'cM1', earned: false, unlock: { module: 'm1' }, kind: 'guide', title: 'Field Guide · Beans',
    summary: 'You can read a bag of coffee and know what you’re holding.',
    fact: 'A barista who can name the species, origin, and processing can predict the cup before the first sip.',
    meta: [['MODULE', '01 · Beans'], ['LESSONS', '3'], ['EARNED BY', 'Finishing Beans']] },
  // ── Visual training cards — beginner references for what changes taste. ──
  { id: 'tr-roast', earned: true, kind: 'training', train: 'roast', title: 'Roast Levels',
    summary: 'Light to dark — how the roast shifts taste before you even brew.',
    fact: 'Medium roast is the most forgiving place for a beginner to start.',
    meta: [['LIGHT', 'Bright · acidic'], ['MEDIUM', 'Balanced · sweet'], ['DARK', 'Bitter · smoky']] },
  { id: 'tr-grind', earned: true, kind: 'training', train: 'grind', title: 'Grind Size',
    summary: 'Coarse to fine — the dial that controls how fast flavour extracts.',
    fact: 'Grind is usually the first thing to change when a cup tastes off.',
    meta: [['COARSE', 'French press'], ['MEDIUM', 'Pour-over'], ['FINE', 'Espresso']] },
  { id: 'tr-extraction', earned: true, kind: 'training', train: 'extraction', title: 'Extraction',
    summary: 'Under to over — the one idea behind sour vs bitter.',
    fact: 'Sour usually means too little extraction; bitter usually means too much.',
    meta: [['UNDER', 'Sour · thin'], ['BALANCED', 'Sweet · round'], ['OVER', 'Bitter · dry']] },
  { id: 'tr-ratio', earned: true, kind: 'training', train: 'ratio', title: 'Coffee-to-Water Ratio',
    summary: 'How much coffee vs water sets the strength of your cup.',
    fact: 'Most brews land near 1:16 — one gram of coffee to sixteen of water.',
    meta: [['BASELINE', '1:16'], ['STRONGER', 'More coffee'], ['WEAKER', 'More water']] },
  // ── Lesson & module cards for Modules 2–5 — earned as their lessons and
  //    modules complete (Module 1's three lesson cards are c1/c2/c3 above). ──
  { id: 'c-m2l1', earned: false, unlock: { lesson: 'm2l1' }, kind: 'dryingbed', title: 'The Drying Bed',
    summary: 'Where the process choice gets made — fruit on, fruit off, or between.',
    fact: 'On a raised bed, cherries are turned by hand every few hours so they dry evenly.',
    meta: [['METHODS', 'Washed / natural / honey'], ['CONTROLS', 'Fruit contact time']] },
  { id: 'c-m2l2', earned: false, unlock: { lesson: 'm2l2' }, kind: 'ferment', title: 'Fermentation',
    summary: 'The quiet chemistry that turns leftover fruit sugar into flavour.',
    fact: 'A few extra hours can be the difference between clean citrus and blueberry.',
    meta: [['DRIVEN BY', 'Sugar + time'], ['MORE OF IT', 'Fruit, funk, body']] },
  { id: 'c-m2l3', earned: false, unlock: { lesson: 'm2l3' }, kind: 'label', title: 'The Coffee Label',
    summary: 'Origin, variety, process, roast date — four lines that predict your cup.',
    fact: 'Read enough labels and you’ll guess the taste before the first sip.',
    meta: [['READS', 'Origin · process'], ['FORECASTS', 'Clarity vs fruit']] },
  { id: 'c-m3l1', earned: false, unlock: { lesson: 'm3l1' }, kind: 'roastscale', title: 'The Roast Spectrum',
    summary: 'Light to dark — how far the heat goes, and what it trades away.',
    fact: 'Roast level barely changes caffeine — it trades origin acidity for roast flavour.',
    meta: [['LIGHT', 'Bright · acidic'], ['DARK', 'Bitter · bold']] },
  { id: 'c-m3l2', earned: false, unlock: { lesson: 'm3l2' }, kind: 'crack', title: 'First & Second Crack',
    summary: 'The two sounds that tell a roaster how far a roast has gone.',
    fact: 'First crack sounds like faint popcorn; second crack is sharper, like crackling.',
    meta: [['FIRST', 'Light begins'], ['SECOND', 'Dark begins']] },
  { id: 'c-m3l3', earned: false, unlock: { lesson: 'm3l3' }, kind: 'calendar', title: 'The Roast Date',
    summary: 'The one number that tells you whether a bag is worth buying.',
    fact: 'Most coffee is at its best from a few days to about a month after roasting.',
    meta: [['SWEET SPOT', '~4 weeks'], ['LOOK FOR', 'A roast date']] },
  { id: 'c-m4l1', earned: false, unlock: { lesson: 'm4l1' }, kind: 'specimen', title: 'Particle Size',
    summary: 'How coarse or fine you grind — the speed dial for extraction.',
    fact: 'Halving particle size roughly doubles the surface water can reach.',
    meta: [['FINER', 'Faster'], ['COARSER', 'Slower']] },
  { id: 'c-m4l2', earned: false, unlock: { lesson: 'm4l2' }, kind: 'botanical', title: 'Burr vs Blade',
    summary: 'Why an even grind — not a fancy brewer — is the upgrade that counts.',
    fact: 'Blade grinders make dust and boulders at once; burrs make one even size.',
    meta: [['BURR', 'Even · dial-able'], ['BLADE', 'Uneven · muddy']] },
  { id: 'c-m4l3', earned: false, unlock: { lesson: 'm4l3' }, kind: 'map', title: 'The Grinder',
    summary: 'Your first and best dial for fixing a cup that tastes off.',
    fact: 'Baristas change grind before almost anything else — it moves the cup most.',
    meta: [['FINER', 'Faster · stronger'], ['COARSER', 'Slower · lighter']] },
  { id: 'c-m5l1', earned: false, unlock: { lesson: 'm5l1' }, kind: 'gauge', title: 'The Brew Ratio',
    summary: 'Coffee to water, by weight — the dial that sets your cup’s strength.',
    fact: 'Most filter recipes live between 1:15 and 1:17. Pick one and stay consistent.',
    meta: [['BASELINE', '1:16'], ['STRONGER', 'More coffee']] },
  { id: 'c-m5l2', earned: false, unlock: { lesson: 'm5l2' }, kind: 'droplet', title: 'Water',
    summary: 'The invisible 98% — temperature and quality shape every cup.',
    fact: 'Brewed coffee is about 98% water; filtered and just off the boil is the target.',
    meta: [['COFFEE IS', '~98% water'], ['TARGET', '~90–96°C']] },
  { id: 'c-m5l3', earned: false, unlock: { lesson: 'm5l3' }, kind: 'spectrum', title: 'Sour vs Bitter',
    summary: 'The two-word diagnosis behind almost every cup you’ll fix.',
    fact: 'Sour and thin means too little extraction; bitter and dry means too much.',
    meta: [['SOUR + THIN', 'Extract more'], ['BITTER + DRY', 'Extract less']] },
  { id: 'cM2', earned: false, unlock: { module: 'm2' }, kind: 'guide', title: 'Field Guide · Processing',
    summary: 'You can tell washed from natural by taste alone — eventually.',
    fact: 'Processing changes a coffee more than the roast does. Same bean, three cups.',
    meta: [['MODULE', '02 · Processing'], ['LESSONS', '3'], ['EARNED BY', 'Finishing Processing']] },
  { id: 'cM3', earned: false, unlock: { module: 'm3' }, kind: 'guide', title: 'Field Guide · Roasting',
    summary: 'You can read a roast level and a roast date, and know what they mean.',
    fact: 'Roast trades origin acidity for body — and freshness beats fame.',
    meta: [['MODULE', '03 · Roasting'], ['LESSONS', '3'], ['EARNED BY', 'Finishing Roasting']] },
  { id: 'cM4', earned: false, unlock: { module: 'm4' }, kind: 'guide', title: 'Field Guide · Grind',
    summary: 'You know why grind size and grinder type quietly control the cup.',
    fact: 'Grind is the speed dial for extraction — an even grind lets you use it.',
    meta: [['MODULE', '04 · Grind'], ['LESSONS', '3'], ['EARNED BY', 'Finishing Grind']] },
  { id: 'cM5', earned: false, unlock: { module: 'm5' }, kind: 'guide', title: 'Field Guide · Brew',
    summary: 'You can set a ratio, fix your water, and taste your way to a better cup.',
    fact: 'Ratio sets strength, water sets the speed, sour-vs-bitter names the fix.',
    meta: [['MODULE', '05 · Brew'], ['LESSONS', '3'], ['EARNED BY', 'Finishing Brew']] },
];

// Module reward cards — granted when a module is completed.
const MODULE_REWARDS = {
  m1: {
    title: 'Field Guide · Beans',
    summary: 'You can read a bag of coffee and know what you\u2019re holding.',
    fact: 'A barista who can name the species, origin, and processing can predict the cup before the first sip.',
    meta: [
      ['MODULE',   '01 · Beans'],
      ['LESSONS',  '3'],
      ['CARDS',    '3 unlocked'],
    ],
    badge: 'BEANS · COMPLETE',
  },
  m2: {
    title: 'Field Guide · Processing',
    summary: 'You can tell washed from natural by taste alone — eventually.',
    fact: 'Processing changes a coffee more than the roast does. Same bean, three different cups.',
    meta: [
      ['MODULE',   '02 · Processing'],
      ['LESSONS',  '3'],
      ['CARDS',    '3 unlocked'],
    ],
    badge: 'PROCESSING · COMPLETE',
  },
  m3: {
    title: 'Field Guide · Roasting',
    summary: 'You can read a roast level and a roast date, and know what they mean.',
    fact: 'Roast trades origin acidity for body and roast flavour — and freshness beats fame.',
    meta: [
      ['MODULE',  '03 · Roasting'],
      ['LESSONS', '3'],
      ['CARDS',   '3 unlocked'],
    ],
    badge: 'ROASTING · COMPLETE',
  },
  m4: {
    title: 'Field Guide · Grind',
    summary: 'You know why grind size and grinder type quietly control the cup.',
    fact: 'Grind is the speed dial for extraction — and an even grind is what lets you use it.',
    meta: [
      ['MODULE',  '04 · Grind'],
      ['LESSONS', '3'],
      ['CARDS',   '3 unlocked'],
    ],
    badge: 'GRIND · COMPLETE',
  },
  m5: {
    title: 'Field Guide · Brew',
    summary: 'You can set a ratio, fix your water, and taste your way to a better cup.',
    fact: 'Ratio sets strength, water sets the speed, and sour-vs-bitter tells you what to change.',
    meta: [
      ['MODULE',  '05 · Brew'],
      ['LESSONS', '3'],
      ['CARDS',   '3 unlocked'],
    ],
    badge: 'BREW · COMPLETE',
  },
};

window.MODULES = MODULES;
window.LESSONS = LESSONS;
window.COLLECTION = COLLECTION;
window.MODULE_REWARDS = MODULE_REWARDS;

// ── Coffee Tree progress (core-course progress) ─────────────────────
// The tree grows ONLY from first-time completion of core (main-path) lessons.
// Every module lesson is core; replays, challenges, duels and mini-games never
// grow it. Tree progress = completed core lessons / total core lessons, mapped
// onto the 10 growth stages. A weak first completion still grows the tree.
window.CORE_LESSON_IDS = MODULES.flatMap(m => m.lessons.map(l => l.id));
window.CORE_TOTAL = window.CORE_LESSON_IDS.length;
window.coreDoneCount = function(completedSet) {
  if (!completedSet) return 0;
  let n = 0; window.CORE_LESSON_IDS.forEach(id => { if (completedSet.has(id)) n++; });
  return n;
};
window.treeStageFromCore = function(done) {
  const total = window.CORE_TOTAL || 1;
  const frac = Math.max(0, Math.min(1, (done || 0) / total));
  return Math.max(1, Math.min(10, Math.round(1 + frac * 9)));
};

// ── Lesson state (mastery) ──────────────────────────────────
// Derived from the user's BEST result as a PERCENTAGE of that lesson's own
// question count — lessons have different lengths, so only the ratio compares.
// Effort/habit is points; this is mastery. ONE threshold, MASTERY_PASS:
//   below MASTERY_PASS → Needs Practice (the only state labelled in lists)
//   MASTERY_PASS–99%   → Solid (no label; the bean node shows how full)
//   100%               → Perfect (celebrated once + gift trigger, not a label)
// Ordered by rank so callers can compare / never downgrade.
window.MASTERY_PASS = 0.8;
const LESSON_STATES = {
  'needs-practice': { rank: 1, label: 'Needs Practice', short: 'PRACTICE', chip: true  },
  'mastered':       { rank: 2, label: 'Solid',          short: 'SOLID',    chip: false },
  'perfect':        { rank: 3, label: 'Perfect',        short: 'PERFECT',  chip: false },
};
window.LESSON_STATES = LESSON_STATES;

// best = { correct, total } or null. Returns a state key, or null if unplayed.
window.lessonStateFromResult = function(best) {
  if (!best || !best.total) return null;
  const pct = best.correct / best.total;
  if (pct >= 1) return 'perfect';
  return pct >= window.MASTERY_PASS ? 'mastered' : 'needs-practice';
};

// Stamp each core lesson with its mastery state (from best results) so the
// Path / Learn / Module cards can show it. Runs alongside syncModuleProgress.
window.syncMastery = function(bestResults) {
  const best = bestResults || {};
  MODULES.forEach(m => m.lessons.forEach(l => {
    l.best = best[l.id] || null;
    l.mastery = window.lessonStateFromResult(best[l.id]);
    // Ratio 0–1 of the best run, for the bean node's fill level. Null = no score.
    l.masteryPct = l.best && l.best.total ? l.best.correct / l.best.total : null;
  }));
};

// Helpers for lesson navigation
window.findLessonContext = function(id) {
  for (let mi = 0; mi < MODULES.length; mi++) {
    const m = MODULES[mi];
    const idx = m.lessons.findIndex(l => l.id === id);
    if (idx >= 0) {
      return {
        module: m, moduleIndex: mi,
        lesson: m.lessons[idx], lessonIndex: idx,
        isLastInModule: idx === m.lessons.length - 1,
        isLastModule: mi === MODULES.length - 1,
      };
    }
  }
  return null;
};
window.findNextLessonId = function(id) {
  const ctx = window.findLessonContext(id);
  if (!ctx) return null;
  if (!ctx.isLastInModule) return ctx.module.lessons[ctx.lessonIndex + 1].id;
  if (!ctx.isLastModule)  return MODULES[ctx.moduleIndex + 1].lessons[0].id;
  return null;
};
window.findNextModuleFirstLesson = function(id) {
  const ctx = window.findLessonContext(id);
  if (!ctx || ctx.isLastModule) return null;
  return MODULES[ctx.moduleIndex + 1].lessons[0].id;
};

// Keep the static MODULES status flags in sync with real completion progress.
// Gating (Path / Learn / Module screens) reads lesson.status + module.locked,
// so as the user completes lessons we recompute those from the live completed
// set: finished lessons become 'complete', the first unfinished lesson in an
// unlocked module becomes 'current', the rest stay 'locked'.
//
// A module unlocks the moment the PREVIOUS module is fully complete AND this
// module's own content is authored (its first lesson exists in LESSONS). That
// lets finishing Module 1 open Module 2 and drop the user straight into it;
// future modules that aren't built yet stay locked ("coming soon").
window.syncModuleProgress = function(completedSet) {
  const done = completedSet || new Set();
  const moduleDone = (m) => !!(m && m.lessons.length && m.lessons.every((l) => done.has(l.id)));
  MODULES.forEach((m, mi) => {
    const prev = mi > 0 ? MODULES[mi - 1] : null;
    const prevComplete = mi === 0 ? true : moduleDone(prev);
    const authored = !!(m.lessons.length && window.LESSONS && window.LESSONS[m.lessons[0].id]);
    // Module 1 was authored open; every later module opens on prev-complete +
    // authored content. Recomputed each render, so a progress reset re-locks.
    m.locked = mi === 0 ? false : !(prevComplete && authored);
    if (m.locked) { m.lessons.forEach((l) => { l.status = 'locked'; }); return; }
    let foundCurrent = false;
    m.lessons.forEach((l) => {
      if (done.has(l.id)) l.status = 'complete';
      else if (!foundCurrent) { l.status = 'current'; foundCurrent = true; }
      else l.status = 'locked';
    });
  });
};

// Flip collectible cards to `earned` from live progress. A lesson card unlocks
// when its lesson is complete; a module card (the Field Guide) unlocks when
// every lesson in that module is done. Placeholder cards (no `unlock`) stay as
// authored. Runs alongside syncModuleProgress on each render.
window.syncCollection = function(completedSet) {
  const done = completedSet || new Set();
  const moduleComplete = (mid) => {
    const m = MODULES.find((x) => x.id === mid);
    return !!(m && m.lessons.length && m.lessons.every((l) => done.has(l.id)));
  };
  COLLECTION.forEach((c) => {
    if (!c.unlock) return;
    if (c.unlock.lesson)      c.earned = done.has(c.unlock.lesson);
    else if (c.unlock.module) c.earned = moduleComplete(c.unlock.module);
  });
};
