# Hand the new lessons to Claude Design

> **✅ CONSUMED — do not paste again.** The prototype already carries this
> content (`prototype/data.jsx` holds the expanded course; verified 2026-08-16),
> and `prototype/` is read-only. Kept deliberately as history (see its adding
> commit). Note the course later grew beyond this handoff's 30 lessons — the
> live count comes from `node docs/design/tools/extract-facts.js`, not from
> this file. Paste the blocks below **in order**. Each is self-contained JavaScript, already validated.

> **Why this order.** Step 1 switches the app to the 30-lesson course, so lessons 2–7 come immediately after: a module stays **locked** until its first lesson exists in `LESSONS`, and Roasting's first lesson is one of them. Once steps 1–7 are in, everything is reachable and you can paste steps 8–16 one at a time and look at each lesson as it lands.

**Do not renumber any id.** Ids run deliberately out of sequence in Roasting, Grind and Brew — display order comes from array position, and the collectible, challenge and dictionary pointers are keyed to the ids as they are.

The content is already checked: 90 graded cards with exactly one correct answer each, every lesson 7–10 cards opening on `predict` and closing on `recall`, every pointer resolving, no straight quotes.

---

## Step 1 — Replace the `MODULES` array in `data.jsx`

Five modules, six lessons each. After this, Roasting · Grind · Brew read as locked until step 2 lands — that is expected.

```js
const MODULES = [
  {
    id: 'm1', n: 1, label: 'BEANS', title: 'Beans', glyph: 'beans',
    locked: false,
    lessons: [
      { id: 'm1l1', title: 'What coffee actually is', xp: 10, time: 3, status: 'complete' },
      { id: 'm1l2', title: 'Arabica vs Robusta',     xp: 10, time: 3, status: 'current' },
      { id: 'm1l3', title: 'What origin means',      xp: 10, time: 4, status: 'locked' },
      { id: 'm1l4', title: 'Why altitude matters',   xp: 10, time: 4, status: 'locked' },
      { id: 'm1l5', title: 'What the shelf promises', xp: 10, time: 4, status: 'locked' },
      { id: 'm1l6', title: 'Why two Ethiopias taste different', xp: 10, time: 3, status: 'locked' },
    ],
  },
  {
    id: 'm2', n: 2, label: 'PROCESSING', title: 'Processing', glyph: 'processing',
    locked: true,
    lessons: [
      { id: 'm2l1', title: 'Washed, natural, honey', xp: 10, time: 4, status: 'locked' },
      { id: 'm2l2', title: 'Why processing matters', xp: 10, time: 4, status: 'locked' },
      { id: 'm2l3', title: 'Reading a bag label',    xp: 10, time: 3, status: 'locked' },
      { id: 'm2l4', title: 'Drying coffee',          xp: 10, time: 4, status: 'locked' },
      { id: 'm2l5', title: 'What happens in the tank', xp: 10, time: 4, status: 'locked' },
      { id: 'm2l6', title: 'Decaf, honestly',        xp: 10, time: 4, status: 'locked' },
    ],
  },
  { id: 'm3', n: 3, label: 'ROASTING',  title: 'Roasting',  glyph: 'roasting', locked: true, lessons: [
      { id: 'm3l4', title: 'What roasting does',     xp: 10, time: 4, status: 'locked' },
      { id: 'm3l1', title: 'Light, medium, dark', xp: 10, time: 4, status: 'locked' },
      { id: 'm3l2', title: 'First and second crack', xp: 10, time: 5, status: 'locked' },
      { id: 'm3l3', title: 'Reading a roast date',   xp: 10, time: 3, status: 'locked' },
      { id: 'm3l5', title: 'Light vs dark, side by side', xp: 10, time: 4, status: 'locked' },
      { id: 'm3l6', title: 'How much caffeine are you actually drinking?', xp: 10, time: 4, status: 'locked' },
  ]},
  { id: 'm4', n: 4, label: 'GRIND',     title: 'Grind',     glyph: 'grind', locked: true, lessons: [
      { id: 'm4l1', title: 'Particle size, in plain English', xp: 10, time: 4, status: 'locked' },
      { id: 'm4l2', title: 'Burr vs blade',                   xp: 10, time: 4, status: 'locked' },
      { id: 'm4l5', title: 'Which grind for which brewer',    xp: 10, time: 3, status: 'locked' },
      { id: 'm4l3', title: 'Dialing in by taste',             xp: 10, time: 5, status: 'locked' },
      { id: 'm4l6', title: 'Why pre-ground never tastes as good', xp: 10, time: 3, status: 'locked' },
      { id: 'm4l7', title: 'Choosing your first grinder',     xp: 10, time: 3, status: 'locked' },
  ]},
  { id: 'm5', n: 5, label: 'BREW',      title: 'Brew',      glyph: 'brewing', locked: true, lessons: [
      { id: 'm5l1', title: 'The brew ratio',     xp: 10, time: 5, status: 'locked' },
      { id: 'm5l2', title: 'Water, the variable', xp: 10, time: 4, status: 'locked' },
      { id: 'm5l4', title: 'Extraction explained', xp: 10, time: 5, status: 'locked' },
      { id: 'm5l5', title: 'Choosing a filter',  xp: 10, time: 4, status: 'locked' },
      { id: 'm5l3', title: 'Tasting your cup',   xp: 10, time: 5, status: 'locked' },
      { id: 'm5l6', title: 'Your first good cup', xp: 10, time: 5, status: 'locked' },
  ]},
];
```
---

## Step 2 — Add `m3l4` to `LESSONS` in `data.jsx`

**Roasting 1 — What roasting does**
**Paste this one early — Roasting stays locked until it exists.**


```js
  m3l4: {
    moduleLabel: 'MODULE 3 · ROASTING',
    title: 'What roasting does',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 1', title: 'What roasting does',
        body: 'Green coffee smells like hay and tastes like nothing. Everything you recognise as coffee is made in the roaster. One guess before we open it up.',
        question: 'As a roast goes darker, acidity…',
        options: ['Goes up', 'Goes down'],
        a: 'Goes down',
        hold: 'Held. What it trades away — and what it gains — is the whole lesson.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Heat makes the flavour',
        fill: ['Roasting drives ', { a: 'hundreds', o: ['hundreds', 'two or three'], label: 'How many' }, ' of reactions that build aroma, colour and flavour that were ', { a: 'not there before', o: ['not there before', 'already present'], label: 'Before the roast' }, '.'],
        paragraphs: [
          'A green bean holds acids, sugars, proteins and caffeine. Heat rearranges almost all of it — browning reactions build hundreds of new aromatic compounds along the way.',
          'This is why the same lot can arrive as two completely different cups. The roaster is not revealing a flavour; they are making one.',
        ],
        meta: [['GREEN', 'Hay, grass'], ['ROASTED', 'Hundreds of aromatics']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'The trade',
        fill: ['Longer and hotter trades origin ', { a: 'acidity', o: ['acidity', 'caffeine'], label: 'What is lost' }, ' for roast ', { a: 'body and bitterness', o: ['body and bitterness', 'floral notes'], label: 'What is gained' }, '.'],
        paragraphs: [
          'Acids break down as the roast runs on, so brightness fades. In its place come the heavier, darker, roastier flavours the heat itself is producing.',
          'Neither end is better. They are different answers to the question of how much of the origin you want to still be able to taste.',
        ],
        meta: [['DARKER', 'Less acidity'], ['TRADED FOR', 'Body, roast flavour']],
      },
      { kind: 'sequence',
        prompt: 'Order the stages of a roast.',
        items: [
          { label: 'Drying phase',            order: 1 },
          { label: 'Browning (Maillard)',     order: 2 },
          { label: 'First crack',             order: 3 },
          { label: 'Development',             order: 4 },
          { label: 'Drop from the roaster',   order: 5 },
        ],
      },
      { kind: 'match',
        prompt: 'Match each stage to what you see or hear.',
        pairs: [
          { l: 'Drying',      r: 'Green turns yellow' },
          { l: 'Browning',    r: 'Bean turns light brown' },
          { l: 'First crack', r: 'A sharp popping sound' },
          { l: 'Development', r: 'Colour deepens, smoke rises' },
        ],
      },
      { kind: 'slider',
        prompt: 'Around what bean temperature does first crack happen?',
        leftLabel: 'COOLER', rightLabel: 'HOTTER',
        target: 52, tolerance: 12,
        scale: [
          '150 °C — still drying',
          '175 °C — browning',
          '195–205 °C — first crack',
          '225 °C — second crack',
          '250 °C — well past dark',
        ],
        feedback: 'First crack usually lands around 195–205 °C, when steam pressure pops the bean open.' },
      { kind: 'mcq',
        prompt: 'What is actually happening at first crack?',
        choices: [
          { t: 'Steam pressure inside the bean forces it to pop open', correct: true },
          { t: 'The caffeine boils off' },
          { t: 'The bean catches fire briefly' },
          { t: 'The roaster changes the fan speed' },
        ],
        explain: 'Water inside the bean turns to steam, pressure builds, and the structure gives way with an audible crack. It is the roaster’s clearest landmark.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Someone asks what roasting is for. What is the one-sentence answer?',
        choices: [
          { t: 'Heat builds the aroma and flavour that green coffee does not have yet', correct: true },
          { t: 'Heat dries the coffee out so it can be stored' },
          { t: 'Heat removes the bitterness the green bean starts with' },
        ],
        explain: 'Green coffee is stable and nearly flavourless. Roasting is where coffee starts tasting like coffee — and where acidity gets traded for body.',
        line: 'Green coffee is potential. The roaster decides how much of it you taste.' },
    ],
    reward: {
      title: 'The Roast',
      summary: 'What heat actually does to a green bean.',
      fact: 'First crack arrives around 195–205 °C, when steam pressure pops the bean open.',
      meta: [['BUILDS', 'Aroma · colour'], ['TRADES', 'Acidity for body']],
    },
  },
```
---

## Step 3 — Add `m1l4` to `LESSONS` in `data.jsx`

**Beans 4 — Why altitude matters**


```js
  m1l4: {
    moduleLabel: 'MODULE 1 · BEANS',
    title: 'Why altitude matters',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 4', title: 'Why altitude matters',
        body: 'Bags of specialty coffee often print a number in metres. It is there for a reason. One guess before we get to it.',
        question: 'Coffee grown higher up tends to be…',
        options: ['Much the same', 'Denser and more complex'],
        a: 'Denser and more complex',
        hold: 'Hold it there. The reason is temperature, not height itself.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Height buys time',
        fill: ['Higher ground is cooler, so the cherry ripens ', { a: 'slower', o: ['slower', 'faster'], label: 'What changes' }, ' — and slow ripening lets sugars and acids build ', { a: 'further', o: ['further', 'less'], label: 'The result' }, '.'],
        paragraphs: [
          'Altitude is a proxy for temperature. Higher up the air is cooler, and a cooler cherry takes longer to mature.',
          'That extra time is the whole mechanism: sugars and acids keep accumulating in the seed instead of the fruit rushing to ripe.',
        ],
        meta: [['ALTITUDE MEANS', 'Cooler air'], ['COOLER MEANS', 'Slower ripening']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Denser beans',
        fill: ['A slowly grown seed ends up ', { a: 'denser', o: ['denser', 'lighter'], label: 'The bean' }, ', which is why roasters often print the altitude on the ', { a: 'bag', o: ['bag', 'receipt'], label: 'Where you see it' }, '.'],
        paragraphs: [
          'Slow maturation packs more material into the same seed. Dense beans hold up to heat differently and carry more of the origin character through the roast.',
          'Most specialty coffee is grown between about 1,200 and 2,200 metres. Above that, frost stops being theoretical.',
        ],
        meta: [['SPECIALTY BAND', '1,200–2,200 m'], ['ABOVE THAT', 'Frost risk']],
      },
      { kind: 'match',
        prompt: 'Match each altitude band to its typical character.',
        pairs: [
          { l: 'Below 1,000 m',  r: 'Soft, neutral' },
          { l: '1,200–1,600 m',  r: 'Balanced, sweet' },
          { l: 'Above 1,800 m',  r: 'Bright, complex' },
        ],
      },
      { kind: 'slider',
        prompt: 'Where is most specialty coffee grown?',
        leftLabel: 'LOWER', rightLabel: 'HIGHER',
        target: 62, tolerance: 15,
        scale: [
          'Below 800 m — soft, flat',
          '800–1,200 m — pleasant, simple',
          '1,200–1,800 m — the specialty band',
          '1,800–2,200 m — bright, dense',
          'Above 2,200 m — frost country',
        ],
        feedback: 'Most specialty coffee sits between about 1,200 and 2,200 metres.' },
      { kind: 'mcq',
        prompt: 'Why does cooler weather help quality?',
        choices: [
          { t: 'It slows ripening, giving flavour more time to develop', correct: true },
          { t: 'It speeds ripening, which keeps flavours bright' },
          { t: 'It kills off the weaker plants' },
          { t: 'It has no effect on flavour' },
        ],
        explain: 'Slow maturation lets the cherry’s sugars and acids reach a deeper, more layered profile.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'The number in metres',
        scenario: 'Two Colombian bags, same roaster, same week, same price. One prints “1,900 masl”. The other prints nothing about altitude.',
        question: 'Which is the safer buy if you want complexity?',
        options: [
          { t: 'The bag printing 1,900 masl', sub: 'High and specific', correct: true },
          { t: 'The bag with no altitude', sub: 'Could be anything' },
        ],
        right: 'A printed altitude is a traceable claim. At 1,900 m you can expect density and acidity, and the roaster is telling you they know where it came from.',
        wrong: 'It might be excellent. But with nothing printed you are buying on faith, and altitude is one of the cheapest signals to check.',
        note: 'Altitude on a bag is a forecast for acidity and complexity — and a sign the roaster knows the farm.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Someone says high-grown coffee is better because the air is thinner. What is the accurate correction?',
        choices: [
          { t: 'It is the cooler temperature, which slows ripening', correct: true },
          { t: 'It is the thinner air pressing the beans denser' },
          { t: 'It is the stronger sunlight at altitude' },
        ],
        explain: 'Altitude matters because of what it does to temperature. Cooler air, slower ripening, denser seed, more complex cup.',
        line: 'Altitude is not height. It is time.' },
    ],
    reward: {
      title: 'Altitude',
      summary: 'Why the number in metres on a bag predicts the cup.',
      fact: 'Most specialty coffee grows between 1,200 and 2,200 metres — high enough to ripen slowly, low enough to avoid frost.',
      meta: [['SPECIALTY BAND', '1,200–2,200 m'], ['MECHANISM', 'Cooler · slower']],
    },
  },
```
---

## Step 4 — Add `m2l4` to `LESSONS` in `data.jsx`

**Processing 4 — Drying coffee**


```js
  m2l4: {
    moduleLabel: 'MODULE 2 · PROCESSING',
    title: 'Drying coffee',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 4', title: 'Drying coffee',
        body: 'After the fruit is dealt with, the seed still has to dry. It is the slowest, quietest step at origin — and one of the easiest to get wrong.',
        question: 'Green coffee is dried down to roughly…',
        options: ['About 11% moisture', 'Bone dry'],
        a: 'About 11% moisture',
        hold: 'Hold that number. Bone dry would be a problem, and the reason is worth knowing.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Stable, not dry',
        fill: ['Green coffee is dried to about ', { a: '11%', o: ['11%', '1%'], label: 'The target' }, ' moisture — dry enough to ', { a: 'ship safely', o: ['ship safely', 'roast instantly'], label: 'Why' }, ', wet enough to keep its character.'],
        paragraphs: [
          'Between roughly 10 and 12% moisture, coffee is stable: it will not mould in a sack crossing an ocean, and it will not have baked itself flat on the patio.',
          'Take it lower and the seed loses aromatics it never gets back. Leave it higher and the whole lot is at risk.',
        ],
        meta: [['TARGET', '10–12%'], ['TOO DRY', 'Flat, brittle']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Slow on purpose',
        fill: ['Drying is done ', { a: 'slowly', o: ['slowly', 'quickly'], label: 'The method' }, ' and the beans are turned by hand, because fast drying leaves ', { a: 'uneven moisture', o: ['uneven moisture', 'perfect beans'], label: 'The risk' }, ' through the lot.'],
        paragraphs: [
          'Sun drying takes ten to twenty-five days. Naturals run longer than washed because the whole cherry is still on the seed, holding water in.',
          'Raised beds give airflow on every side; patios use warm concrete; mechanical dryers trade some character for speed and control.',
        ],
        meta: [['SUN DRYING', '10–25 days'], ['NATURALS', 'Longer still']],
      },
      { kind: 'sequence',
        prompt: 'Order the drying workflow.',
        items: [
          { label: 'Spread on the drying surface', order: 1 },
          { label: 'Turn and rake daily',          order: 2 },
          { label: 'Measure moisture',             order: 3 },
          { label: 'Rest in the shade',            order: 4 },
          { label: 'Bag for storage',              order: 5 },
        ],
      },
      { kind: 'match',
        prompt: 'Match each drying method to its main idea.',
        pairs: [
          { l: 'Raised beds',       r: 'Airflow on every side' },
          { l: 'Patios',            r: 'Sun-warmed concrete floors' },
          { l: 'Mechanical dryers', r: 'Heated drums for speed' },
        ],
      },
      { kind: 'mcq',
        prompt: 'Why does even drying matter so much?',
        choices: [
          { t: 'Uneven moisture makes the lot roast unevenly and stale unpredictably', correct: true },
          { t: 'It makes the beans heavier, so the farmer earns more' },
          { t: 'It changes the species of the coffee' },
          { t: 'It removes the caffeine' },
        ],
        explain: 'A lot with mixed moisture is a lot that cannot be roasted to one target. Some beans go too far while others are still behind.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Drying you can taste',
        scenario: 'A natural process bag describes itself as “dried 22 days on raised beds, turned hourly”. Another says nothing about drying at all.',
        question: 'What does the first bag actually tell you?',
        options: [
          { t: 'Someone tracked the slow step and thought it worth printing', correct: true },
          { t: 'The coffee is guaranteed to score higher' },
        ],
        right: 'Drying detail is a transparency signal. A roaster who knows the bed and the day count is a roaster close enough to the lot to be worth trusting.',
        wrong: 'It is not a score and it is not a guarantee. It is evidence about the supply chain, which is a different and still useful thing.',
        note: 'Drying detail on a bag is a traceability signal, not a quality grade.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Why is coffee dried to about 11% rather than as dry as possible?',
        choices: [
          { t: 'It is the point where the seed is stable to ship but has not lost its character', correct: true },
          { t: 'Drier coffee is illegal to export' },
          { t: 'Below 11% the caffeine breaks down' },
        ],
        explain: 'Ten to twelve percent is the compromise between spoilage on one side and a flat, brittle, hollowed-out seed on the other.',
        line: 'Drying is the slowest step and the easiest to rush. Both show up in the cup.' },
    ],
    reward: {
      title: 'Drying',
      summary: 'The slow step that decides whether a lot survives the journey.',
      fact: 'Sun drying takes 10–25 days, and naturals run longest because the fruit is still on.',
      meta: [['TARGET', '~11% moisture'], ['TURNED', 'By hand, daily']],
    },
  },
```
---

## Step 5 — Add `m3l5` to `LESSONS` in `data.jsx`

**Roasting 5 — Light vs dark, side by side**


```js
  m3l5: {
    moduleLabel: 'MODULE 3 · ROASTING',
    title: 'Light vs dark, side by side',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 5', title: 'Light vs dark, side by side',
        body: 'You know what the roast spectrum is. Now put two cups next to each other and choose between them on purpose.',
        question: 'Scoop for scoop, which has slightly more caffeine?',
        options: ['Light roast', 'Dark roast'],
        a: 'Light roast',
        hold: 'Held — and the reason is about density, not heat.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Not better, different',
        fill: ['Light and dark are not ', { a: 'better and worse', o: ['better and worse', 'the same thing'], label: 'The framing' }, ' — they show off ', { a: 'different parts', o: ['different parts', 'the same part'], label: 'What differs' }, ' of the same coffee.'],
        paragraphs: [
          'A light roast leaves the origin audible: florals, fruit, acidity. A dark roast puts the roaster’s own flavours in front: caramelised, smoky, bittersweet.',
          'Choosing is a question about what you want to taste, and about what the coffee is capable of showing.',
        ],
        meta: [['LIGHT', 'Floral · fruity'], ['DARK', 'Smoky · bittersweet']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Density, and the caffeine myth',
        fill: ['Caffeine is ', { a: 'heat stable', o: ['heat stable', 'burnt off'], label: 'In the roaster' }, ', but darker beans are ', { a: 'less dense', o: ['less dense', 'heavier'], label: 'What changes' }, ' — so by weight, light roasts edge ahead.'],
        paragraphs: [
          'Roasting does not destroy caffeine in any amount worth counting. What it does is drive off water and puff the bean up, so a dark roast bean weighs less than a light one of the same size.',
          'Measure by scoop and you get slightly more caffeine from light. Measure by weight and the difference nearly vanishes. Either way it is small.',
        ],
        meta: [['CAFFEINE', 'Heat stable'], ['DARK BEANS', 'Less dense']],
      },
      { kind: 'match',
        prompt: 'Match each roast level to the flavour family it shows off.',
        pairs: [
          { l: 'Light roast',  r: 'Floral and fruity' },
          { l: 'Medium roast', r: 'Caramel and nutty' },
          { l: 'Dark roast',   r: 'Smoky and bittersweet' },
        ],
      },
      { kind: 'sequence',
        prompt: 'Order these from shortest time in the roaster to longest.',
        items: [
          { label: 'Light roast',  order: 1 },
          { label: 'Medium roast', order: 2 },
          { label: 'Dark roast',   order: 3 },
        ],
      },
      { kind: 'mcq',
        prompt: 'Which roast usually works better in a milk drink?',
        choices: [
          { t: 'Medium to dark — it stays audible through the milk', correct: true },
          { t: 'The lightest available, for maximum acidity' },
          { t: 'It makes no difference at all' },
          { t: 'Decaf, always' },
        ],
        explain: 'Milk flattens acidity and adds sweetness of its own. Darker roasts have the body and bittersweetness to still be tasted through it.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Buying for the brewer you own',
        scenario: 'You drink one black filter coffee each morning, and you have just been given a bag of expensive Ethiopian coffee to choose the roast for.',
        question: 'Light or dark?',
        options: [
          { t: 'Light', sub: 'Keeps the origin audible', correct: true },
          { t: 'Dark', sub: 'Safe and familiar' },
        ],
        right: 'You are drinking it black through a filter, which is the setup that shows origin character best. A dark roast would cover the thing you paid for.',
        wrong: 'Nothing wrong with a dark roast — but taking a distinctive Ethiopian coffee dark spends money on a flavour the roast then hides.',
        note: 'Match the roast to how you drink it. Black filter favours light; milk favours darker.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Why does a scoop of light roast carry slightly more caffeine than a scoop of dark?',
        choices: [
          { t: 'Caffeine survives the roast, but dark beans are less dense — so a scoop holds less coffee', correct: true },
          { t: 'Heat creates extra caffeine in lighter roasts' },
          { t: 'Dark roasting burns most of the caffeine away' },
        ],
        explain: 'It is a measuring artefact, not chemistry. Weigh instead of scooping and the difference nearly disappears.',
        line: 'Light and dark are not a ranking. They are a choice about what you want to taste.' },
    ],
    reward: {
      title: 'Light vs Dark',
      summary: 'Two ends of the spectrum, and how to choose between them.',
      fact: 'Caffeine survives roasting — light roasts only win by the scoop because dark beans are less dense.',
      meta: [['LIGHT', 'Origin forward'], ['DARK', 'Roast forward']],
    },
  },
```
---

## Step 6 — Add `m5l4` to `LESSONS` in `data.jsx`

**Brew 3 — Extraction explained**


```js
  m5l4: {
    moduleLabel: 'MODULE 5 · BREW',
    title: 'Extraction explained',
    xp: 10, time: 5, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 3', title: 'Extraction explained',
        body: 'Ratio sets how much coffee. Extraction is how much of that coffee actually made it into the water. One guess before the numbers.',
        question: 'Your cup tastes sour and thin. Most likely…',
        options: ['Under-extracted', 'Over-extracted'],
        a: 'Under-extracted',
        hold: 'Held. Two words, two directions — this is the diagnosis the rest of the course leans on.' },
      { kind: 'concept', label: 'CONCEPT', title: 'What extraction is',
        fill: ['Extraction is how much of the coffee ', { a: 'dissolves', o: ['dissolves', 'floats'], label: 'What it does' }, ' into the water — the target band is about ', { a: '18–22%', o: ['18–22%', '50–60%'], label: 'The sweet spot' }, '.'],
        paragraphs: [
          'Only some of a coffee ground is soluble at all. Of what is, you want to pull roughly eighteen to twenty-two percent into the cup.',
          'Below that band you have left the sweetness behind. Above it you have started pulling out the parts nobody wants.',
        ],
        meta: [['TARGET', '18–22%'], ['MEASURED AS', 'Yield']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Sour and bitter are directions',
        fill: ['Sour and thin means ', { a: 'too little', o: ['too little', 'too much'], label: 'Under' }, ' extraction; bitter and dry means ', { a: 'too much', o: ['too much', 'too little'], label: 'Over' }, '.'],
        paragraphs: [
          'The acids come out first, then the sugars, then the bitter compounds. Stop early and you get the acids on their own. Run long and you get everything, including the last part.',
          'That is why sour and bitter are not opposites on a quality scale. They are opposite ends of one dial, and they tell you which way to turn it.',
        ],
        meta: [['SOUR + THIN', 'Extract more'], ['BITTER + DRY', 'Extract less']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'The extraction spectrum', variant: 'extraction',
        caption: 'Under, balanced, over. Almost every cup you will want to fix is somewhere on this line, and the taste tells you which side.' },
      { kind: 'match',
        prompt: 'Match each symptom to its cause.',
        pairs: [
          { l: 'Sour and thin',     r: 'Under-extracted' },
          { l: 'Bitter and harsh',  r: 'Over-extracted' },
          { l: 'Balanced and sweet', r: 'Correctly extracted' },
        ],
      },
      { kind: 'slider',
        prompt: 'Pick the target extraction yield.',
        leftLabel: 'UNDER', rightLabel: 'OVER',
        target: 50, tolerance: 12,
        scale: [
          '12% — sour, hollow',
          '16% — bright but thin',
          '18–22% — the sweet spot',
          '24% — drying, bitter',
          '28% — harsh',
        ],
        feedback: 'Eighteen to twenty-two percent. Outside that band, cups reliably taste sour or bitter.' },
      { kind: 'sequence',
        prompt: 'Order the extraction levers from biggest effect to subtlest.',
        items: [
          { label: 'Grind size',         order: 1 },
          { label: 'Brew time',          order: 2 },
          { label: 'Water temperature',  order: 3 },
          { label: 'Brew ratio',         order: 4 },
        ],
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A cup is sour and hollow. What is the first thing you change?',
        choices: [
          { t: 'Grind finer — it is under-extracted and grind moves it most', correct: true },
          { t: 'Add more water to soften it' },
          { t: 'Use a lighter roast next time' },
        ],
        explain: 'Sour and thin means under-extracted. Grind is the strongest lever, so it is the one to move first — and only one at a time.',
        line: 'Sour means pull more. Bitter means pull less. Everything else is detail.' },
    ],
    reward: {
      title: 'Extraction',
      summary: 'The one idea behind sour versus bitter.',
      fact: 'The classic target is 18–22% of the coffee dissolved into the water.',
      meta: [['UNDER', 'Sour · thin'], ['OVER', 'Bitter · dry']],
    },
  },
```
---

## Step 7 — Add `m5l5` to `LESSONS` in `data.jsx`

**Brew 4 — Choosing a filter**


```js
  m5l5: {
    moduleLabel: 'MODULE 5 · BREW',
    title: 'Choosing a filter',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 4', title: 'Choosing a filter',
        body: 'The cheapest part of the whole setup, and it changes the cup more than most people expect.',
        question: 'A paper filter mainly…',
        options: ['Removes oils, for a cleaner cup', 'Adds body'],
        a: 'Removes oils, for a cleaner cup',
        hold: 'Held. What it takes out is the point, and it is a choice, not a loss.' },
      { kind: 'concept', label: 'CONCEPT', title: 'What a filter keeps back',
        fill: ['Paper traps ', { a: 'oils and fines', o: ['oils and fines', 'caffeine'], label: 'What it catches' }, ', so the cup reads ', { a: 'cleaner', o: ['cleaner', 'heavier'], label: 'The result' }, ' and more transparent.'],
        paragraphs: [
          'Coffee oils carry body and a soft, lingering texture. Fines — the dust from grinding — carry silt and some bitterness.',
          'Paper catches both. What is left is clarity: you taste the acidity and the individual notes more distinctly, with less weight underneath them.',
        ],
        meta: [['PAPER TRAPS', 'Oils · fines'], ['LEAVES', 'Clarity']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Metal and cloth',
        fill: ['Metal lets the ', { a: 'oils through', o: ['oils through', 'water through only'], label: 'Metal' }, ' for a fuller body; cloth sits ', { a: 'between the two', o: ['between the two', 'below both'], label: 'Cloth' }, '.'],
        paragraphs: [
          'A metal filter is a mesh, not a membrane. Oils and some fines go straight through, giving a heavier, glossier cup with more texture.',
          'Cloth splits the difference — most of the body, much of the clarity — at the cost of needing to be kept properly clean.',
        ],
        meta: [['METAL', 'Heavy · oily'], ['CLOTH', 'In between']],
      },
      { kind: 'match',
        prompt: 'Match each filter to the body it tends to give.',
        pairs: [
          { l: 'Paper filter', r: 'Clean and light' },
          { l: 'Metal filter', r: 'Heavy and oily' },
          { l: 'Cloth filter', r: 'Somewhere in between' },
        ],
      },
      { kind: 'sequence',
        prompt: 'Order the steps for rinsing a paper filter.',
        items: [
          { label: 'Place the filter in the brewer', order: 1 },
          { label: 'Pour hot water through it',      order: 2 },
          { label: 'Discard the rinse water',        order: 3 },
          { label: 'Add the ground coffee',          order: 4 },
        ],
      },
      { kind: 'mcq',
        prompt: 'Why rinse a paper filter before brewing?',
        choices: [
          { t: 'It washes out papery taste and warms the brewer at the same time', correct: true },
          { t: 'It makes the paper more porous, so the brew runs faster' },
          { t: 'It removes caffeine from the filter' },
          { t: 'It is only for decoration' },
        ],
        explain: 'A short rinse does two jobs at once: no paper taste in the cup, and a preheated brewer that will not steal heat from the brew.',
      },
      { kind: 'decision', label: 'AT THE BREWER', title: 'A delicate Ethiopian, and two filters',
        scenario: 'You have a light, floral Ethiopian coffee and both a paper and a metal filter for the same brewer.',
        question: 'Which do you reach for?',
        options: [
          { t: 'Paper', sub: 'Clarity, so the florals show', correct: true },
          { t: 'Metal', sub: 'More body' },
        ],
        right: 'You paid for delicate aromatics. Paper strips the oils that would sit on top of them, and the florals come through much more clearly.',
        wrong: 'Metal is a good choice for a chocolatey, heavy coffee where body is the point. Here it muffles the thing you bought.',
        note: 'Paper for clarity, metal for body. Match the filter to the coffee, not the habit.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Your filter cup tastes thin and you want more weight to it, same beans.',
        choices: [
          { t: 'Switch to a metal filter — it lets the oils through', correct: true },
          { t: 'Rinse the paper filter for longer' },
          { t: 'Use two paper filters instead of one' },
        ],
        explain: 'Body lives in the oils, and paper is what is holding them back. A metal mesh is the direct fix.',
        line: 'The cheapest part of the setup, and it decides how heavy the cup feels.' },
    ],
    reward: {
      title: 'The Filter',
      summary: 'Paper, metal or cloth — and what each one keeps out of the cup.',
      fact: 'Paper traps the oils that carry body; metal lets them straight through.',
      meta: [['PAPER', 'Clean · light'], ['METAL', 'Heavy · oily']],
    },
  },
```
---

## Step 8 — Add `m1l5` to `LESSONS` in `data.jsx`

**Beans 5 — What the shelf promises**

```js
  m1l5: {
    moduleLabel: 'MODULE 1 · BEANS',
    title: 'What the shelf promises',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 5', title: 'What the shelf promises',
        body: 'Bags carry words that sound like guarantees — Fair Trade, single origin, specialty. Some of them are. One guess first.',
        question: '“Fair Trade” on a bag means the farmer was paid well.',
        options: ['Yes, it guarantees it', 'Not exactly'],
        a: 'Not exactly',
        hold: 'Hold that. What it actually guarantees is narrower — and more specific — than it sounds.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Single origin, or a blend',
        fill: ['A ', { a: 'single origin', o: ['single origin', 'blend'], label: 'One place' }, ' names one place; a ', { a: 'blend', o: ['blend', 'single origin'], label: 'Several places' }, ' mixes several for a consistent house taste.'],
        paragraphs: [
          '“Single origin” is a range, not a point. It can mean one country, one region, one farm, or one lot from one patch of one farm — each narrower and more traceable than the last.',
          'A blend is not a lesser thing. It is a different goal: consistency across the year rather than the character of one harvest.',
        ],
        meta: [['NARROWEST', 'A single lot'], ['BROADEST', 'A country']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'What certification certifies',
        fill: ['Fair Trade sets a ', { a: 'minimum price', o: ['minimum price', 'quality bar'], label: 'What it fixes' }, ' paid to a co-operative — it is a price floor, not a promise about the ', { a: 'cup', o: ['cup', 'price tag'], label: 'What it is silent on' }, '.'],
        paragraphs: [
          'The Fair Trade mark means a certified co-operative was paid at or above a set minimum price. That is a real, checkable thing, and it is the whole of what the mark asserts.',
          'It is not a quality bar, and it is not a wage guarantee to the person who picked the cherries. The co-operative decides what happens to the money after that.',
        ],
        meta: [['CERTIFIES', 'A price floor'], ['DOES NOT', 'Grade the cup']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Direct trade and traceability',
        fill: ['“Direct trade” has ', { a: 'no certifying body', o: ['no certifying body', 'a strict auditor'], label: 'Who checks it' }, ' — it is the roaster’s own ', { a: 'claim', o: ['claim', 'guarantee'], label: 'What it is' }, '.'],
        paragraphs: [
          'Direct trade means the roaster says they buy from the farm themselves. There is no standards body behind the phrase, so it is worth exactly as much as the roaster’s transparency.',
          'At its best it beats certification outright — more money to the farm, a named producer, a published price. At its worst it is a word on a bag with nothing behind it.',
        ],
        meta: [['BACKED BY', 'The roaster'], ['CHECK FOR', 'A named farm']],
      },
      { kind: 'match',
        prompt: 'Match each claim to what it actually guarantees.',
        pairs: [
          { l: 'Fair Trade',    r: 'A minimum price to the co-op' },
          { l: 'Single origin', r: 'One named place' },
          { l: 'Specialty',     r: 'Scored 80+ by a cupper' },
          { l: 'Direct trade',  r: 'The roaster buys at the farm' },
        ],
      },
      { kind: 'multi',
        prompt: 'Which lines on a bag are verifiable claims? Select all that apply.',
        choices: [
          { t: 'Roast date', correct: true },
          { t: 'Origin', correct: true },
          { t: 'Process', correct: true },
          { t: 'A certification mark', correct: true },
          { t: '“Artisan”' },
          { t: '“Gourmet”' },
          { t: '“Premium blend”' },
        ],
        explain: 'A date, a place, a process and a mark can each be checked. “Artisan”, “gourmet” and “premium” are unregulated — they mean whatever the printer felt like.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Two kinds of promise',
        scenario: 'A Fair Trade certified blend with no roast date anywhere on the bag, next to a single farm in Huila, traceable to the producer, roasted eight days ago.',
        question: 'Which one goes in the basket?',
        options: [
          { t: 'The traceable single farm', sub: 'Roasted 8 days ago', correct: true },
          { t: 'The Fair Trade blend', sub: 'No roast date' },
        ],
        right: 'The certification tells you something real about the trade, but nothing about the cup — and no roast date means nobody is standing behind the freshness.',
        wrong: 'The mark is worth something, but it is a claim about price paid at origin. It cannot tell you whether the coffee in the bag is still alive.',
        note: 'A certification tells you about the trade, not the cup. Read both lines and know which is which.' },
      { kind: 'mcq',
        prompt: '“Specialty coffee” means…',
        choices: [
          { t: 'It scored 80 or above out of 100 with a trained cupper', correct: true },
          { t: 'It is sold in a speciality café' },
          { t: 'It is a marketing word with no definition' },
          { t: 'It was grown above 1,500 metres' },
        ],
        explain: 'Specialty is a score, not a vibe. A qualified cupper grades the coffee against a fixed protocol, and 80 is the line.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A bag reads “Fair Trade Certified · Premium Blend”. What do you actually know?',
        choices: [
          { t: 'A co-op was paid at least a set minimum price — and nothing about how it tastes', correct: true },
          { t: 'The picker earned a living wage and the coffee scored well' },
          { t: 'It is single origin and traceable to a farm' },
        ],
        explain: '“Fair Trade” is a checkable claim about price. “Premium blend” is not a claim at all. Neither says anything about the cup.',
        line: 'A label makes two promises — one about the cup, one about the trade. Now you can tell them apart.' },
    ],
    reward: {
      title: 'The Trade',
      summary: 'What the words on a bag promise, and who they promise it to.',
      fact: 'Specialty is a score, not a vibe — 80 or more out of 100, cupped.',
      meta: [['CERTIFIES', 'Price floor'], ['DOES NOT', 'Guarantee quality']],
    },
  },
```
---

## Step 9 — Add `m1l6` to `LESSONS` in `data.jsx`

**Beans 6 — Why two Ethiopias taste different**

```js
  m1l6: {
    moduleLabel: 'MODULE 1 · BEANS',
    title: 'Why two Ethiopias taste different',
    xp: 10, time: 3, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 6', title: 'Why two Ethiopias taste different',
        body: 'In Lesson 3 you took one variety and moved it between countries. Now run the experiment the other way round — same country, same process, two different varieties.',
        question: 'Same place, different variety. Same cup?',
        options: ['Roughly, yes', 'They can taste very different'],
        a: 'They can taste very different',
        hold: 'Held. Two experiments, one variable each — this is the second one.' },
      { kind: 'concept', label: 'CONCEPT', title: 'A variety is a cultivar',
        fill: ['A ', { a: 'variety', o: ['variety', 'species'], label: 'The line on the bag' }, ' is a named type within a ', { a: 'species', o: ['species', 'region'], label: 'The bigger group' }, ' — nearly every Arabica traces back to Typica or Bourbon.'],
        paragraphs: [
          'Arabica is the species. Typica and Bourbon are its two great ancestors, and almost everything grown today descends from one of them — Caturra, SL28, Geisha and the rest.',
          'The variety line on a bag names that cultivar. It is a different question from the country line, and it moves the cup on its own.',
        ],
        meta: [['ANCESTORS', 'Typica · Bourbon'], ['DESCENDANTS', 'Caturra · SL28 · Geisha']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Why the good ones cost more',
        fill: ['The varieties that cup highest tend to ', { a: 'yield less', o: ['yield less', 'yield more'], label: 'Per tree' }, ' and catch disease more easily, so a farmer growing them earns ', { a: 'less per tree', o: ['less per tree', 'more per tree'], label: 'The trade-off' }, '.'],
        paragraphs: [
          'Geisha is the clearest case: floral, tea-like, extraordinary in the cup — and a fussy, low-yielding plant that needs the right altitude to show any of it.',
          'The price on the bag is paying for that trade. Fewer kilos per tree, more risk per season, and a farmer who took the bet.',
        ],
        meta: [['HIGH CUPPING', 'Low yield'], ['THE COST', 'Risk at the farm']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'The variety family tree', variant: 'variety',
        caption: 'Typica and Bourbon at the root, branching out to Geisha, Caturra and SL28. When a bag prints a variety, this is the line it is pointing at — not the country, not the process.' },
      { kind: 'mcq',
        prompt: 'Which of these lines on a bag names the variety?',
        choices: [
          { t: 'Geisha', correct: true },
          { t: 'Yirgacheffe' },
          { t: 'Natural' },
          { t: 'Medium roast' },
        ],
        explain: 'Geisha is a cultivar. Yirgacheffe is a region, natural is a process, and medium roast is what the roaster did afterwards.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Same everything, one line apart',
        scenario: 'Two Ethiopian bags. Same region, same washed process, same roast date. One says “Heirloom”. The other says “Geisha” and costs three times as much.',
        question: 'You are buying to learn what variety does. Which one?',
        options: [
          { t: 'The Geisha', sub: 'Three times the price', correct: true },
          { t: 'The heirloom', sub: 'The everyday choice' },
        ],
        right: 'Everything else is held constant, so whatever you taste is the variety talking. That is worth paying for once — you are buying the experiment, not just the coffee.',
        wrong: 'A perfectly good bag, and the sensible everyday buy. It just will not answer the question you came in with, because you have nothing to compare it against.',
        note: 'To learn what a variable does, change only that variable. Once.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Lesson 3 held the variety and changed the place. This lesson held the place and changed the variety. What did the pair show?',
        choices: [
          { t: 'Both lines move the cup — origin and variety are separate variables', correct: true },
          { t: 'Only origin really matters; variety is marketing' },
          { t: 'Only variety really matters; origin is marketing' },
        ],
        explain: 'Two controlled experiments, one variable each. Neither line on the bag is decoration.',
        line: 'Same variety, different place. Same place, different variety. Both move the cup — now you know which line on the bag is which.' },
    ],
    reward: {
      title: 'Varieties',
      summary: 'Typica, Bourbon, Geisha — the names behind the cup.',
      fact: 'Almost every Arabica grown today traces back to Typica or Bourbon.',
      meta: [['ANCESTORS', 'Typica · Bourbon'], ['PRIZED', 'Geisha']],
    },
  },
```
---

## Step 10 — Add `m2l5` to `LESSONS` in `data.jsx`

**Processing 5 — What happens in the tank**

```js
  m2l5: {
    moduleLabel: 'MODULE 2 · PROCESSING',
    title: 'What happens in the tank',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 5', title: 'What happens in the tank',
        body: 'Washed, natural, honey — you know the three names. Underneath all of them sits one stage that actually makes the difference.',
        question: 'Fermentation happens to…',
        options: ['Only some coffees', 'Every coffee'],
        a: 'Every coffee',
        hold: 'Held. It is not an option on the menu — it is the menu.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Every coffee ferments',
        fill: ['Microbes eat the sugary ', { a: 'mucilage', o: ['mucilage', 'caffeine'], label: 'What they eat' }, ' off the seed — that is what ', { a: 'processing', o: ['processing', 'roasting'], label: 'Which stage' }, ' is actually doing.'],
        paragraphs: [
          'Under the skin of a coffee cherry is a layer of sticky, sugary flesh called mucilage. Getting it off the seed is the job every processing method is doing, and microbes do most of the work.',
          'So fermentation is not a special technique some coffees get. It is the stage all of them pass through.',
        ],
        meta: [['DRIVEN BY', 'Microbes'], ['EATING', 'Mucilage']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Time and oxygen',
        fill: ['Washed coffee ferments ', { a: 'briefly', o: ['briefly', 'for weeks'], label: 'Washed' }, ' in a tank then rinses; natural ferments ', { a: 'slowly', o: ['slowly', 'not at all'], label: 'Natural' }, ' inside the whole drying fruit.'],
        paragraphs: [
          'Two dials: how long the microbes get, and how much air they have. Washed is short and rinsed clean. Natural is long, inside the intact cherry, with all that fruit sugar in play.',
          'Honey sits between — some mucilage left on, some taken off. The three names you already know are three settings of the same two dials.',
        ],
        meta: [['DIAL ONE', 'Time'], ['DIAL TWO', 'Oxygen']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Anaerobic, and what it claims',
        fill: ['An ', { a: 'anaerobic', o: ['anaerobic', 'aerobic'], label: 'The word on the bag' }, ' ferment happens in a sealed tank with the ', { a: 'oxygen shut out', o: ['oxygen shut out', 'lid off'], label: 'What is different' }, ', pushing wilder and more intense flavours.'],
        paragraphs: [
          'Seal the tank and starve it of air and a different set of microbes takes over. The results run intense, fruit-forward, sometimes boozy — recognisably not what the same cherry does in an open tank.',
          '“Co-ferment” goes further and adds something to the tank on purpose. Both words now appear on specialty bags, so they are a shelf encounter, not just theory.',
        ],
        meta: [['SEALED TANK', 'No oxygen'], ['EXPECT', 'Intense, fruity']],
      },
      { kind: 'sequence',
        prompt: 'Order the stages a washed coffee passes through.',
        items: [
          { label: 'Cherry picked', order: 1 },
          { label: 'Pulped',        order: 2 },
          { label: 'Fermented',     order: 3 },
          { label: 'Washed',        order: 4 },
          { label: 'Dried',         order: 5 },
        ],
      },
      { kind: 'multi',
        prompt: 'Which of these are true of fermentation? Select all that apply.',
        choices: [
          { t: 'It happens to every coffee', correct: true },
          { t: 'Microbes drive it', correct: true },
          { t: 'Time and oxygen change the result', correct: true },
          { t: 'It makes the coffee alcoholic' },
          { t: 'It means the coffee has spoiled' },
        ],
        explain: 'Fermentation is a controlled stage, not a fault. What varies is how long it runs and how much air it gets.',
      },
      { kind: 'mcq',
        prompt: 'A bag reads “anaerobic natural”. What should you expect?',
        choices: [
          { t: 'Intense, fruit-forward, sometimes a little boozy', correct: true },
          { t: 'Clean, delicate and tea-like' },
          { t: 'Flat and neutral, with no fruit at all' },
          { t: 'Decaffeinated' },
        ],
        explain: 'Sealed-tank fermentation plus the whole fruit left on through drying is the loudest combination on the shelf.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'A friend says only “anaerobic” coffees are fermented. What is the correction?',
        choices: [
          { t: 'All coffee is fermented — anaerobic just names how the tank was run', correct: true },
          { t: 'Only natural process coffees are fermented' },
          { t: 'Fermentation happens during roasting, not at origin' },
        ],
        explain: 'Every method passes through fermentation. The words on the bag describe the settings, not whether it happened.',
        line: 'Every coffee ferments. The choice is how long, and with how much air.' },
    ],
    reward: {
      title: 'Fermentation',
      summary: 'The stage where much of the flavour is actually made.',
      fact: 'Seal the tank and starve it of oxygen, and the same cherry tastes like a different fruit.',
      meta: [['DRIVEN BY', 'Microbes'], ['DIALS', 'Time · oxygen']],
    },
  },
```
---

## Step 11 — Add `m2l6` to `LESSONS` in `data.jsx`

**Processing 6 — Decaf, honestly**

```js
  m2l6: {
    moduleLabel: 'MODULE 2 · PROCESSING',
    title: 'Decaf, honestly',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 6', title: 'Decaf, honestly',
        body: 'Decaf has a reputation problem, and most of it is about a process almost nobody can describe. One guess before we fix that.',
        question: 'Decaf has no caffeine at all.',
        options: ['True', 'False'],
        a: 'False',
        hold: 'Held. The real number is small, but it is not zero — and that matters at 9 pm.' },
      { kind: 'concept', label: 'CONCEPT', title: 'It happens before the roast',
        fill: ['Decaffeination is done to ', { a: 'green', o: ['green', 'roasted'], label: 'Which beans' }, ' beans, ', { a: 'before roasting', o: ['before roasting', 'after brewing'], label: 'When' }, ', at origin or a dedicated plant.'],
        paragraphs: [
          'Decaf is a processing step, which is why it belongs in this module. The beans arrive green, get their caffeine taken out, and are dried back down before anyone roasts them.',
          'By the time a roaster sees the coffee, the decaffeination happened somewhere else, months earlier.',
        ],
        meta: [['APPLIED TO', 'Green coffee'], ['WHERE', 'Origin or plant']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Three routes out',
        fill: ['All three methods ', { a: 'soak, strip and return', o: ['soak, strip and return', 'burn off'], label: 'The pattern' }, ' the beans — what changes is the ', { a: 'solvent', o: ['solvent', 'temperature'], label: 'What does the work' }, '.'],
        paragraphs: [
          'Solvent methods use ethyl acetate — often derived from sugarcane — or methylene chloride. Swiss Water uses water and a carbon filter. CO2 uses pressurised gas.',
          'The shape is the same in each: wet the beans so the caffeine is mobile, pull it out, then put everything else back.',
        ],
        meta: [['SOLVENT', 'EA · methylene chloride'], ['NO SOLVENT', 'Swiss Water · CO2']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Never zero',
        fill: ['The legal bar is roughly ', { a: '97%', o: ['97%', '100%'], label: 'Removed' }, ' removal, so a decaf cup still carries ', { a: 'a few milligrams', o: ['a few milligrams', 'nothing at all'], label: 'What is left' }, ' against about 95 in a regular one.'],
        paragraphs: [
          'Around 97% is the standard, which leaves roughly two to five milligrams in a cup. A regular drip cup is near ninety-five.',
          'So decaf is not caffeine-free coffee. It is coffee with almost all of it removed — enough that a cup at night is a different proposition, not a risk-free one for everybody.',
        ],
        meta: [['DECAF CUP', '~2–5 mg'], ['REGULAR CUP', '~95 mg']],
      },
      { kind: 'match',
        prompt: 'Match each method to its mechanism.',
        pairs: [
          { l: 'Swiss Water',   r: 'Water and a carbon filter' },
          { l: 'CO2',           r: 'Pressurised gas' },
          { l: 'Ethyl acetate', r: 'A solvent rinse, often from sugarcane' },
        ],
      },
      { kind: 'mcq',
        prompt: 'Which of these is true of decaf?',
        choices: [
          { t: 'It is decaffeinated as green coffee, before roasting', correct: true },
          { t: 'The caffeine is roasted out at high temperature' },
          { t: 'It is brewed shorter to leave the caffeine behind' },
          { t: 'It comes from a naturally caffeine-free plant' },
        ],
        explain: 'Decaffeination is a processing step applied to green beans. Roasting and brewing do not remove caffeine.',
      },
      { kind: 'decision', label: 'IN THE KITCHEN', title: 'Nine o’clock, and someone says “chemicals”',
        scenario: 'You are making an evening pot of decaf. Someone at the table says decaf is full of chemicals and they would rather not.',
        question: 'What do you do?',
        options: [
          { t: 'Pour it, and explain what the processes actually are', sub: 'Swiss Water and CO2 use no solvent', correct: true },
          { t: 'Tip it out and make regular coffee', sub: 'It is late' },
        ],
        right: 'Swiss Water and CO2 use no solvent at all, and where a solvent is used it is rinsed out and then hits roasting temperatures well above its boiling point. The fear is about a stage that ends before the bean is even roasted.',
        wrong: 'Regular coffee at 9 pm solves a worry by creating a bigger one. The chemistry question has a real answer, and it is a reassuring one.',
        note: 'The “chemicals” worry is about a process that finishes before roasting — and two of the three methods use none.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'You said decaf has no caffeine at all. What is the accurate version?',
        choices: [
          { t: 'About 97% is removed — a cup carries a few milligrams, not none', correct: true },
          { t: 'It is entirely caffeine-free by law' },
          { t: 'It has about half the caffeine of regular coffee' },
        ],
        explain: 'Roughly 97% removal is the bar. Two to five milligrams against about ninety-five is close to nothing, but it is not nothing.',
        line: 'Decaf is not no caffeine. It is almost none — and it is not a chemical bath.' },
    ],
    reward: {
      title: 'Decaf',
      summary: 'How the caffeine comes out, and what stays behind.',
      fact: 'Roughly 97% removed is the bar — a decaf cup still carries a few milligrams.',
      meta: [['METHODS', 'Solvent · water · CO2'], ['REMOVED', '~97%']],
    },
  },
```
---

## Step 12 — Add `m3l6` to `LESSONS` in `data.jsx`

**Roasting 6 — How much caffeine are you actually drinking?**

```js
  m3l6: {
    moduleLabel: 'MODULE 3 · ROASTING',
    title: 'How much caffeine are you actually drinking?',
    xp: 10, time: 4, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 6', title: 'How much caffeine are you actually drinking?',
        body: 'Almost everyone gets this one backwards, and the reason is a word people use loosely. One guess.',
        question: 'Which has more caffeine — a single espresso, or a large drip coffee?',
        options: ['The espresso', 'The drip'],
        a: 'The drip',
        hold: 'Held. Most people say espresso. The gap is bigger than you would think.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Concentration is not dose',
        fill: ['Espresso is ', { a: 'concentrated', o: ['concentrated', 'diluted'], label: 'Per millilitre' }, ' — but only about 30 ml of it, so the ', { a: 'dose', o: ['dose', 'concentration'], label: 'What reaches you' }, ' that reaches you is small.'],
        paragraphs: [
          'Per millilitre, espresso is far stronger than drip. That is what “strong” usually means when people say it about espresso, and it is true.',
          'But you drink 30 ml of espresso and 240 ml of drip. Eight times the volume at a fraction of the concentration still adds up to more caffeine.',
        ],
        meta: [['ESPRESSO', '~30 ml'], ['DRIP CUP', '~240 ml']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'The numbers worth carrying',
        fill: ['A single espresso is about ', { a: '63 mg', o: ['63 mg', '200 mg'], label: 'Espresso' }, '; a 240 ml drip cup about ', { a: '95 mg', o: ['95 mg', '20 mg'], label: 'Drip' }, '.'],
        paragraphs: [
          'Espresso ≈ 63 mg. A 240 ml drip cup ≈ 95 mg. A large cold brew can reach 200 mg. Decaf sits at 2–5 mg.',
          'Health bodies commonly put a daily ceiling near 400 mg for most healthy adults — about four drip cups.',
        ],
        meta: [['ESPRESSO', '~63 mg'], ['DRIP CUP', '~95 mg']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'What actually moves the number',
        fill: ['Three things move it: how much ', { a: 'coffee you used', o: ['coffee you used', 'sugar you added'], label: 'Dose' }, ', how long the water ', { a: 'touched it', o: ['touched it', 'boiled'], label: 'Contact' }, ', and the species.'],
        paragraphs: [
          'Dose and contact time do most of the work. Robusta carries about twice Arabica’s caffeine, as you saw in Beans.',
          'Roast colour is not on the list. It barely moves the number at all — the myth is durable, but it is a myth.',
        ],
        meta: [['MOVES IT', 'Dose · time · species'], ['DOES NOT', 'Roast colour']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'Caffeine, per serving', variant: 'caffeine',
        caption: 'Decaf, espresso, drip cup, large cold brew — laid out at the size you actually drink them. The espresso is the concentrated one and the smallest dose on the chart.' },
      { kind: 'slider',
        prompt: 'How much caffeine is in a 240 ml drip cup?',
        leftLabel: 'LESS', rightLabel: 'MORE',
        target: 46, tolerance: 10,
        scale: [
          'Decaf — ~3 mg',
          'Espresso — ~63 mg',
          'Drip cup — ~95 mg',
          'Two drip cups — ~190 mg',
          'Large cold brew — ~200 mg',
        ],
        feedback: 'About 95 mg. That is the number worth carrying around.' },
      { kind: 'decision', label: 'IN THE KITCHEN', title: 'Four o’clock',
        scenario: 'It is 4 pm. You want a coffee. You also need to be asleep by eleven.',
        question: 'What do you make?',
        options: [
          { t: 'A decaf, or a smaller cup', sub: '~3 mg, or half the dose', correct: true },
          { t: 'Switch to a dark roast', sub: 'It tastes stronger' },
        ],
        right: 'Dose is the lever. Less coffee, or decaf, and you have actually changed the number rather than the flavour.',
        wrong: 'Roast colour barely moves caffeine — you met that in Light, medium, dark. A dark roast tastes bolder and keeps you up just the same.',
        note: 'If you want less caffeine, change the dose or the drink. Roast colour is not the dial.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Why does a large drip coffee beat a single espresso on caffeine?',
        choices: [
          { t: 'Espresso is more concentrated, but the drip is eight times the volume', correct: true },
          { t: 'Espresso is made from decaffeinated beans' },
          { t: 'The dark roast used for espresso has less caffeine' },
        ],
        explain: 'Concentration is per millilitre. Dose is what reaches you. Espresso wins the first and loses the second.',
        line: 'The strongest-tasting cup is rarely the strongest one.' },
    ],
    reward: {
      title: 'Caffeine',
      summary: 'How much is really in the cup in front of you.',
      fact: 'A single espresso carries less caffeine than a mug of drip — concentration is not dose.',
      meta: [['ESPRESSO', '~63 mg'], ['DRIP CUP', '~95 mg']],
    },
  },
```
---

## Step 13 — Add `m4l5` to `LESSONS` in `data.jsx`

**Grind 3 — Which grind for which brewer**

```js
  m4l5: {
    moduleLabel: 'MODULE 4 · GRIND',
    title: 'Which grind for which brewer',
    xp: 10, time: 3, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 3', title: 'Which grind for which brewer',
        body: 'You know what particle size does. Now land it on the one brewer sitting on your counter.',
        question: 'The right grind depends mostly on…',
        options: ['The beans', 'The brewer'],
        a: 'The brewer',
        hold: 'Held. There is one rule underneath it, and it is about time.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Contact time sets the grind',
        fill: ['The longer water sits with the coffee, the ', { a: 'coarser', o: ['coarser', 'finer'], label: 'The rule' }, ' you grind — otherwise it ', { a: 'over-extracts', o: ['over-extracts', 'stays sour'], label: 'Or else' }, '.'],
        paragraphs: [
          'A French press holds water on the grounds for four minutes. An espresso machine pushes it through in under thirty seconds. The same grind cannot serve both.',
          'So the brewer sets the contact time, and the contact time sets the grind. That is the whole rule, and every brewer on the shelf follows it.',
        ],
        meta: [['LONG CONTACT', 'Coarser'], ['SHORT CONTACT', 'Finer']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'The map',
        fill: ['French press ', { a: 'coarse', o: ['coarse', 'fine'], label: 'Four minutes' }, ' · Chemex medium-coarse · V60 medium · AeroPress medium-fine · espresso ', { a: 'fine', o: ['fine', 'coarse'], label: 'Thirty seconds' }, '.'],
        paragraphs: [
          'Five brewers, one line. Read it as a time axis and the order stops needing to be memorised.',
          'Your brewer sits somewhere on it. Start there, then adjust by taste — that is what the next lesson is for.',
        ],
        meta: [['COARSEST', 'French press'], ['FINEST', 'Espresso']],
      },
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'The grind spectrum, by brewer', variant: 'grind',
        caption: 'Coarse to fine, with the brewers placed along it. Find yours, start there, adjust from taste.' },
      { kind: 'match',
        prompt: 'Match each brewer to its grind.',
        pairs: [
          { l: 'French press', r: 'Coarse' },
          { l: 'V60',          r: 'Medium' },
          { l: 'AeroPress',    r: 'Medium-fine' },
          { l: 'Espresso',     r: 'Fine' },
        ],
      },
      { kind: 'slider',
        prompt: 'Set the dial for a French press.',
        leftLabel: 'FINER', rightLabel: 'COARSER',
        target: 82, tolerance: 12,
        scale: [
          'Flour — espresso',
          'Table salt — moka pot',
          'Kosher salt — pour-over',
          'Coarse sand — French press',
          'Peppercorns — cold brew',
        ],
        feedback: 'Coarse sand. Four minutes of contact needs big particles, or the cup turns bitter and silty.' },
      { kind: 'decision', label: 'AT THE BREWER', title: 'Ground for filter',
        scenario: 'You own a French press. The bag on the shelf you want says “ground for filter”.',
        question: 'What do you do?',
        options: [
          { t: 'Buy whole bean and grind it coarse', sub: 'Or accept a muddier cup', correct: true },
          { t: 'Buy it pre-ground and press it anyway', sub: 'It is only one step off' },
        ],
        right: 'Filter grind in a French press is too fine for four minutes of contact. It over-extracts and slips through the mesh — bitter and silty at once.',
        wrong: 'You can do it, and it will be drinkable. It will also be muddier and harsher than the same coffee ground properly, for no reason.',
        note: 'Pre-ground is ground for one brewer, and it probably is not yours.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'You switch from a V60 to a French press with the same beans. Which way does the grind move?',
        choices: [
          { t: 'Coarser — the French press holds water on the coffee far longer', correct: true },
          { t: 'Finer — immersion needs more surface area' },
          { t: 'It stays the same; the beans decide the grind' },
        ],
        explain: 'Longer contact, coarser grind. The rule runs the same direction every time.',
        line: 'Ask the brewer, not the bag.' },
    ],
    reward: {
      title: 'Grind & Brewer',
      summary: 'Which grind belongs to which brewer, and why.',
      fact: 'The longer the water sits with the coffee, the coarser the grind has to be.',
      meta: [['RULE', 'Contact time'], ['COARSEST', 'French press']],
    },
  },
```
---

## Step 14 — Add `m4l6` to `LESSONS` in `data.jsx`

**Grind 5 — Why pre-ground never tastes as good**

```js
  m4l6: {
    moduleLabel: 'MODULE 4 · GRIND',
    title: 'Why pre-ground never tastes as good',
    xp: 10, time: 3, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 5', title: 'Why pre-ground never tastes as good',
        body: 'You have been dialling grind size in by taste. Worth knowing what happens to those grounds while they sit.',
        question: 'Ground coffee goes stale in…',
        options: ['Days', 'Minutes'],
        a: 'Minutes',
        hold: 'Held. It is faster than almost anyone expects, and the reason is geometry.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Surface area is the whole story',
        fill: ['Grinding turns one bean into thousands of exposed ', { a: 'surfaces', o: ['surfaces', 'flavours'], label: 'What multiplies' }, ' — and it is ', { a: 'surface area', o: ['surface area', 'weight'], label: 'The variable' }, ', not time in the bag, that drives staling.'],
        paragraphs: [
          'A whole bean has a skin and a small outside. Grinding it shatters that into thousands of faces, all of them suddenly in contact with air.',
          'Nothing else about the coffee changed. The geometry did, and the geometry is what staling runs on.',
        ],
        meta: [['WHOLE BEAN', 'One surface'], ['GROUND', 'Thousands']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'What leaves, what arrives',
        fill: ['CO2 and ', { a: 'aromatics', o: ['aromatics', 'caffeine'], label: 'What leaves' }, ' go out; ', { a: 'oxygen and moisture', o: ['oxygen and moisture', 'nothing much'], label: 'What comes in' }, ' come in.'],
        paragraphs: [
          'That smell filling the kitchen when you grind is not a bonus. It is the coffee leaving the coffee — aromatic compounds you were about to drink, going into the room instead.',
          'Meanwhile oxygen and moisture move the other way, and the oils start to oxidise. Both directions are one-way.',
        ],
        meta: [['OUT', 'CO2 · aromatics'], ['IN', 'Oxygen · moisture']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'The order of upgrades',
        fill: ['A ', { a: 'cheap grinder with fresh beans', o: ['cheap grinder with fresh beans', 'great bag bought pre-ground'], label: 'Wins' }, ' beats an expensive bag bought pre-ground — if you buy one thing, buy the ', { a: 'grinder', o: ['grinder', 'brewer'], label: 'Buy this' }, '.'],
        paragraphs: [
          'This is the highest-leverage change most beginners can make, and it is not close. Every other adjustment is working with what the grounds have left.',
          'The bag you already like, ground fresh, will beat a better bag ground last month.',
        ],
        meta: [['FIRST BUY', 'A grinder'], ['THEN', 'Better beans']],
      },
      { kind: 'multi',
        prompt: 'Which of these actually slow staling? Select all that apply.',
        choices: [
          { t: 'Keeping beans whole until you brew', correct: true },
          { t: 'An airtight container', correct: true },
          { t: 'Somewhere cool and dark', correct: true },
          { t: 'A distant “best by” date' },
          { t: 'Storing it in the fridge door' },
        ],
        explain: 'Whole, sealed, cool and dark. A “best by” date tells you nothing about the roast date, and the fridge door cycles temperature and pumps moisture into the bag.',
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'Grind it here?',
        scenario: 'The shop offers to grind your bag on the counter. Next to the till is a modest hand grinder for about the price of two bags of coffee.',
        question: 'Which way do you go?',
        options: [
          { t: 'Whole bean, and buy the hand grinder', sub: 'Fresh every brew', correct: true },
          { t: 'Have them grind it', sub: 'Convenient now' },
        ],
        right: 'Ground at the counter, the bag starts fading on the walk home. The grinder pays for itself over one bag and keeps paying afterwards.',
        wrong: 'It is genuinely convenient, and by the last cup of the bag you will be drinking something noticeably flatter than the first.',
        note: 'The grinder pays for itself in one bag.' },
      { kind: 'mcq',
        prompt: 'You have no choice but to buy pre-ground. What is the best you can do?',
        choices: [
          { t: 'Smallest bag, sealed, recent roast date — and use it fast', correct: true },
          { t: 'Largest bag available, for the better price per kilo' },
          { t: 'Whichever bag has the longest “best by” date' },
          { t: 'Store it in the freezer door and use it over a year' },
        ],
        explain: 'You cannot stop the clock, so shorten it. Small, sealed, recently roasted, finished quickly.',
      },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'You said ground coffee stales in days. What is the accurate version, and why?',
        choices: [
          { t: 'Minutes — grinding multiplies the exposed surface enormously', correct: true },
          { t: 'Weeks — the grounds are still protected by their oils' },
          { t: 'It does not stale until the bag is opened' },
        ],
        explain: 'Surface area is the mechanism. Thousands of new faces meet the air the instant you grind, and the aromatics start leaving immediately.',
        line: 'Whole beans keep for weeks. Ground coffee keeps for minutes.' },
    ],
    reward: {
      title: 'Freshness',
      summary: 'Why the smell in the room is the flavour leaving the cup.',
      fact: 'Grinding multiplies the exposed surface enormously — staling starts immediately.',
      meta: [['WHOLE BEAN', 'Weeks'], ['GROUND', 'Minutes']],
    },
  },
```
---

## Step 15 — Add `m4l7` to `LESSONS` in `data.jsx`

**Grind 6 — Choosing your first grinder**

```js
  m4l7: {
    moduleLabel: 'MODULE 4 · GRIND',
    title: 'Choosing your first grinder',
    xp: 10, time: 3, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 6', title: 'Choosing your first grinder',
        body: 'You already know to buy a burr. This is the next question — which burr, and what the price step is actually buying.',
        question: 'A hand grinder and an electric grinder at the same price — which grinds better?',
        options: ['The electric', 'The hand grinder'],
        a: 'The hand grinder',
        hold: 'Held. The answer is about where the money went inside the box.' },
      { kind: 'concept', label: 'CONCEPT', title: 'Hand or electric',
        fill: ['At the same price, a hand grinder puts more of the money into the ', { a: 'burrs', o: ['burrs', 'motor'], label: 'Where it goes' }, ' — with an electric you are buying ', { a: 'convenience', o: ['convenience', 'quality'], label: 'What you get' }, ', not grind quality.'],
        paragraphs: [
          'An electric grinder has to pay for a motor, a housing, a hopper and a switch before a single gram goes into the burrs. A hand grinder pays for burrs, a shaft and a handle.',
          'So at any given budget the hand grinder out-grinds the electric. What the electric buys you is thirty seconds of your morning back.',
        ],
        meta: [['HAND', 'More burr per pound'], ['ELECTRIC', 'Convenience']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'What the price step buys',
        fill: ['Paying more buys burr material, burr ', { a: 'alignment', o: ['alignment', 'diameter'], label: 'The quiet one' }, ' and stepless adjustment — not ', { a: 'wattage', o: ['wattage', 'burrs'], label: 'Not this' }, '.'],
        paragraphs: [
          'Alignment is the one nobody markets. If the two burrs are not parallel, the gap varies as they turn and you get a spread no setting can close.',
          'Stepped adjustment gives you fixed clicks; stepless lets you land between them. Wattage and the number of settings printed on the dial tell you almost nothing.',
        ],
        meta: [['PAY FOR', 'Burrs · alignment'], ['IGNORE', 'Wattage']],
      },
      { kind: 'concept', label: 'CONCEPT', title: 'Don’t buy for espresso yet',
        fill: ['Espresso needs a ', { a: 'far finer and more consistent', o: ['far finer and more consistent', 'slightly coarser'], label: 'The grind' }, ' grind, from a ', { a: 'much dearer', o: ['much dearer', 'similar'], label: 'The class of machine' }, ' class of grinder.'],
        paragraphs: [
          'An espresso-capable grinder is a different purchase with a different budget. Buying a filter grinder and hoping it will stretch to espresso ends badly in both directions.',
          'If espresso is the goal, that is a later decision. This lesson is about brewing filter well now.',
        ],
        meta: [['FILTER', 'Entry burr is fine'], ['ESPRESSO', 'A different budget']],
      },
      { kind: 'match',
        prompt: 'Match each budget to what is realistic.',
        pairs: [
          { l: 'Entry',            r: 'A capable hand burr' },
          { l: 'Mid',              r: 'A decent electric burr' },
          { l: 'Espresso-capable', r: 'A different budget entirely' },
          { l: 'Any budget',       r: 'Alignment matters more than size' },
        ],
      },
      { kind: 'decision', label: 'AT THE SHELF', title: 'One cup, every morning',
        scenario: 'Two burr grinders at the same price: a well-regarded hand grinder, and an entry-level electric. You brew one cup each morning, on your own.',
        question: 'Which one?',
        options: [
          { t: 'The hand burr', sub: 'Better burrs for the money', correct: true },
          { t: 'The entry electric', sub: 'Push a button' },
        ],
        right: 'One cup is about thirty seconds of grinding. For that, you get noticeably better burrs and a grind you can actually dial in.',
        wrong: 'The electric earns its price when you brew for several people or in a hurry — not when you brew better.',
        note: 'The electric buys time, not grind quality. Decide which one you are short of.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'Same price, hand versus electric. Why does the hand grinder usually win on grind?',
        choices: [
          { t: 'None of the budget went to a motor and housing, so more of it went to the burrs', correct: true },
          { t: 'Turning by hand is slower, which grinds more evenly' },
          { t: 'Hand grinders use a completely different cutting principle' },
        ],
        explain: 'Same burr geometry, same principle. The difference is how much of the price reached the burrs.',
        line: 'Same money, more of it in the burrs. That’s the whole trade.' },
    ],
    reward: {
      title: 'Your Grinder',
      summary: 'What the money actually buys in a grinder.',
      fact: 'A hand burr grinder usually out-grinds an electric at the same price.',
      meta: [['PAY FOR', 'Burrs · alignment'], ['IGNORE', 'Wattage']],
    },
  },
```
---

## Step 16 — Add `m5l6` to `LESSONS` in `data.jsx`

**Brew 6 — Your first good cup**

```js
  m5l6: {
    moduleLabel: 'MODULE 5 · BREW',
    title: 'Your first good cup',
    xp: 10, time: 5, draft: true,
    cards: [
      { kind: 'predict', label: 'LESSON 6', title: 'Your first good cup',
        body: 'Everything the course has taught, assembled into one brew you actually make. Start with something you will see in about a minute.',
        question: 'You pour the first splash of water onto fresh grounds. They…',
        options: ['Sit flat', 'Swell and bubble up'],
        a: 'Swell and bubble up',
        hold: 'Held. Watch for it — and note whether it happens at all.' },
      { kind: 'practical', tag: 'WHAT YOU NEED', title: 'On the counter',
        paragraphs: [
          'Beans roasted within the month. A grinder. A scale. A brewer with its filter. Water just off the boil.',
          'Nothing here is optional in the sense of being nice to have. Each one removes a guess you would otherwise be making.',
        ],
        note: 'If you are missing the scale, that is the one to fix first. Everything else can be approximated; the weights cannot.' },
      { kind: 'practical', tag: 'STEP 1', title: 'Weigh and grind',
        paragraphs: [
          'Fifteen grams of coffee to two hundred and fifty grams of water. Weigh the beans before you grind them.',
          'Grind for your brewer — medium for a V60, coarse for a press. Grind now, not earlier.',
        ],
        note: 'Weigh the water too, not just the coffee. A scale under the brewer is the whole trick.' },
      { kind: 'practical', tag: 'STEP 2', title: 'Bloom',
        paragraphs: [
          'Pour about thirty grams of water — roughly twice the weight of the coffee — and stop. Wait thirty to forty-five seconds.',
          'The bed will swell and bubble as trapped CO2 escapes. That is the bloom, and it is the coffee telling you it is still fresh.',
        ],
        note: 'If it does not swell, the coffee is old. That is the freshness test from Grind, running in your own kitchen.' },
      { kind: 'practical', tag: 'STEP 3', title: 'Pour and finish',
        paragraphs: [
          'Pour the rest in two or three stages, keeping the bed wet without flooding it. Aim to finish the pour with the water level low, not brimming.',
          'Total time from the first drop to the last drawdown: two and a half to three and a half minutes.',
        ],
        note: 'If it drains much faster or slower than that, the grind is the thing to change — not the pour.' },
      { kind: 'sequence',
        prompt: 'Order the steps.',
        items: [
          { label: 'Weigh the beans', order: 1 },
          { label: 'Grind',           order: 2 },
          { label: 'Bloom',           order: 3 },
          { label: 'Pour in stages',  order: 4 },
          { label: 'Taste',           order: 5 },
        ],
      },
      { kind: 'slider',
        prompt: 'You have 15 g of coffee in the brewer. How much water for the bloom?',
        leftLabel: 'LESS', rightLabel: 'MORE',
        target: 40, tolerance: 10,
        scale: [
          '10 g — barely wets the bed',
          '20 g — patchy',
          '30 g — twice the dose',
          '50 g — you have started brewing',
          '80 g — no bloom at all',
        ],
        feedback: 'About thirty grams — twice the weight of the coffee. Enough to wet everything, not enough to start the brew.' },
      { kind: 'tastefix', tags: ['THIN', 'FAST'],
        prompt: 'It drew through in half the time you expected and tastes watery. What do you change?',
        scenario: 'Fresh beans, right ratio, water just off the boil, the bloom looked healthy.',
        choices: [
          { t: 'Grind finer', correct: true },
          { t: 'Use more water' },
          { t: 'Use hotter water' },
          { t: 'Bloom for longer' },
        ],
        explain: 'A fast drawdown means the water is finding channels through coarse grounds and leaving before it has taken much with it. Finer grounds slow it down and pull more out.',
      },
      { kind: 'decision', label: 'AT THE BREWER', title: 'Drinkable, but flat',
        scenario: 'You made it exactly as written. It is perfectly drinkable and slightly boring.',
        question: 'What do you do tomorrow?',
        options: [
          { t: 'Change one variable and brew again — start with the grind', sub: 'Finer by one step', correct: true },
          { t: 'Change the grind, ratio and water together', sub: 'Save time' },
        ],
        right: 'One change, one result, one thing learned. Grind first because it moves the cup most.',
        wrong: 'Change three things and the cup will be different, but you will have no idea which change did it — so tomorrow you are guessing again.',
        note: 'Change one thing at a time or you learn nothing.' },
      { kind: 'recall', label: 'BEFORE YOU GO',
        question: 'The grounds sat flat when you poured the bloom. What does that tell you?',
        choices: [
          { t: 'The coffee is old — the CO2 that makes the bloom has already escaped', correct: true },
          { t: 'The water was not hot enough' },
          { t: 'You ground it too fine' },
        ],
        explain: 'The bloom is trapped CO2 leaving fresh grounds. A flat bed means there is none left, which means the coffee has been ground or roasted too long ago.',
        line: 'You didn’t buy a better cup. You measured one.' },
    ],
    reward: {
      title: 'Your First Cup',
      summary: 'Every decision in the course, assembled into one brew.',
      fact: 'Weighing the water matters as much as weighing the coffee — most people only do half.',
      meta: [['RATIO', '1:16 — 1:17'], ['TOTAL TIME', '2:30 — 3:30']],
    },
  },
```
---

## Step 17 — Replace `m4l2` in `LESSONS` (7 → 9 cards)

*Grind 2 — Burr vs blade.* A `visual` and a `tastefix` card were inserted after the existing “Why evenness matters” card. Everything else is unchanged.

```js
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
      { kind: 'visual', label: 'VISUAL GUIDE', title: 'One setting, many sizes', variant: 'distribution',
        caption: 'A blade grinder throws a wide, twin-humped spread \u2014 dust at one end, boulders at the other. A burr pulls that into one tight band. Not a single size, though: even a good burr produces a spread. It is just a narrow enough one to dial in.' },
      { kind: 'tastefix', tags: ['BITTER', 'THIN'],
        prompt: 'The cup is harsh and watery at the same time. What would you change first?',
        scenario: 'Fresh beans, right ratio, water just off the boil \u2014 and it still tastes burnt and thin at once.',
        choices: [
          { t: 'Grind more evenly \u2014 use a burr grinder', correct: true },
          { t: 'Grind finer' },
          { t: 'Grind coarser' },
          { t: 'Use hotter water' },
        ],
        explain: 'Harsh and watery together is the spread talking: the dust is over-extracting while the boulders barely extract at all. No dial setting fixes a spread problem \u2014 finer makes the dust worse, coarser makes the boulders worse. The fix is the grinder, not the number.',
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
```
---

## Step 18 — Add 15 entries to `COLLECTION` in `data.jsx`

One collectible per new lesson.

```js
  { id: 'c-m1l4', earned: false, unlock: { lesson: 'm1l4' }, kind: 'map', title: 'Altitude',
    summary: 'Why the number in metres on a bag predicts the cup.',
    fact: 'Most specialty coffee grows between 1,200 and 2,200 metres — high enough to ripen slowly, low enough to avoid frost.',
    meta: [['SPECIALTY BAND', '1,200–2,200 m'], ['MECHANISM', 'Cooler · slower']] },
  { id: 'c-m1l5', earned: false, unlock: { lesson: 'm1l5' }, kind: 'scales', title: 'The Trade',
    summary: 'What the words on a bag promise, and who they promise it to.',
    fact: 'Specialty is a score, not a vibe — 80 or more out of 100, cupped.',
    meta: [['CERTIFIES', 'Price floor'], ['DOES NOT', 'Guarantee quality']] },
  { id: 'c-m1l6', earned: false, unlock: { lesson: 'm1l6' }, kind: 'botanical', title: 'Varieties',
    summary: 'Typica, Bourbon, Geisha — the names behind the cup.',
    fact: 'Almost every Arabica grown today traces back to Typica or Bourbon.',
    meta: [['ANCESTORS', 'Typica · Bourbon'], ['PRIZED', 'Geisha']] },
  { id: 'c-m2l4', earned: false, unlock: { lesson: 'm2l4' }, kind: 'dryingbed', title: 'Drying',
    summary: 'The slow step that decides whether a lot survives the journey.',
    fact: 'Sun drying takes 10–25 days, and naturals run longest because the fruit is still on.',
    meta: [['TARGET', '~11% moisture'], ['TURNED', 'By hand, daily']] },
  { id: 'c-m2l5', earned: false, unlock: { lesson: 'm2l5' }, kind: 'ferment', title: 'Fermentation',
    summary: 'The stage where much of the flavour is actually made.',
    fact: 'Seal the tank and starve it of oxygen, and the same cherry tastes like a different fruit.',
    meta: [['DRIVEN BY', 'Microbes'], ['DIALS', 'Time · oxygen']] },
  { id: 'c-m2l6', earned: false, unlock: { lesson: 'm2l6' }, kind: 'specimen', title: 'Decaf',
    summary: 'How the caffeine comes out, and what stays behind.',
    fact: 'Roughly 97% removed is the bar — a decaf cup still carries a few milligrams.',
    meta: [['METHODS', 'Solvent · water · CO2'], ['REMOVED', '~97%']] },
  { id: 'c-m3l4', earned: false, unlock: { lesson: 'm3l4' }, kind: 'roastscale', title: 'The Roast',
    summary: 'What heat actually does to a green bean.',
    fact: 'First crack arrives around 195–205 °C, when steam pressure pops the bean open.',
    meta: [['BUILDS', 'Aroma · colour'], ['TRADES', 'Acidity for body']] },
  { id: 'c-m3l5', earned: false, unlock: { lesson: 'm3l5' }, kind: 'roastscale', title: 'Light vs Dark',
    summary: 'Two ends of the spectrum, and how to choose between them.',
    fact: 'Caffeine survives roasting — light roasts only win by the scoop because dark beans are less dense.',
    meta: [['LIGHT', 'Origin forward'], ['DARK', 'Roast forward']] },
  { id: 'c-m3l6', earned: false, unlock: { lesson: 'm3l6' }, kind: 'gauge', title: 'Caffeine',
    summary: 'How much is really in the cup in front of you.',
    fact: 'A single espresso carries less caffeine than a mug of drip — concentration is not dose.',
    meta: [['ESPRESSO', '~63 mg'], ['DRIP CUP', '~95 mg']] },
  { id: 'c-m4l5', earned: false, unlock: { lesson: 'm4l5' }, kind: 'spectrum', title: 'Grind & Brewer',
    summary: 'Which grind belongs to which brewer, and why.',
    fact: 'The longer the water sits with the coffee, the coarser the grind has to be.',
    meta: [['RULE', 'Contact time'], ['COARSEST', 'French press']] },
  { id: 'c-m4l6', earned: false, unlock: { lesson: 'm4l6' }, kind: 'hourglass', title: 'Freshness',
    summary: 'Why the smell in the room is the flavour leaving the cup.',
    fact: 'Grinding multiplies the exposed surface enormously — staling starts immediately.',
    meta: [['WHOLE BEAN', 'Weeks'], ['GROUND', 'Minutes']] },
  { id: 'c-m4l7', earned: false, unlock: { lesson: 'm4l7' }, kind: 'burrs', title: 'Your Grinder',
    summary: 'What the money actually buys in a grinder.',
    fact: 'A hand burr grinder usually out-grinds an electric at the same price.',
    meta: [['PAY FOR', 'Burrs · alignment'], ['IGNORE', 'Wattage']] },
  { id: 'c-m5l4', earned: false, unlock: { lesson: 'm5l4' }, kind: 'spectrum', title: 'Extraction',
    summary: 'The one idea behind sour versus bitter.',
    fact: 'The classic target is 18–22% of the coffee dissolved into the water.',
    meta: [['UNDER', 'Sour · thin'], ['OVER', 'Bitter · dry']] },
  { id: 'c-m5l5', earned: false, unlock: { lesson: 'm5l5' }, kind: 'droplet', title: 'The Filter',
    summary: 'Paper, metal or cloth — and what each one keeps out of the cup.',
    fact: 'Paper traps the oils that carry body; metal lets them straight through.',
    meta: [['PAPER', 'Clean · light'], ['METAL', 'Heavy · oily']] },
  { id: 'c-m5l6', earned: false, unlock: { lesson: 'm5l6' }, kind: 'droplet', title: 'Your First Cup',
    summary: 'Every decision in the course, assembled into one brew.',
    fact: 'Weighing the water matters as much as weighing the coffee — most people only do half.',
    meta: [['RATIO', '1:16 — 1:17'], ['TOTAL TIME', '2:30 — 3:30']] }
```
---

## Step 19 — Add 3 entries to `BREW_CHALLENGES` in `brew-challenge.jsx`

`BREW_TOTAL` derives from the array length, so it updates itself.

```js
{ id: 'bc-m2l6', type: 'lesson', lessonId: 'm2l6', moduleId: 'm2', cardId: 'c-m2l6',
    title: 'Blind decaf test',
    instruction: 'Brew a decaf and a regular coffee, then taste them blind and see whether you can actually tell which is which.',
    effort: 'Next brews · 5 min',
    reactions: ['Told them apart', 'Couldn’t tell', 'Only brewed one'] },
{ id: 'bc-m4l6', type: 'lesson', lessonId: 'm4l6', moduleId: 'm4', cardId: 'c-m4l6',
    title: 'Fresh vs pre-ground',
    instruction: 'Grind half your dose now and leave the other half ground overnight. Brew both the same way tomorrow and taste them side by side.',
    effort: 'Next brews · 5 min',
    reactions: ['Fresh was clearly better', 'Close, but fresh won', 'Couldn’t tell'] },
{ id: 'bc-m5l6', type: 'lesson', lessonId: 'm5l6', moduleId: 'm5', cardId: 'c-m5l6',
    title: 'Brew it by the numbers',
    instruction: 'Brew one cup with a scale, a ratio and a timer — exactly as the lesson lays out. Just once, properly.',
    effort: 'Next brew · 5 min',
    reactions: ['Best cup I’ve made', 'Better than usual', 'About the same'] }
```
---

## Design work — not covered by the paste

### 1. Three card-art components are missing

`scales`, `hourglass` and `burrs` are set as the `kind` on three collectibles but exist nowhere in the art registry, so those cards fall back to the generic stamp.

| Collectible | `kind` | Subject |
|---|---|---|
| *The Trade* | `scales` | Certification and price — balance scales |
| *Freshness* | `hourglass` | Time running out on ground coffee |
| *Your Grinder* | `burrs` | Two burr plates |

Add an SVG component alongside the existing `CardArt*` set in `screens.jsx`, then an entry in `CARD_ART` (line 1758) and a tint in `CARD_TINT` (line 1773). Match the existing ones: inline SVG, every colour a theme token, no hardcoded hex.

### 2. Three visual-guide variants are missing

Three `visual` cards point at variants that do not exist. `TrainingCard` does `if (!t) return null`, so they render **silently blank** — no error, just nothing.

| Variant | Used by | Should show |
|---|---|---|
| `variety` | *Why two Ethiopias taste different*, card 4 | Typica and Bourbon branching out to Geisha, Caturra, SL28 |
| `caffeine` | *How much caffeine are you actually drinking?*, card 5 | Per-serving scale — decaf ~3 mg · espresso ~63 mg · drip ~95 mg · cold brew ~200 mg |
| `distribution` | *Burr vs blade*, the added card | A blade grinder's wide twin-humped spread against a burr's tight one |

Add them to the `TRAINING` registry in `practical.jsx` (line 286). Each entry is `{ id, label, title, summary, fact, body: () => (<JSX/>) }` — copy the shape of `roast` or `grind`.

*(`ratio` is also referenced without a renderer. That predates this work.)*

### 3. Dictionary is short by six terms

42 terms against the ~50 intended. `Cultivar` is a full term now; **`Fermentation` is still a stub** and needs deep text, an example, a self-check and sources.

| Term | Category | Source lesson |
|---|---|---|
| `Caffeine` | beans | How much caffeine are you actually drinking? |
| `Decaf` | processing | Decaf, honestly |
| `Swiss Water Process` | processing | Decaf, honestly |
| `Anaerobic` | processing | What happens in the tank |
| `Degassing` | roasting | Why pre-ground never tastes as good |
| `Staling` | roasting | Why pre-ground never tastes as good |

### Also worth knowing

Every collectible is meant to have unique art. The registry is keyed by `kind`, so cards share components — `botanical` draws both *The Coffee Cherry* and *Burr vs Blade*, and the five module Field Guides have no art at all. One design per card means keying by card instead of kind, and drawing the 23 that do not exist. Larger work, not blocking.

## Step 20 — Fix five lesson numbers in `data.jsx`

These five lessons moved position when the modules grew to six, but their opening card still announces the old number. `PredictCard` renders `card.label` as the eyebrow (`active-cards.jsx:23`), so this is visible at the top of each lesson.

In each lesson's **first card** (`kind: 'predict'`), change `label`:

| Lesson | Title | `label` should be |
|---|---|---|
| `m3l1` | Light, medium, dark | `'LESSON 2'` |
| `m3l2` | First and second crack | `'LESSON 3'` |
| `m3l3` | Reading a roast date | `'LESSON 4'` |
| `m4l3` | Dialing in by taste | `'LESSON 4'` |
| `m5l3` | Tasting your cup | `'LESSON 5'` |

---

## Step 21 — Update module counts from 3 to 6

Every module has six lessons now, but two places still say three. Both are rendered on the module Field Guide cards.

**In `COLLECTION`** — the five `kind: 'guide'` entries. Change `['LESSONS', '3']` to `['LESSONS', '6']` in each:

```js
meta: [['MODULE', '01 · Beans'],      ['LESSONS', '6'], ['EARNED BY', 'Finishing Beans']]
meta: [['MODULE', '02 · Processing'], ['LESSONS', '6'], ['EARNED BY', 'Finishing Processing']]
meta: [['MODULE', '03 · Roasting'],   ['LESSONS', '6'], ['EARNED BY', 'Finishing Roasting']]
meta: [['MODULE', '04 · Grind'],      ['LESSONS', '6'], ['EARNED BY', 'Finishing Grind']]
meta: [['MODULE', '05 · Brew'],       ['LESSONS', '6'], ['EARNED BY', 'Finishing Brew']]
```

**In `MODULE_REWARDS`** — all five entries. Change both lines:

```js
['LESSONS', '6'],
['CARDS',   '6 unlocked'],
```

---

## Step 22 — Re-point nine dictionary terms in `dictionary-data.jsx`

Nine terms point at lessons that no longer teach them. `TermDetail` renders a link to the source lesson with its title and completion state (`dictionary.jsx:657`), and a term counts as "learned" once that lesson is complete — so a wrong pointer both mislinks and marks the term learned too early.

Change the `lesson` field on each:

| Term id | Was | Now | Why |
|---|---|---|---|
| `pour-over` | `m5l1` | `m4l5` | *Which grind for which brewer* is where brewers are taught |
| `immersion` | `m5l1` | `m4l5` | " |
| `aeropress` | `m5l1` | `m4l5` | " |
| `chemex` | `m5l1` | `m4l5` | " |
| `single-origin` | `m1l3` | `m1l5` | *What the shelf promises* — the lesson written for these five |
| `fair-trade` | `m1l3` | `m1l5` | " |
| `direct-trade` | `m1l3` | `m1l5` | " |
| `traceability` | `m1l3` | `m1l5` | " |
| `specialty` | `m1l1` | `m1l5` | " |

Giving those last five a home was the reason *What the shelf promises* exists — without this they still point elsewhere.

---
