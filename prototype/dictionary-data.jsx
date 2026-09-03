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
    example: 'Nearly all coffee grown above 1,200 m is arabica; robusta dominates the hot lowlands.',
    related: ['robusta', 'cultivar', 'single-origin'], lesson: 'm1l2',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }, { label: 'SCA — Coffee Basics', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'A supermarket blend advertises “100% arabica”. What does that promise about quality?',
      choices: [{ t: 'Very little', correct: true }, { t: 'That it cupped above 80 points' }, { t: 'That it was grown at altitude' }],
      explain: 'Arabica is a species, and it covers everything from competition lots to the cheapest commodity coffee, so the phrase mostly means “no robusta in it”. Carefully grown robusta beats carelessly grown arabica, which is why the species line tells you less than the roast date and the origin do.' } },

  { id: 'robusta', term: 'Robusta', pron: 'roh-BUST-uh', cat: 'beans',
    short: 'A tougher coffee species with nearly double the caffeine — bolder, more bitter, and easier to farm.',
    deep: 'Coffea canephora (robusta) grows well at low elevations in hot, humid climates and resists disease, so it’s cheaper to produce. It brings heavy body and a grain-like bitterness, and shows up in espresso blends for crema and punch, and in instant coffee.',
    example: 'A little robusta in an espresso blend can deepen the crema and add a caffeine kick.',
    related: ['arabica', 'crema'], lesson: 'm1l2',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'A specialty roaster puts 15% robusta into an espresso blend on purpose. What are they after?',
      choices: [{ t: 'Thicker crema and body', correct: true }, { t: 'More acidity in the shot' }, { t: 'A gentler dose of caffeine' }],
      explain: 'Robusta brings more of the oils and soluble solids that build crema, plus a heavier body — which is why traditional Italian blends use it rather than settling for it. It also carries roughly twice arabica’s caffeine, so a robusta blend is the stronger drink, not the milder one.' } },

  { id: 'cultivar', term: 'Cultivar', pron: 'KUHL-tih-var', cat: 'beans',
    short: 'A cultivated variety of coffee plant, bred or selected for traits like flavour, yield, or disease resistance.',
    deep: 'Think of cultivars the way you think of apple varieties — Bourbon, Typica, Geisha and SL28 are all arabica, but each brings its own character. Some are chosen for cup quality, others for surviving leaf rust.',
    example: '“Geisha” on a label points to a prized cultivar famous for jasmine-like aromatics.',
    related: ['arabica', 'single-origin', 'terroir'], lesson: 'm1l6',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'One bag says “Caturra”, another says “washed”. What kind of fact is Caturra?',
      choices: [{ t: 'The plant’s genetics', correct: true }, { t: 'How the cherries were dried' }, { t: 'How far the roast was taken' }],
      explain: 'A label usually stacks three independent facts: which plant it came from, what the mill did with the fruit, and how dark the roaster took it. Reading a bag well means keeping those apart, because any one of them can dominate the cup.' } },

  { id: 'typica', term: 'Typica', pron: 'TIP-ih-kuh', cat: 'beans',
    short: 'One of the two ancestral arabica varieties — the line most coffee outside Africa descends from.',
    deep: 'Typica travelled out of Yemen and through Java and the Caribbean, seeding plantations across Latin America and Asia. It gives a clean, sweet, elegant cup but yields poorly and catches disease easily, so most farms now grow its descendants rather than Typica itself.',
    example: 'Jamaica Blue Mountain and old Hawaiian Kona plantings are Typica.',
    related: ['bourbon', 'cultivar', 'arabica'], lesson: 'm1l6',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'Typica cups beautifully. Why do so few farms still grow it?',
      choices: [{ t: 'It yields little and gets sick', correct: true }, { t: 'Its flavour went out of fashion with buyers' }, { t: 'It only survives in the Caribbean climate' }],
      explain: 'A variety has to earn its place on the farm as well as in the cup, and a plant that produces small crops and catches disease easily loses that argument however good it tastes. Most of the varieties grown today are descendants chosen to keep the flavour and fix the farming.' } },

  { id: 'bourbon', term: 'Bourbon', pron: 'boor-BON', cat: 'beans', aliases: ['bourbon', 'red bourbon', 'pink bourbon'],
    short: 'The other ancestral arabica variety — sweeter and higher-yielding than Typica, and the parent of Caturra and Catuaí.',
    deep: 'Named for the island of Bourbon (now Réunion), where it was planted separately from the Typica line. It carries more sugar and a rounder body, and mutated into much of what Latin America grows today. Red, yellow, orange and pink Bourbons differ in cherry colour, not in ancestry.',
    example: 'A bag reading “Red Bourbon” is naming this variety, not a whiskey barrel.',
    related: ['typica', 'caturra', 'cultivar'], lesson: 'm1l6',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'Why do almost all the world’s arabica varieties trace back to just two ancestors?',
      choices: [{ t: 'Coffee left Yemen as a few seeds', correct: true }, { t: 'Arabica cannot cross-breed at all' }, { t: 'Growers may only plant certified lines' }],
      explain: 'A handful of plants carried out of Yemen founded nearly every plantation outside Africa, so cultivated arabica is startlingly inbred. That narrow base is why one new disease can threaten crops on three continents, and why breeding programmes keep going back to Ethiopia for wild genetics.' } },

  { id: 'caturra', term: 'Caturra', pron: 'kuh-TOO-ruh', cat: 'beans',
    short: 'A natural dwarf mutation of Bourbon — shorter plants, easier picking, widely grown across Latin America.',
    deep: 'Discovered in Brazil in the early 20th century. Its compact height lets farms plant densely and harvest without ladders, and it keeps much of Bourbon’s sweetness — which is why it spread so fast through Colombia and Central America.',
    example: 'Most Colombian and Costa Rican lots are Caturra or one of its offspring.',
    related: ['bourbon', 'cultivar'], lesson: 'm1l6',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'What did Caturra’s dwarf mutation buy the farms that adopted it?',
      choices: [{ t: 'More trees per hectare', correct: true }, { t: 'Resistance to leaf rust' }, { t: 'Cherries that ripen weeks earlier' }],
      explain: 'The mutation changed the shape of the plant, not its defences — Caturra catches leaf rust as readily as Bourbon does, and breeding rust resistance into the family came later and cost some cup quality. Height, yield, disease and flavour are separate things a farmer has to trade off.' } },

  { id: 'geisha', term: 'Geisha', pron: 'GAY-shuh', cat: 'beans', aliases: ['geisha', 'gesha'],
    short: 'A famously floral, tea-like variety — the most expensive coffee on most shelves, and a fussy, low-yielding plant.',
    deep: 'Collected in Ethiopia, held in collections for decades, then made famous when a Panamanian farm won a 2004 competition with it. At the right altitude it gives jasmine and bergamot aromatics unlike anything else; grown too low it is unremarkable. The plant yields little, so the price is real rather than pure hype.',
    example: 'A bag reading “Geisha” costs several times a neighbouring lot from the same farm.',
    related: ['cultivar', 'specialty', 'terroir'], lesson: 'm1l6',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'Geisha breaks auction records year after year. What most explains the price?',
      choices: [{ t: 'Fussy trees, small crops', correct: true }, { t: 'It is sorted bean by bean by hand' }, { t: 'Only farms in Panama are allowed to grow it' }],
      explain: 'Price comes from scarcity meeting demand: the trees are tall, fragile and low-yielding, so there is never much of it. Geisha also needs altitude and careful handling to show its jasmine character — planted low and processed carelessly, it cups unremarkably.' } },

  { id: 'sl28', term: 'SL28', pron: 'S-L twenty-eight', cat: 'beans', aliases: ['sl28', 'sl 28', 'sl34', 'sl-series'],
    short: 'A Kenyan variety selected in the 1930s, behind the blackcurrant acidity Kenyan coffee is known for.',
    deep: 'The “SL” is Scott Laboratories, the Nairobi station that selected it — SL28 and SL34 were the two that stuck. SL28 is drought-tolerant and deep-rooted but vulnerable to leaf rust, and it is grown almost entirely in Kenya, which is why the flavour reads as a country signature.',
    example: 'A Nyeri lot listing SL28 is the classic Kenyan profile.',
    related: ['cultivar', 'acidity'], lesson: 'm1l6',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'Blackcurrant acidity gets called a Kenyan signature rather than an SL28 one. Why?',
      choices: [{ t: 'SL28 is grown almost only in Kenya', correct: true }, { t: 'Kenyan soil makes the flavour, whatever the variety' }, { t: 'Kenya does not allow other varieties to be planted' }],
      explain: 'When one country holds nearly all the plantings of a variety, people credit the country for what the plant is doing. Grow SL28 elsewhere and the profile largely travels with it, which is the test that separates variety from place.' } },

  { id: 'heirloom', term: 'Heirloom', cat: 'beans', aliases: ['heirloom', 'landrace', 'landraces'],
    short: 'A catch-all for Ethiopia’s thousands of wild and local arabica types, where no single variety name is recorded.',
    deep: 'Ethiopia is arabica’s birthplace, and its coffee grows as mixed local populations rather than named, catalogued varieties. “Heirloom” on a bag is honest but vague — it tells you the coffee is Ethiopian and genetically diverse, not what to expect in the cup. Region and processing are the more useful lines on that bag.',
    example: '“Yirgacheffe, heirloom, washed” — the region and process carry the information.',
    related: ['cultivar', 'terroir', 'single-origin'], lesson: 'm1l6',
    sources: [{ label: 'World Coffee Research — Arabica Catalog', url: 'https://varieties.worldcoffeeresearch.org/arabica' }],
    check: { q: 'A bag reads “Ethiopia, heirloom”. What have you learned about how it will taste?',
      choices: [{ t: 'Almost nothing', correct: true }, { t: 'That it is a single variety kept by one family' }, { t: 'That it was picked from wild forest trees' }],
      explain: 'Heirloom is a true statement about genetics rather than a promise about flavour: it says the trees are a mixed local population nobody has catalogued. On an Ethiopian bag, the region and the processing are the lines that predict the cup.' } },

  { id: 'cherry', term: 'Coffee Cherry', cat: 'beans', aliases: ['cherry', 'cherries', 'coffee cherry'],
    short: 'The fruit of the coffee plant. Each cherry usually holds two seeds — the “beans” we roast.',
    deep: 'A coffee bean is a seed, and the cherry is the fruit it grew in: skin, sweet pulp, sticky mucilage, then two seeds pressed flat against each other. Sugar builds up in the fruit while it hangs on the branch, and nobody further down the chain can add it later — so an unripe cherry gives the mill and the roaster nothing to work with. It takes about five to six kilos of cherry to make one kilo of green coffee.',
    example: 'A branch ripens unevenly, which is why hand-picked lots get walked several times in a season.',
    related: ['arabica', 'bean-belt', 'peaberry'], lesson: 'm1l1',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'A picker strips a branch, ripe and unripe cherries together. What does that cost the lot?',
      choices: [{ t: 'Sweetness the fruit never built', correct: true }, { t: 'Nothing much; roasting evens ripeness out' }, { t: 'Caffeine, which forms only as fruit ripens' }],
      explain: 'Ripeness is decided on the branch. The mill can sort out the worst cherries and the roaster can do a careful job, but neither one adds sugar that was never there. The caffeine is in the seed either way, so what you lose is sweetness, not strength.' } },

  { id: 'peaberry', term: 'Peaberry', pron: 'PEE-beh-ree', cat: 'beans', aliases: ['peaberry', 'peaberries', 'pea berry', 'caracolillo'],
    short: 'A single round seed from a cherry that grew only one — sorted into its own lot, and priced as if that were a grade.',
    deep: 'A cherry normally sets two seeds that flatten against each other. When only one of the two ovules is fertilised, the lone seed grows with nothing to press it flat, so it comes out small, round and dense. It happens in roughly 5% of cherries, on the same branches as everything else — it is not a variety, and nobody can plant it. Mills sieve peaberries out because round, dense beans move and take heat differently in a roaster, which is a real reason to keep them apart and a poor reason to expect a better cup.',
    example: '“Tanzania Peaberry” names the shape of the bean in the bag, not a cupping score.',
    related: ['cherry', 'cultivar', 'specialty'], lesson: 'm1l5',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }, { label: 'Perfect Daily Grind — What Are Peaberry Coffee Beans?', url: 'https://perfectdailygrind.com/2020/03/what-are-peaberry-coffee-beans-the-myths-the-reality/' }],
    check: { q: 'What has happened inside a cherry that produces a peaberry?',
      choices: [{ t: 'Only one seed was fertilised', correct: true }, { t: 'A farmer plants the peaberry variety' }, { t: 'A bean cracks in half during roasting' }],
      explain: 'One seed, nothing to flatten it, so it grows round. It is chance inside an ordinary cherry — which is why a peaberry lot has to be sieved out rather than grown.' } },
  { id: 'bean-belt', term: 'Bean Belt', cat: 'beans', aliases: ['bean belt'],
    short: 'The band around the equator, roughly 25°N to 25°S, where coffee grows best.',
    deep: 'Coffee needs a narrow climate: arabica likes an average of about 18–22 °C and no frost at all. Those conditions sit either side of the equator. Height and latitude are two ways to reach them — farms on the equator climb high for cool nights, while farms near the edges of the belt find the same temperatures much lower down. A warming climate is pushing that window uphill, which is one reason altitude now appears on so many bags.',
    example: 'Kenyan farms on the equator sit near 1,700 m; Brazilian ones at 20°S grow well below 1,200 m.',
    related: ['cherry', 'terroir', 'masl'], lesson: 'm1l1',
    sources: [{ label: 'Foods (MDPI) — Does Coffee Have Terroir and How Should It Be Assessed?', url: 'https://www.mdpi.com/2304-8158/11/13/1907' }],
    check: { q: 'Why do Kenyan farms sit so much higher than Brazilian ones?',
      choices: [{ t: 'Altitude supplies the cool it needs', correct: true }, { t: 'Kenyan soil is only fertile high up' }, { t: 'Arabica needs thin air to ripen properly' }],
      explain: 'Height and distance from the equator both get you to the same cool temperatures. It is also why “high grown” means different numbers in different countries.' } },
  { id: 'terroir', term: 'Terroir', pron: 'tair-WAHR', cat: 'beans',
    short: 'The sense of place in a cup — how soil, altitude and climate shape a coffee’s flavour.',
    deep: 'Terroir is the whole growing environment turning up in the cup: altitude, soil, rainfall, shade, and how far the temperature drops overnight. Cooler, higher farms ripen their cherries slowly, and slow ripening is the usual explanation for denser beans with more acidity and more going on. Coffee has no legal definition of terroir the way wine does — and a heavy roast or a bold processing style will drown it out.',
    example: 'Two farms on one Colombian slope, 300 m apart in height, cup differently every harvest.',
    related: ['single-origin', 'cultivar', 'masl'], lesson: 'm1l3',
    sources: [{ label: 'Foods (MDPI) — Does Coffee Have Terroir and How Should It Be Assessed?', url: 'https://www.mdpi.com/2304-8158/11/13/1907' }],
    check: { q: 'A roaster says a coffee “tastes of its terroir”. What has to hold steady for that to mean anything?',
      choices: [{ t: 'Roast, grind and brew method', correct: true }, { t: 'Nothing: terroir survives any roast' }, { t: 'The variety, since terroir is really genetics' }],
      explain: 'Terroir is a claim about a place, so everything that happens after the farm has to stay the same before you can taste it. Variety is a separate thing: that is genetics, not ground.' } },

  { id: 'masl', term: 'MASL', pron: 'M-A-S-L', cat: 'beans', aliases: ['masl', 'm.a.s.l.', 'metres above sea level', 'meters above sea level'],
    short: 'Metres above sea level — a shorthand some bags print instead of writing out the growing altitude.',
    deep: 'Nothing more than a unit label: “1,900 masl” means grown at 1,900 metres. It is trade shorthand rather than something you need to say out loud, and plenty of bags skip it and print “1,900 m” or feet instead. What matters is the number, and that there is one at all — a specific altitude is a quality signal, no altitude tells you nothing.',
    example: '“1,900 masl” and “grown at 1,900 metres” mean exactly the same thing.',
    related: ['bean-belt', 'terroir', 'specialty'],
    check: { q: 'One bag says “1,900 masl”, another “1,900 m”. Which grew higher?',
      choices: [{ t: 'Neither — they are the same', correct: true }, { t: 'The masl one, measured from sea level' }, { t: 'Impossible to say without the country' }],
      explain: 'MASL is only a unit label, so the two bags say the same thing in different shorthand. What is worth noticing is whether a specific number is printed at all: a precise altitude means somebody kept records, and no altitude tells you nothing either way.' } },

  { id: 'mucilage', term: 'Mucilage', pron: 'MYOO-sih-lij', cat: 'processing',
    short: 'The sticky, sugary gel glued to the coffee seed under the fruit — the layer processing is really about.',
    deep: 'Mucilage sits between the pulp and the parchment and won’t rinse off with water alone: it either ferments loose or dries onto the seed. How much of it stays on while the coffee dries is the whole difference between washed, honey and natural.',
    example: 'Leave the mucilage on and its sugars ferment into berry and body; rinse it off and the cup turns clean and bright.',
    related: ['parchment', 'silverskin', 'washed', 'natural', 'honey', 'fermentation'], lesson: 'm1l7',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }, { label: 'Perfect Daily Grind — Processing 101', url: 'https://perfectdailygrind.com/2016/07/washed-natural-honey-coffee-processing-101/' }],
    check: { q: 'What becomes of the mucilage in a washed coffee?',
      choices: [{ t: 'It is rinsed off after fermenting', correct: true }, { t: 'It dries onto the bean in the sun' }, { t: 'It comes away later with the parchment' }],
      explain: 'Washed, honey and natural are really three answers to one question: what happens to this sticky layer. Wash it off and you taste the seed and its origin; leave it on and you taste what fermented in place.' } },

  { id: 'parchment', term: 'Parchment', cat: 'processing', aliases: ['parchment', 'pergamino'],
    short: 'The papery shell around a coffee seed. Coffee rests and ships inside it, then is hulled before export.',
    deep: 'Once the fruit and mucilage are gone, the seed is still wrapped in this dry husk, which protects it during storage. Hulling — removing the parchment — usually happens as late as possible, just before the coffee leaves for the roaster.',
    example: 'A lot sold “in parchment” hasn’t been hulled yet — it’s still wearing layer 04.',
    related: ['mucilage', 'silverskin', 'washed'], lesson: 'm1l7',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'Why do mills leave hulling as late as they can?',
      choices: [{ t: 'The husk protects the seed in storage', correct: true }, { t: 'Hulling early strips out flavour compounds' }, { t: 'Coffee has to be shipped in parchment by law' }],
      explain: 'Parchment is packaging the plant already supplied, so coffee keeps better inside it and comes out later. The same thinking runs through the whole chain: leave a protective layer on until the moment it is in the way.' } },

  { id: 'silverskin', term: 'Silverskin', cat: 'beans', aliases: ['silverskin', 'silver skin', 'chaff'],
    short: 'The tissue-thin membrane on a green bean. Most of it lifts off in the roaster as chaff.',
    deep: 'Silverskin is the last layer between parchment and seed. Roasting dries it and it flakes away as chaff, which roasters collect and discard — except in the centre crease, where a little usually stays behind. On naturals that trapped silverskin often looks stained.',
    example: 'Those papery flakes in the bottom of a home roaster are silverskin, not burnt coffee.',
    related: ['parchment', 'center-cut', 'mucilage'], lesson: 'm1l7',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'A home roaster fills its chaff tray on every batch. What does that mean?',
      choices: [{ t: 'Nothing is wrong', correct: true }, { t: 'The roast is running too hot' }, { t: 'The beans were dried badly at origin' }],
      explain: 'Every batch loses its silverskin, so chaff is a sign the roast is working rather than a fault. It is worth clearing out for a duller reason: dry chaff near a heating element is a fire risk, which is why roasters have collectors at all.' } },

  { id: 'center-cut', term: 'Centre Cut', cat: 'beans', aliases: ['centre cut', 'center cut', 'centre crease', 'center crease'],
    short: 'The S-shaped crease down the flat face of a bean, where it was pressed against its twin inside the cherry.',
    deep: 'The centre cut is the first thing graders look at. It traps leftover silverskin, so it also records how the coffee was processed: pale and clean on a washed lot, often stained amber or reddish on a natural where fruit sugar dried in place.',
    example: 'Tip beans onto a white plate and read the crease — pale usually means washed, stained usually means natural.',
    related: ['silverskin', 'mucilage', 'natural', 'washed'], lesson: 'm1l7',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'How can a crease in the bean carry any information about processing?',
      choices: [{ t: 'It traps silverskin, which stains', correct: true }, { t: 'It deepens the longer a coffee ferments' }, { t: 'Washed beans are hulled before the crease forms' }],
      explain: 'The crease is a pocket, so whatever dried in there stayed behind: fruit sugars on a natural, clean water on a washed lot. Graders read appearance for clues like this all the time, and treat them as clues rather than proof — a carefully washed natural can look almost clean.' } },

  { id: 'caffeine', term: 'Caffeine', pron: 'kaf-EEN', cat: 'beans',
    short: 'The natural stimulant in coffee — around 95 mg in a mug of drip, and far less in a single espresso.',
    deep: 'Caffeine is the plant’s built-in pesticide, and how much lands in your cup depends on species, brew and serving size. Robusta carries roughly twice arabica’s share, and a long steep plus a big glass is why cold brew often tops the chart while a small espresso sits well below a mug of drip. Roasting barely touches it: what changes is the bean, which loses moisture and swells, so a dark roast weighs less per scoop and brews weaker measured that way — and much the same measured by weight.',
    example: 'A 30 ml espresso (~63 mg) delivers less caffeine than a 240 ml mug of drip (~95 mg).',
    related: ['decaf', 'robusta', 'arabica'], lesson: 'm3l6',
    sources: [{ label: 'USDA — FoodData Central', url: 'https://fdc.nal.usda.gov/' }],
    check: { q: 'Does a dark roast contain less caffeine than a light one?',
      choices: [{ t: 'Barely any difference', correct: true }, { t: 'Yes — roasting burns caffeine off' }, { t: 'Yes, and light roasts have almost none' }],
      explain: 'Caffeine survives roasting almost untouched, so bean for bean the two are close. The confusion comes from measuring: dark beans are less dense, so a scoop of them holds fewer beans and brews weaker, while the same weight brews much the same.' } },

  // ── PROCESSING ───────────────────────────────────────────
  { id: 'washed', term: 'Washed Process', cat: 'processing', aliases: ['washed process', 'washed'],
    short: 'The fruit is stripped and the seeds are fermented and rinsed clean before drying — giving a clean, bright cup.',
    deep: 'Also called the “wet” process. Removing the fruit early lets the bean’s own character and acidity shine, with less of the fruit’s influence. It needs plenty of water and careful fermentation control.',
    example: 'Washed Kenyans are famous for their crisp, almost blackcurrant-like acidity.',
    related: ['natural', 'honey', 'fermentation'], lesson: 'm2l1',
    sources: [{ label: 'Perfect Daily Grind — Processing 101', url: 'https://perfectdailygrind.com/2016/07/washed-natural-honey-coffee-processing-101/' }],
    check: { q: 'Why do buyers often ask for a washed sample when judging a new farm?',
      choices: [{ t: 'It hides the least', correct: true }, { t: 'It removes any defective beans' }, { t: 'It is the only process buyers can score' }],
      explain: 'Taking the fruit off early leaves the seed and the place it grew with nowhere to hide — flaws included. It is a clearer window, not a better process: a well-made natural can score higher, it just tells you more about the mill.' } },

  { id: 'natural', term: 'Natural Process', cat: 'processing', aliases: ['natural process', 'dry process', 'naturals', 'natural'],
    short: 'The whole cherry is dried with the fruit still on, pushing fruity, sometimes wine-like sweetness into the bean.',
    deep: 'The oldest method: cherries dry in the sun for weeks before the dried fruit is removed. It uses little water but demands constant turning to avoid mould. Results are heavier-bodied and fruit-forward.',
    example: 'A natural Ethiopian can taste of blueberry and ripe strawberry.',
    related: ['washed', 'honey', 'fermentation'], lesson: 'm2l1',
    sources: [{ label: 'Perfect Daily Grind — Processing 101', url: 'https://perfectdailygrind.com/2016/07/washed-natural-honey-coffee-processing-101/' }],
    check: { q: 'Naturals taste boldly fruity. What has to go right for that not to turn into a defect?',
      choices: [{ t: 'Careful, even drying', correct: true }, { t: 'A longer ferment in the tank first' }, { t: 'A darker roast to cover any rough edges' }],
      explain: 'Whole cherries dry slowly with all their sugar attached, so the same fruit that gives strawberry and jam gives mould and rot if the beds are heaped or left unturned. Thin layers, constant raking and the discipline to accept a slower dry are what separate a great natural from a dirty one.' } },

  { id: 'honey', term: 'Honey Process', cat: 'processing', aliases: ['honey process'],
    short: 'A middle path: some fruit pulp is left on the bean during drying, balancing sweetness and clarity.',
    deep: 'The skin and some pulp are removed, but the sticky layer underneath — the mucilage — is left on the seed while it dries. There is no honey in it; the name describes how the wet seed feels. Producers grade the result by colour: yellow honey dries fastest and cleanest, red takes longer, black is slowest and sweetest. More mucilage left on means more sugar fermenting in place, and more risk of mould if the beds are not turned often enough.',
    example: '“Black honey” means most of the mucilage stayed on through a long, shaded dry.',
    related: ['washed', 'natural', 'mucilage'], lesson: 'm2l1',
    sources: [{ label: 'Barista Magazine — Understanding the Process: Honey', url: 'https://www.baristamagazine.com/understanding-the-process-part-three-honey-process/' }, { label: 'Perfect Daily Grind — Processing 101', url: 'https://perfectdailygrind.com/2016/07/washed-natural-honey-coffee-processing-101/' }],
    check: { q: 'A bag says “red honey”. What are you being told?',
      choices: [{ t: 'How much mucilage stayed on', correct: true }, { t: 'That honey was added during processing' }, { t: 'That the coffee was roasted medium-dark' }],
      explain: 'Honey grades describe how much mucilage was left on and how slowly it dried. Nothing is added, and it says nothing about the roast. Washed and natural sit at the two ends of that same dial.' } },
  { id: 'fermentation', term: 'Fermentation', pron: 'fur-men-TAY-shun', cat: 'processing',
    short: 'The controlled breakdown of the cherry’s sugars that develops flavour during processing.',
    deep: 'Every coffee ferments — microbes eat the sticky, sugary mucilage off the seed whether the method is washed, natural or honey. What producers control is time, temperature and oxygen: careful, short ferments keep a cup clean; long or sealed ones push it fruity, winey, even boozy.',
    example: 'An “anaerobic natural” on a label means the cherries fermented in a sealed tank — expect loud, winey fruit.',
    related: ['washed', 'natural', 'anaerobic'], lesson: 'm2l5',
    sources: [{ label: 'Perfect Daily Grind — Fermentation Guides' }],
    check: { q: 'A tank runs twelve hours longer than the mill planned. What is the risk?',
      choices: [{ t: 'Boozy, vinegary flavours', correct: true }, { t: 'The seeds take up too much water' }, { t: 'The caffeine ferments away' }],
      explain: 'Fermentation is a window rather than a switch: stop early and mucilage clings on, run long and the microbes push past fruit into alcohol and acetic acid. Judging when to stop, by feel and by taste, is most of the skill in a wet mill.' } },

  { id: 'anaerobic', term: 'Anaerobic Fermentation', cat: 'processing', aliases: ['anaerobic', 'anaerobic fermentation'],
    short: 'Fermenting cherries in sealed, oxygen-free tanks — slower microbes, louder and funkier flavours.',
    deep: 'Cherries or depulped seeds ferment in sealed tanks. With the oxygen gone the usual microbes cannot work, CO₂ builds up, and a different set of yeasts and bacteria takes over. Because the producer sets the time and temperature instead of leaving it to the weather, the loud, wine-like flavours come out the same way batch after batch. It is the newest style on most shelves, and the easiest to push too far.',
    example: 'A sealed ferment of several days before drying is what puts “cinnamon, plum” on a competition bag.',
    related: ['fermentation', 'natural', 'honey'], lesson: 'm2l5',
    sources: [{ label: 'PMC — Effect of processing method (natural, washed, honey, fermentation, maceration) on specialty coffee', url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC10848008/' }],
    check: { q: 'What does sealing the tank actually change?',
      choices: [{ t: 'Which microbes can work', correct: true }, { t: 'The temperature, which drives all fermentation' }, { t: 'Nothing chemical — it keeps rain and insects off' }],
      explain: 'Sealing the tank swaps one set of microbes for another, so you get different byproducts and a different cup. The real prize is control: a sealed ferment repeats in a way that open tanks in the sun never will.' } },
  { id: 'decaf', term: 'Decaf', cat: 'processing', aliases: ['decaf', 'decaffeinated'],
    short: 'Coffee with roughly 97% of its caffeine removed as green beans, before roasting — almost none, never zero.',
    deep: 'Decaffeination is a processing step applied to green coffee, months before roasting. Solvent methods use ethyl acetate or methylene chloride; Swiss Water and CO₂ methods use none. All leave a few milligrams per cup — close to nothing, but not nothing.',
    example: 'A “sugarcane decaf” from Colombia was decaffeinated with ethyl acetate derived from cane.',
    related: ['swiss-water', 'caffeine', 'fermentation'], lesson: 'm2l6',
    sources: [{ label: 'SCA — Coffee Basics', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'Why can’t a café make an ordinary coffee decaf on request?',
      choices: [{ t: 'Caffeine goes before roasting', correct: true }, { t: 'A shorter brew would leave the caffeine behind' }, { t: 'A coarser grind extracts almost none of it' }],
      explain: 'Decaffeination happens at the green stage, in a factory, long before a bag reaches a café. Brewing tricks do not help either: caffeine is very soluble and comes out early, so a short brew is weak coffee with most of its caffeine intact.' } },
  { id: 'swiss-water', term: 'Swiss Water Process', cat: 'processing', aliases: ['swiss water', 'swiss water process'],
    short: 'A solvent-free decaffeination method that pulls caffeine out of green beans with water and a carbon filter.',
    deep: 'Green beans are soaked in green coffee extract: water already full of everything coffee is made of, except caffeine. Because the water is already loaded with flavour compounds, those stay in the bean, while the caffeine has somewhere to go and leaves. Activated carbon then filters the caffeine out of the water so the same extract can be used again. No solvent ever touches the coffee. Decaf is never caffeine-free, though — US rules set the bar at 97% removed, and Swiss Water reports 99.9%.',
    example: 'Single origins are usually decaffeinated this way, because origin character survives it best.',
    related: ['decaf', 'caffeine', 'green-coffee'], lesson: 'm2l6',
    sources: [{ label: 'Barista Magazine — Understanding the Process: Swiss Water Decaffeination', url: 'https://www.baristamagazine.com/understanding-the-process-swiss-water-decaffeination/' }],
    check: { q: 'Why soak the beans in coffee extract instead of plain water?',
      choices: [{ t: 'Water would carry flavour out too', correct: true }, { t: 'Extract dissolves caffeine faster than water' }, { t: 'The extract swaps in sugars for the caffeine' }],
      explain: 'Every water-based decaf works this way: give a compound nowhere to go and it stays where it is. These methods are judged on what they leave behind, not on what they take out.' } },
  { id: 'green-coffee', term: 'Green Coffee', cat: 'processing', aliases: ['green coffee', 'green bean', 'green beans'],
    short: 'Coffee as it leaves the farm and ships: dried, hulled, unroasted seeds — pale green, hard, and smelling of hay.',
    deep: 'Everything before the roaster happens to green coffee, and everything after is the roaster’s work on it. Green keeps for months in a sack, which is why it, not roasted coffee, is what gets graded, traded and shipped.',
    example: 'A roaster buys green coffee by the sack and roasts it in small batches to order.',
    related: ['parchment', 'washed', 'first-crack', 'specialty'], lesson: 'm1l7',
    sources: [{ label: 'National Coffee Association — Storage and shelf life', url: 'https://www.aboutcoffee.org/beans/storage-and-shelf-life/' }],
    check: { q: 'A roaster’s green coffee has sat in the warehouse for eight months. Is that a problem?',
      choices: [{ t: 'Not in itself', correct: true }, { t: 'Yes — it stales like roasted coffee does' }, { t: 'Yes, unless it was kept refrigerated' }],
      explain: 'Green coffee keeps for many months in cool, dry, stable conditions; it fades slowly, losing acidity and sweetness over a year or more, and the trade calls it past crop. The fast clock starts at roasting, which is why the roast date is the date on the bag that matters.' } },
  { id: 'washing-station', term: 'Washing Station', cat: 'processing', aliases: ['washing station', 'wet mill'],
    short: 'The shared site where a village’s cherries are pulped, fermented, washed and dried — often the real author of a coffee’s cup.',
    deep: 'Smallholders rarely process their own cherries. They deliver to a station, which does the work for hundreds of farms at once — so on a Kenyan or Ethiopian bag, the station name is the closest thing to a producer name you get.',
    example: 'Two Ethiopian lots from the same hillside can taste different because they went to different stations.',
    related: ['washed', 'fermentation', 'traceability'], lesson: 'm1l3',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'A station replaces its drying beds. Whose coffee gets better?',
      choices: [{ t: 'Every farm that delivers there', correct: true }, { t: 'Only the farms that helped pay for them' }, { t: 'Nobody — drying happens back at the farm' }],
      explain: 'One station processes the cherries of hundreds of growers, so an improvement there lifts all of them at once. That leverage is why buyers who want better coffee fund equipment and training at the station rather than farm by farm.' } },
  { id: 'wet-hulled', term: 'Wet-Hulled', cat: 'processing', aliases: ['wet-hulled', 'wet hulled', 'wet-hulling', 'wet hulling', 'giling basah'],
    short: 'An Indonesian method where the parchment comes off while the bean is still damp — the source of that earthy, heavy Sumatran cup.',
    deep: 'Elsewhere coffee dries fully inside its parchment; here it is hulled part-dried, at high moisture, and finishes drying bare. It is a response to a wet climate that never gives you enough dry days, and it turns the beans a distinctive jade colour.',
    example: 'A wet-hulled Sumatra reads as earthy, herbal and cedar-like, with very low acidity.',
    related: ['parchment', 'washed', 'body'],
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'Why did Sumatran mills start hulling coffee while it was still damp?',
      choices: [{ t: 'The climate never gives enough dry days', correct: true }, { t: 'Buyers asked for the earthy, low-acid taste' }, { t: 'Damp parchment attracts insects in storage' }],
      explain: 'Wet-hulling is a workaround for humidity: get the parchment off early and the bare bean finishes drying far faster. The famous earthy, herbal cup is a side effect of that necessity, not a flavour anyone set out to create.' } },

  // ── ROASTING ─────────────────────────────────────────────
  { id: 'first-crack', term: 'First Crack', cat: 'roasting', aliases: ['first crack'],
    short: 'The audible pop during roasting when beans expand and steam escapes — the threshold of a drinkable roast.',
    deep: 'As beans heat, moisture turns to steam and pressure builds until the bean cracks open, like popcorn. First crack marks the start of light-roast territory; how far past it you go decides light, medium, or dark.',
    example: 'Pulling beans just after first crack gives a bright, light roast.',
    related: ['second-crack', 'roast-level', 'development'], lesson: 'm3l2',
    sources: [{ label: 'Scott Rao — The Coffee Roaster’s Companion' }],
    check: { q: 'What is making the noise at first crack?',
      choices: [{ t: 'Steam splitting the bean', correct: true }, { t: 'Sugars caramelising inside' }, { t: 'Oils bursting out of the cells' }],
      explain: 'Water in the bean flashes to steam and the pressure cracks it audibly, like popcorn on a small scale. Because it is a physical event at a fairly predictable point, roasters use it as the landmark they time the rest of the roast from.' } },

  { id: 'roast-level', term: 'Roast Level', cat: 'roasting', aliases: ['roast level'],
    short: 'How far a coffee is roasted — light, medium, or dark — which shapes acidity, body and bitterness.',
    deep: 'Lighter roasts keep more origin character and acidity; darker roasts trade that for body, bitterness and roasty notes. Neither is “better” — it’s a flavour choice.',
    example: 'A light roast tastes of the bean; a dark roast tastes more of the roast.',
    related: ['first-crack', 'second-crack', 'roast-date'], lesson: 'm3l1',
    sources: [{ label: 'SCA — Coffee Standards', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'Two roasters both call their coffee “medium”. Why can the cups be nothing alike?',
      choices: [{ t: 'Nobody defines medium', correct: true }, { t: 'One of them used a hotter machine' }, { t: 'One roasted a much larger batch' }],
      explain: 'Roast names are relative to whatever else a roaster sells, and no standard fixes them — one house’s medium is another’s light. That is why the trade measures roast colour with a meter and a number when it needs to agree on anything.' } },

  { id: 'second-crack', term: 'Second Crack', cat: 'roasting', aliases: ['second crack'],
    short: 'A second, quieter cracking deeper into the roast that marks the edge of dark-roast territory.',
    deep: 'Deeper into the roast the cell walls break down again. It is quieter and faster than first crack — a crackle rather than a pop — and oils start working their way to the surface of the bean. Past that point you are in dark-roast territory: bittersweet, smoky, low in acidity, tasting more of the roast than of where it grew. Oil on the outside of the bean also turns rancid sooner, which is why dark roasts keep for less time.',
    example: 'Beans that look glossy in the bag went at least as far as second crack.',
    related: ['first-crack', 'roast-level', 'staling'], lesson: 'm3l2',
    sources: [{ label: 'Scott Rao — The Coffee Roaster’s Companion' }],
    check: { q: 'What does a sheen of oil on the beans tell you?',
      choices: [{ t: 'The roast reached second crack', correct: true }, { t: 'The beans are especially fresh' }, { t: 'The lot was natural, not washed' }],
      explain: 'Oil on the surface tells you how far the roast went, not how fresh the beans are or how they were processed. If anything it means the coffee will fade sooner.' } },
  { id: 'development', term: 'Development Time', cat: 'roasting', aliases: ['development time', 'development'],
    short: 'The stretch after first crack that balances the inside and outside of the bean.',
    deep: 'Development is the time between first crack and the moment the roaster drops the beans, while the heat finishes working through to the middle of each bean. Cut it short and the inside never catches up with the outside: the cup tastes grassy, hollow and drying. That is pale coffee, not bright coffee. Roasters track development as a share of the whole roast rather than as a temperature, because what matters is the proportion.',
    example: 'Roasters talk about development as a ratio — often around a fifth to a quarter of the whole roast.',
    related: ['first-crack', 'roast-level'], lesson: 'm3l4',
    sources: [{ label: 'Scott Rao — The Coffee Roaster’s Companion' }],
    check: { q: 'Brewed to a recipe you trust, a light roast still tastes grassy and hollow. What is the fault?',
      choices: [{ t: 'Dropped too soon after first crack', correct: true }, { t: 'Taken too dark for its origin' }, { t: 'A blend rather than a single origin' }],
      explain: 'The colour tells you where the roast stopped. Development tells you whether the middle of the bean caught up. People mix up “light” and “underdeveloped” all the time, and only one of the two is a fault.' } },
  { id: 'roast-date', term: 'Roast Date', cat: 'roasting', aliases: ['roast date'],
    short: 'When the coffee was roasted — fresher is better; aim to brew within a few weeks.',
    deep: 'The roast date is the only date on a bag that measures anything. A best-before date is chosen by whoever packed the coffee, often a year ahead, and tells you nothing about when it was roasted. Whole beans are usually at their best from a few days after roasting, once the worst of the degassing is over, until a few weeks after. A bag with no roast date on it is telling you something too.',
    example: '“Roasted 9 days ago” is a fact; “best before March 2027” is a shelf-life promise.',
    related: ['roast-level', 'degassing', 'staling'], lesson: 'm3l3',
    sources: [{ label: 'National Coffee Association — Storage and shelf life', url: 'https://www.aboutcoffee.org/beans/storage-and-shelf-life/' }],
    check: { q: 'One bag is best-before in eight months; another was roasted eleven days ago. Which is the better bet?',
      choices: [{ t: 'The dated one — you know where it sits in its life', correct: true }, { t: 'The best-before one, which guarantees eight months of freshness' }, { t: 'Neither matters as long as the beans are whole' }],
      explain: 'Freshness is really the distance from the roast, and only a roast date measures that. Keeping the beans whole slows the decline, but it does not reset the clock.' } },
  { id: 'degassing', term: 'Degassing', cat: 'roasting', aliases: ['degassing', 'degas'],
    short: 'Roasted beans releasing built-up CO₂ for days after roasting — the gas behind the bloom.',
    deep: 'Roasting traps carbon dioxide inside the bean, and it leaks out for days or weeks afterwards — fastest in the first few days, and much faster once the coffee is ground. Brew too early and the escaping gas stops the water soaking the grounds evenly. Wait too long and the aromas have drifted off along with it. Filter coffee usually wants a few days of rest; espresso wants rather more.',
    example: 'Espresso pulled the day after roasting gushes crema and tastes thin — the gas is in the way.',
    related: ['roast-date', 'staling', 'bloom', 'co2'], lesson: 'm3l3',
    sources: [{ label: 'Food Research International — Roasting conditions and CO₂ degassing behaviour', url: 'https://www.sciencedirect.com/science/article/abs/pii/S0963996914000337' }, { label: 'J. Agric. Food Chem. — Time-resolved gravimetric assessment of coffee degassing', url: 'https://pubs.acs.org/doi/10.1021/acs.jafc.7b03310' }],
    check: { q: 'Why does very fresh coffee often brew unevenly?',
      choices: [{ t: 'CO₂ blocks even wetting', correct: true }, { t: 'Fresh beans are harder, so grind coarser' }, { t: 'The oils have not yet reached the surface' }],
      explain: 'The bloom is that gas escaping where you can see it. Resting the coffee gives up a little aroma in exchange for an even extraction. Espresso gets the longer rest because the water only has seconds to do its work, not minutes.' } },
  { id: 'co2', term: 'CO₂', pron: 'C-O-two', cat: 'roasting', aliases: ['co2', 'co₂', 'carbon dioxide'],
    short: 'Carbon dioxide — the gas roasting traps inside the bean, and the reason fresh grounds bloom.',
    deep: 'Roasting generates carbon dioxide and locks it in the bean, which then leaks out for days or weeks afterwards. That escaping gas is what makes fresh grounds swell in the bloom, what fills the valve on a bag, and part of what builds crema on an espresso shot. As it leaves, oxygen and moisture take its place — which is staling.',
    example: 'A bag with a one-way valve is letting CO₂ out without letting air in.',
    related: ['degassing', 'bloom', 'staling', 'crema'], lesson: 'm4l6',
    sources: [{ label: 'SCA — Coffee Standards', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'Why do coffee bags have a little plastic valve?',
      choices: [{ t: 'To let CO₂ escape', correct: true }, { t: 'To let air in and soften the beans' }, { t: 'To stop the bag being crushed in transit' }],
      explain: 'Fresh coffee gives off enough gas to swell a sealed bag until it bursts, and the valve lets that out while keeping oxygen from coming back in. It is a neat summary of storing coffee: gas out, air never in.' } },

  { id: 'staling', term: 'Staling', cat: 'roasting', aliases: ['staling', 'stale'],
    short: 'Flavour fading as oxygen gets at the coffee — slow for whole beans, fast once ground.',
    deep: 'Staling is oxidation, not gas escaping: oxygen reacts with the oils and aromas in the coffee, and heat, light and damp all speed that up. Whole beans hold on for weeks. Ground coffee fades within days, because grinding exposes far more surface to the air. Stale coffee tastes papery, woody and flat.',
    example: 'Grinding a week’s worth on Sunday costs more flavour than buying cheaper beans would.',
    related: ['degassing', 'roast-date', 'co2'], lesson: 'm4l6',
    sources: [{ label: 'National Coffee Association — Storage and shelf life', url: 'https://www.aboutcoffee.org/beans/storage-and-shelf-life/' }],
    check: { q: 'You can change one thing about how you store coffee. Which does the most?',
      choices: [{ t: 'Grind only what you brew', correct: true }, { t: 'Move the bag into the fridge' }, { t: 'Decant into a clear jar on the counter' }],
      explain: 'Exposed surface is what drives staling, so grinding at the last minute does more than anything else you can change. The fridge adds moisture and a clear jar lets light in, and both speed up the same reaction.' } },

  // ── BREWING ──────────────────────────────────────────────
  { id: 'bloom', term: 'Bloom', cat: 'brewing',
    short: 'The first splash of water on fresh grounds, which releases trapped CO₂ and makes the bed swell and bubble.',
    deep: 'Fresh coffee is full of carbon dioxide. Wetting it for 30–45 seconds before the main pour lets that gas escape, so water can extract evenly instead of channelling around bubbles.',
    example: 'A vigorous bloom is a good sign your coffee is fresh.',
    related: ['extraction', 'brew-ratio', 'pour-over'], lesson: 'm5l6',
    sources: [{ label: 'James Hoffmann — Technique Guides' }],
    check: { q: 'How long should you let a bloom run?',
      choices: [{ t: 'Half a minute or so', correct: true }, { t: 'Until every bubble has stopped, however long that takes' }, { t: 'Two to three minutes, like a steep' }],
      explain: 'Thirty to forty-five seconds gets the gas that would otherwise be in the way; waiting for the last bubble just cools the bed and drags the brew out. Older coffee blooms feebly, and that is a reason to shorten the pause, not to lengthen it.' } },

  { id: 'brew-ratio', term: 'Brew Ratio', cat: 'brewing', aliases: ['brew ratio'],
    short: 'The proportion of coffee to water — the single biggest lever on strength, often written like 1:16.',
    deep: 'A 1:16 ratio means 1 gram of coffee to 16 grams of water. Lower numbers (1:12) brew stronger; higher (1:18) brew lighter. Dial this to taste before fiddling with anything else.',
    example: '60 g of coffee to 1,000 g of water is a classic ~1:16 batch-brew ratio.',
    related: ['extraction', 'tds', 'bloom'], lesson: 'm5l1',
    sources: [{ label: 'SCA — Brewing Control Chart', url: 'https://sca.coffee/sca-news/25/issue-13/towards-a-new-brewing-chart' }],
    check: { q: 'You double both the coffee and the water. What happens to the strength?',
      choices: [{ t: 'Nothing', correct: true }, { t: 'It doubles' }, { t: 'It halves' }],
      explain: 'Strength follows the ratio between the two, not the size of the brew, so scaling both up gives you more of the same coffee. It is why recipes are written as ratios: 1:16 travels from one cup to a whole batch.' } },

  { id: 'extraction', term: 'Extraction', cat: 'brewing', aliases: ['extraction', 'over-extraction', 'under-extraction', 'over-extracted', 'under-extracted', 'overextracted', 'underextracted'],
    short: 'How much flavour is dissolved out of the grounds — too little tastes sour, too much tastes bitter.',
    deep: 'Water pulls compounds out of coffee in an order: fruity acids first, sweetness next, bitter and dry notes last. The sweet spot — “even extraction” — is the goal of grinding, ratio and time.',
    example: 'Sour, weak coffee is usually under-extracted; harsh, dry coffee is over-extracted.',
    related: ['brew-ratio', 'tds', 'bloom'], lesson: 'm5l4',
    sources: [{ label: 'SCA — Brewing Control Chart', url: 'https://sca.coffee/sca-news/25/issue-13/towards-a-new-brewing-chart' }],
    check: { q: 'Can a cup be over-extracted and weak at the same time?',
      choices: [{ t: 'Yes', correct: true }, { t: 'No — over-extracted always means strong' }, { t: 'No, they are two words for one thing' }],
      explain: 'Extraction is how much you pulled out of the grounds; strength is how concentrated what landed in the cup is. Far too much water over a fine grind gives you both at once: bitter and drying, and still thin.' } },

  { id: 'tds', term: 'TDS', pron: 'T-D-S', cat: 'brewing', aliases: ['tds', 'total dissolved solids'],
    short: 'Total Dissolved Solids — the measured number for how strong a brew is, read as a percentage.',
    deep: 'TDS is the share of the cup that is dissolved coffee rather than water, measured with a refractometer. Filter coffee usually lands between 1.15% and 1.45%; espresso runs far higher, around 8–12%. It answers “how strong”, not “how well extracted” — the same TDS can come from a good ratio or from over-extracting too little coffee, which is why it is always read alongside the brew ratio.',
    example: 'A cup at 1.20% TDS is weaker than one at 1.40% — but neither number tells you whether it tastes good.',
    related: ['extraction', 'brew-ratio', 'sca'],
    sources: [{ label: 'SCA — Brewing Control Chart', url: 'https://sca.coffee/sca-news/25/issue-13/towards-a-new-brewing-chart' }],
    check: { q: 'Two brews read exactly the same TDS. Will they taste the same?',
      choices: [{ t: 'Not necessarily', correct: true }, { t: 'Yes — TDS is the measure of taste' }, { t: 'Yes, as long as the beans match' }],
      explain: 'TDS only says how concentrated the cup is, and you can arrive at one number by very different routes: a fine grind rushed through, or a coarse one steeped long. Strength is a number, extraction is what you took out of the grounds, and only tasting tells you whether it was the right amount.' } },
  { id: 'pour-over', term: 'Pour-Over', cat: 'brewing', aliases: ['pour-over', 'pour over'],
    short: 'Brewing by pouring hot water through grounds in a filter cone, like a V60 or Chemex.',
    deep: 'Water passes through the bed of grounds once and drains away — nothing sits and steeps. That means the contact time is a result of your grind and how fast you pour, rather than a number you choose. It is the control people love pour-over for, and the reason it is easy to get wrong. Paper holds back most of the oils and fine particles, so the cup tastes clean and light.',
    example: 'Same coffee, same ratio: a slower pour and a finer grind taste noticeably stronger.',
    related: ['bloom', 'immersion', 'gooseneck', 'v60'], lesson: 'm5l6',
    sources: [{ label: 'National Coffee Association — Brewing', url: 'https://www.aboutcoffee.org/brewing/' }],
    check: { q: 'What makes pour-over harder to repeat than a French press?',
      choices: [{ t: 'You set the flow, so time varies', correct: true }, { t: 'The water has to be hotter' }, { t: 'Paper filters strip flavour unpredictably' }],
      explain: 'With a press, the time is fixed: four minutes is four minutes. With a pour-over the time is an outcome of your own choices, which gives you more control and more to keep steady.' } },
  { id: 'immersion', term: 'Immersion', cat: 'brewing',
    short: 'Brewing by steeping grounds fully in water, like a French press, then separating them.',
    deep: 'The grounds sit in the full volume of water for a set time, then get separated out — plunged, filtered or poured off. Because the clock is doing the work, immersion is forgiving of an uneven grind: the bigger particles have the whole steep to catch up with the small ones. A metal mesh lets oils and fine particles through, and that is where the heavier body comes from.',
    example: 'Cold brew and a French press are the same idea run at different temperatures.',
    related: ['pour-over', 'french-press', 'cold-brew', 'grind-size'], lesson: 'm4l5',
    sources: [{ label: 'National Coffee Association — Brewing', url: 'https://www.aboutcoffee.org/brewing/' }],
    check: { q: 'Which method is kindest to someone without a good grinder?',
      choices: [{ t: 'Immersion — time evens it out', correct: true }, { t: 'Pour-over, if you pour more slowly' }, { t: 'Espresso, where pressure compensates' }],
      explain: 'Particles of different sizes extract at different speeds. A long steep closes that gap; pressure widens it. Espresso is the harshest test of a grinder there is.' } },
  { id: 'cold-brew', term: 'Cold Brew', cat: 'brewing', aliases: ['cold brew', 'cold-brew'],
    short: 'Coffee steeped in cold water for 12–24 hours instead of brewed hot — smooth, low-acid, and strong.',
    deep: 'Cold water pulls out sugars and caffeine but leaves most of the bright acids and bitter compounds behind, which is why it tastes round and chocolatey. It is usually brewed as a concentrate and diluted, so a serving carries more caffeine than a mug of drip.',
    example: 'A 1:8 concentrate steeped overnight, then cut with water or milk to taste.',
    related: ['immersion', 'extraction', 'caffeine'],
    sources: [{ label: 'National Coffee Association — Brewing', url: 'https://www.aboutcoffee.org/brewing/' }],
    check: { q: 'Is cold brew a lower-caffeine drink than drip coffee?',
      choices: [{ t: 'Usually the opposite', correct: true }, { t: 'Yes — cold water extracts less caffeine' }, { t: 'Yes — the long steep breaks caffeine down' }],
      explain: 'Cold water is slower, but twelve to twenty-four hours more than makes up for it, and cold brew is normally made as a concentrate. Smooth and low in acidity gets read as mild, and mildness is not the same measurement as strength.' } },

  // ── ESPRESSO ─────────────────────────────────────────────
  { id: 'espresso', term: 'Espresso', pron: 'es-PRESS-oh', cat: 'espresso', aliases: ['espresso', 'espresso shot'],
    short: 'A small, concentrated coffee pulled by forcing hot water through finely ground coffee under about 9 bars of pressure.',
    deep: 'Not a roast level and not a bean — a brewing method. Pressure does in 25–30 seconds what a filter brew takes minutes to do, giving a syrupy cup several times stronger than drip, topped with crema. Everything milk drinks are built on starts here.',
    example: 'A typical modern shot: 18 g of coffee in, ~36 g of liquid out, in about 28 seconds.',
    related: ['crema', 'portafilter', 'dialing-in', 'extraction'], lesson: 'm5l7',
    sources: [{ label: 'Perfect Daily Grind — Espresso Basics', url: 'https://perfectdailygrind.com/2020/04/crema-how-its-formed-what-it-tells-us-how-to-learn-from-it/' }],
    check: { q: 'A café sells a dark blend labelled “espresso roast”. Does espresso need a dark roast?',
      choices: [{ t: 'No', correct: true }, { t: 'Yes — light roasts will not extract under pressure' }, { t: 'Yes, or no crema forms' }],
      explain: 'Espresso is a method — pressure through finely ground coffee — so any roast can go through it, and light-roast espresso is now standard in specialty cafés. Dark roasts became the convention because they extract easily and forgive an imprecise grinder, not because the machine requires them.' } },
  { id: 'dialing-in', term: 'Dialling In', cat: 'espresso', aliases: ['dialling in', 'dialing in', 'dial in', 'dialled in', 'dialed in'],
    short: 'Adjusting the grind until a shot runs in the time you want and tastes right — the daily ritual of espresso.',
    deep: 'You hold the dose and the target output steady and move only the grind: finer slows the shot and pushes extraction up, coarser speeds it up. Fresh coffee, humidity and the bag’s age all shift it, so yesterday’s setting rarely survives today.',
    example: 'The shot ran in 18 seconds and tasted sour, so you grind finer and pull again.',
    related: ['espresso', 'grind-size', 'extraction', 'channeling'], lesson: 'm4l3',
    sources: [{ label: 'Barista Hustle — espresso technique guides' }],
    check: { q: 'Why does yesterday’s grind setting so often need moving today?',
      choices: [{ t: 'The coffee itself has changed', correct: true }, { t: 'The burrs shift position as they spin' }, { t: 'The machine cools overnight and brews weaker' }],
      explain: 'A bag ages by a day, loses more gas, and takes up whatever moisture is in the air, so the same setting meets slightly different coffee. Dialling in is following a target that keeps moving, which is why you change one thing — the grind — and leave dose and yield alone.' } },
  { id: 'crema', term: 'Crema', pron: 'KREH-muh', cat: 'espresso',
    short: 'The reddish-brown foam on top of an espresso shot, made of emulsified oils and CO₂.',
    deep: 'Crema forms when pressurised water forces oils and gases into a fine emulsion. It’s a sign of fresh coffee and a well-pulled shot, though it isn’t the whole story of quality.',
    example: 'A thick, hazelnut-coloured crema usually means fresh beans and a good extraction.',
    related: ['portafilter', 'robusta', 'channeling'], lesson: 'm5l7',
    sources: [{ label: 'Perfect Daily Grind — Espresso Basics', url: 'https://perfectdailygrind.com/2020/04/crema-how-its-formed-what-it-tells-us-how-to-learn-from-it/' }],
    check: { q: 'A shot pulls with thin, pale crema. What is the likeliest cause?',
      choices: [{ t: 'The coffee is old', correct: true }, { t: 'The water ran too hot' }, { t: 'The grind was set too fine' }],
      explain: 'Crema is an emulsion held up by dissolved CO₂, so it thins out as coffee ages and loses gas. It reads freshness, not quality — dark roasts and robusta blends pile up thick crema over a shot that may taste of very little.' } },

  { id: 'portafilter', term: 'Portafilter', pron: 'POR-tuh-fil-ter', cat: 'espresso',
    short: 'The handled basket that holds the coffee grounds and locks into an espresso machine.',
    deep: 'You grind into the portafilter, distribute and tamp the grounds level, then lock it into the group head. Even, well-tamped coffee in the basket is the key to an even shot.',
    example: 'Knocking the spent puck out of the portafilter is the satisfying clack you hear in cafés.',
    related: ['crema', 'tamp', 'channeling'], lesson: 'm5l7',
    sources: [{ label: 'Perfect Daily Grind — Espresso Basics', url: 'https://perfectdailygrind.com/2020/04/crema-how-its-formed-what-it-tells-us-how-to-learn-from-it/' }],
    check: { q: 'Why do baristas leave the portafilter locked into the machine between shots?',
      choices: [{ t: 'To keep the metal hot', correct: true }, { t: 'To stop the rubber seal drying out' }, { t: 'To keep water off the shower screen' }],
      explain: 'A cold basket steals heat from the water in the first seconds of a shot, which is exactly when extraction is fastest. Espresso is unforgiving about temperature, so a lot of café habit is really about keeping metal at a steady heat.' } },

  { id: 'cortado', term: 'Cortado', pron: 'kor-TAH-doh', cat: 'espresso',
    short: 'An espresso “cut” with a small, equal amount of warm milk to soften it.',
    deep: 'Cortado means “cut”: a shot cut with roughly its own volume of warm steamed milk, and hardly any foam. The ratio is the whole point — enough milk to take the edge off the acidity and bitterness, not enough to bury the coffee. That ratio is also the main thing separating one café milk drink from another.',
    example: 'A cortado runs about 1:1 espresso to milk; a latte can be 1:5 or looser.',
    related: ['crema', 'espresso'], lesson: 'm5l7',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'What separates a cortado from a latte?',
      choices: [{ t: 'The ratio, near equal parts', correct: true }, { t: 'The milk is warmed but never steamed' }, { t: 'It is pulled as a longer, weaker shot' }],
      explain: 'Milk drinks mostly differ in one way: how much milk goes in per shot. The names are ratios, not different kinds of coffee.' } },
  { id: 'channeling', term: 'Channeling', cat: 'espresso',
    short: 'When water forces a path through cracks in the espresso puck, extracting unevenly.',
    deep: 'Water takes the easiest route through the coffee, floods it, and leaves the rest of the bed barely brewed — which is how one shot manages to taste sour and bitter at the same time. The causes are all in the puck rather than the machine: clumps, cracks, grounds spread unevenly, or a tamp that went in at an angle. Look at the spent puck afterwards and you will see streaks or small craters.',
    example: 'Sour and harsh in the same sip is the signature; a shot that merely ran fast is a different problem.',
    related: ['portafilter', 'tamp', 'extraction', 'fines'], lesson: 'm5l7',
    sources: [{ label: 'Barista Hustle — espresso technique guides' }],
    check: { q: 'A shot tastes sour and bitter at the same time. What does that point to?',
      choices: [{ t: 'Channelling in the puck', correct: true }, { t: 'A grind that is simply too fine' }, { t: 'Water that is too cool' }],
      explain: 'A mistake that affects the whole puck evenly pushes the cup one way or the other. Two opposite faults at once mean parts of the bed brewed and parts did not — that is how you prepared it, not where the grinder is set.' } },
  { id: 'tamp', term: 'Tamp', cat: 'espresso',
    short: 'Pressing the espresso grounds flat and firm in the portafilter for an even shot.',
    deep: 'Tamping presses the grounds into a level bed so the water meets the same resistance everywhere. Level matters more than hard: once the press is firm and even, pushing harder changes very little, while a tamp that sits a degree or two off level sends water down one side. It also cannot fix badly spread grounds — clumps pressed flat are still clumps.',
    example: 'Baristas practise tamping level rather than hard; the puck should end up like a polished floor.',
    related: ['portafilter', 'channeling', 'espresso'], lesson: 'm5l7',
    sources: [{ label: 'Barista Hustle — espresso technique guides' }],
    check: { q: 'Which does more for a shot — tamping harder, or tamping level?',
      choices: [{ t: 'Level', correct: true }, { t: 'Harder — tamp pressure sets the shot time' }, { t: 'Neither, once the basket is full to the rim' }],
      explain: 'How much resistance the puck gives comes mostly from the grind and the dose. How even it is comes from your hands. Water goes wherever the bed is weakest, so a flat tamp is the part worth practising.' } },

  // ── SENSORY VOCABULARY ───────────────────────────────────
  { id: 'acidity', term: 'Acidity', cat: 'sensory',
    short: 'The bright, tangy liveliness in coffee — pleasant acidity tastes crisp, like citrus or apple, not sour.',
    deep: 'Acidity is a positive quality in tasting language, distinct from “sour” (a fault of under-extraction). High-grown washed coffees tend to be the most acidic, in a sparkling, mouth-watering way.',
    example: 'A Kenyan’s juicy, blackcurrant acidity is what fans love about it.',
    related: ['body', 'balance', 'finish'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Flavor Wheel and Lexicon', url: 'https://sca.coffee/sca-news/how-to-use-the-flavor-wheel-in-eight-steps' }],
    check: { q: 'A cup tastes sour and thin. Is that its acidity?',
      choices: [{ t: 'No, it is under-extracted', correct: true }, { t: 'Yes — a naturally high-acidity coffee' }, { t: 'Yes — the roast was too light for the bean' }],
      explain: 'Acidity is a bright, structured quality with sweetness behind it; sourness is an empty, puckering taste that means the water never got enough out of the grounds. The test is whether anything else came with it — bright coffee tastes of fruit, sour coffee tastes of nothing much.' } },

  { id: 'body', term: 'Body', cat: 'sensory',
    short: 'How heavy or full a coffee feels in your mouth — from tea-like and light to syrupy and thick.',
    deep: 'Also called mouthfeel. Body comes from oils and fine particles suspended in the brew. A French press feels heavier than a paper-filtered pour-over because the filter holds less back.',
    example: 'Naturals and dark roasts often feel fuller-bodied.',
    related: ['mouthfeel', 'acidity', 'balance'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Flavor Wheel and Lexicon', url: 'https://sca.coffee/sca-news/how-to-use-the-flavor-wheel-in-eight-steps' }],
    check: { q: 'Does taking a roast darker always give you more body?',
      choices: [{ t: 'No', correct: true }, { t: 'Yes — roasting builds body all the way' }, { t: 'Yes, once the oils reach the surface' }],
      explain: 'Body climbs through medium roasts and then falls away in the darkest ones, where the structure has broken down and the cup can taste thin and ashy under all that smoke. Weight in the mouth comes from dissolved solids and what stays suspended, which is why the brewer and filter often matter more than the roast.' } },

  { id: 'mouthfeel', term: 'Mouthfeel', cat: 'sensory',
    short: 'The texture and weight of coffee on your tongue — another word for body.',
    deep: 'Mouthfeel is what you feel rather than what you taste: the weight, the texture, how thick the coffee is. It comes from dissolved solids plus whatever oils and fine particles are still floating in the cup, so the filter you brew through changes it more than the coffee itself does. Cuppers score it in its own section, separate from flavour.',
    example: 'The same coffee is silkier from a press than through paper — same beans, same ratio.',
    related: ['body', 'balance', 'finish'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Evolving the cupping protocol and form', url: 'https://sca.coffee/sca-news/read/evolving-the-sca-cupping-protocol-and-form-an-overview-of-the-pilot-testing-process' }],
    check: { q: 'Where does a French press get its heavier mouthfeel?',
      choices: [{ t: 'Oils and fines through the mesh', correct: true }, { t: 'A larger dose of coffee per cup' }, { t: 'A darker roast level' }],
      explain: 'Texture and strength are two different things. Swap paper for a metal mesh and the body changes even though the recipe has not. It is the cheapest experiment in brewing.' } },
  { id: 'finish', term: 'Finish', cat: 'sensory', aliases: ['finish', 'aftertaste'],
    short: 'The flavour that lingers after you swallow — short and clean, or long and sweet.',
    deep: 'The finish — cuppers call it aftertaste — is what is left once you have swallowed: how long it lasts, and whether it stays pleasant. Good coffee fades away sweet and clean. Tired or badly brewed coffee turns papery, drying or ashy a few seconds later. It gets its own score because a cup can taste lovely at first and then fall apart.',
    example: 'Wait ten seconds after swallowing before judging it — the finish arrives late by definition.',
    related: ['acidity', 'balance', 'mouthfeel'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Evolving the cupping protocol and form', url: 'https://sca.coffee/sca-news/read/evolving-the-sca-cupping-protocol-and-form-an-overview-of-the-pilot-testing-process' }],
    check: { q: 'A cup tastes fine, then turns dry and papery ten seconds later. What have you learned?',
      choices: [{ t: 'It is probably stale', correct: true }, { t: 'That it was under-extracted' }, { t: 'Nothing gradeable — that is preference' }],
      explain: 'Different faults show up at different points in a sip, which is why the first taste and the finish are scored separately. Papery and woody are the words for stale coffee; astringent and ashy point at a brewing problem instead.' } },
  { id: 'balance', term: 'Balance', cat: 'sensory',
    short: 'How well a coffee’s sweetness, acidity, body and bitterness fit together.',
    deep: 'Balance asks whether the parts fit together — acidity, sweetness, body, bitterness, finish — not whether any one of them is quiet. A powerful coffee can be balanced, and a dull one can be unbalanced. Cuppers score it after the individual qualities, because it is a judgement about how those relate to each other.',
    example: 'A searing Kenyan acidity carried by enough sweetness scores well; the same acidity alone does not.',
    related: ['acidity', 'body', 'finish', 'mouthfeel'], lesson: 'm5l3',
    sources: [{ label: 'SCA — Evolving the cupping protocol and form', url: 'https://sca.coffee/sca-news/read/evolving-the-sca-cupping-protocol-and-form-an-overview-of-the-pilot-testing-process' }],
    check: { q: 'Which is better balanced — a fierce, very acidic Kenyan whose sweetness carries it, or a mild cup with nothing sticking out?',
      choices: [{ t: 'The Kenyan', correct: true }, { t: 'The mild one; nothing dominates it' }, { t: 'Unanswerable without measuring extraction' }],
      explain: 'Balance is about how the parts relate, so a cup with very little in it has very little to balance. Strength and harmony are separate judgements: plenty of bold coffees are perfectly harmonious.' } },
  { id: 'cupping', term: 'Cupping', cat: 'sensory', aliases: ['cupping', 'cupping table', 'cup score'],
    short: 'The industry’s standard tasting method: same grind, same water, no filter — slurped from a spoon and scored.',
    deep: 'Grounds steep in a bowl, the crust is broken, and tasters slurp across many bowls side by side. Holding every variable but the coffee still lets buyers compare lots fairly, and the 100-point score that comes out of it is what puts a coffee above the specialty line.',
    example: 'A lot cupping at 86 points will be sold as specialty; one at 78 goes to commodity blends.',
    related: ['acidity', 'balance', 'specialty', 'sca'],
    sources: [{ label: 'SCA — Cupping Protocols', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'Why does cupping fix the grind, water and time for every bowl?',
      choices: [{ t: 'So the only difference left is the coffee', correct: true }, { t: 'Because it is the best-tasting way to brew' }, { t: 'Because it copies how customers brew at home' }],
      explain: 'Cupping is a comparison tool, not a recipe: hold everything else still and any difference between bowls has to come from the lots. Nobody claims it makes the nicest cup — a filterless bowl of steeped coffee is the price of a fair test.' } },

  // ── EQUIPMENT ────────────────────────────────────────────
  { id: 'burr-grinder', term: 'Burr Grinder', cat: 'equipment', aliases: ['burr grinder', 'grinder', 'grinders', 'burr', 'burrs'],
    short: 'A grinder that crushes beans between two burrs for an even, adjustable grind — the single best brewing upgrade.',
    deep: 'Unlike blade grinders that chop randomly, burrs produce uniform particles, which is essential for even extraction. The gap between the burrs sets how fine or coarse you grind.',
    example: 'Switching from a blade to a burr grinder is the upgrade most people notice first.',
    related: ['grind-size', 'extraction', 'scale'], lesson: 'm4l2',
    sources: [{ label: 'James Hoffmann — Gear Guides' }],
    check: { q: 'Is the advantage of burrs that they keep the coffee cooler than blades?',
      choices: [{ t: 'No, it is evenness', correct: true }, { t: 'Yes — blades scorch the grounds' }, { t: 'Yes, because burrs turn more slowly' }],
      explain: 'Grinding a few doses at home barely warms the coffee; what blades really do is chop at random, leaving boulders and dust in the same batch. Burrs crush to a set gap, and particles of one size extract at one speed.' } },

  { id: 'gooseneck', term: 'Gooseneck Kettle', cat: 'equipment', aliases: ['gooseneck kettle', 'gooseneck'],
    short: 'A kettle with a long, curved spout that gives slow, precise control over your pour.',
    deep: 'The narrow spout lets you place water exactly where you want it and control the flow rate — important for even pour-over brewing and a controlled bloom.',
    example: 'A gooseneck makes it easy to pour in slow, steady spirals over the grounds.',
    related: ['pour-over', 'bloom', 'scale'],
    sources: [{ label: 'James Hoffmann — Gear Guides' }],
    check: { q: 'Do you need a gooseneck kettle for a French press?',
      choices: [{ t: 'No', correct: true }, { t: 'Yes, to wet the grounds evenly' }, { t: 'Yes, or the pour disturbs the bed' }],
      explain: 'Pour control earns its keep where your pouring sets the brew time — a cone, a dripper, anything you build up in stages. In immersion brewing everything ends up in the same water for the same four minutes, so how you got it in there hardly matters.' } },

  { id: 'aeropress', term: 'AeroPress', pron: 'AIR-oh-press', cat: 'equipment',
    short: 'A compact plunger brewer that uses gentle pressure to make a quick, clean cup.',
    deep: 'A chamber, a paper or metal filter, and a plunger. The coffee steeps for a short time, then you press it through in seconds. As it comes out of the box that press is gentle — around a bar, against the nine or so a machine uses for espresso — so it mostly speeds up the drain, and what you get is a short, clean immersion brew. Add-on caps with a pressure valve change that: they hold the brew back until the pressure builds, and a fine grind and tight ratio then give you a concentrated, foam-topped shot much closer to espresso. It travels well and is forgiving about grind, which is most of the reason people love it.',
    example: 'Two minutes of steep and a slow twenty-second press is a good default recipe.',
    related: ['immersion', 'pour-over', 'grind-size', 'espresso'], lesson: 'm4l5',
    sources: [{ label: 'AeroPress — official brew guides', url: 'https://aeropress.com/pages/brew-guides' }, { label: 'James Hoffmann — Technique Guides' }],
    check: { q: 'Two people brew the same beans in an AeroPress, one with a valve cap fitted. Why is only one cup espresso-like?',
      choices: [{ t: 'The valve holds pressure back', correct: true }, { t: 'The valve raises the brewing temperature' }, { t: 'The valve doses more coffee in' }],
      explain: 'A plain AeroPress lets water through as you push, so pressure never gets a chance to build and the result behaves like filter coffee. A valve makes the brew wait, and pressure is what pulls out the concentration and foam people recognise as espresso.' } },
  { id: 'chemex', term: 'Chemex', pron: 'KEM-ex', cat: 'equipment',
    short: 'An hourglass-shaped pour-over brewer using thick filters for an exceptionally clean cup.',
    deep: 'An hourglass of heatproof glass with a thick, folded paper filter. That paper is heavier than most, so it holds back more oil and fine particles and slows the drain down as it does. The cup comes out unusually clean and tea-like, and the thick paper is why Chemex recipes ask for a coarser grind than a V60 at the same dose.',
    example: 'Grind a notch coarser than you would for a V60, or the brew stalls in the paper.',
    related: ['pour-over', 'v60', 'mouthfeel'], lesson: 'm4l5',
    sources: [{ label: 'James Hoffmann — Technique Guides' }],
    check: { q: 'Why do Chemex recipes ask for a coarser grind than a V60?',
      choices: [{ t: 'Thick paper drains slowly', correct: true }, { t: 'Its cone angle is steeper' }, { t: 'It holds more water at once' }],
      explain: 'The grind has to suit how fast the brewer drains. Thick paper already slows the flow, so a fine grind on top of that stalls the bed and over-extracts whatever does get through. The same paper does two things at once: it slows the drain and it cleans up the cup.' } },
  { id: 'v60', term: 'V60', pron: 'V-sixty', cat: 'equipment', aliases: ['v60', 'v-60'],
    short: 'A cone-shaped pour-over dripper with a 60° angle and spiral ribs — the default filter brewer in most cafés.',
    deep: 'Made by Hario. The single large hole means you, not the cone, control the flow: pour rate and grind size decide the brew time. It rewards a medium grind and a steady pour, and it is the brewer most recipes online are written for.',
    example: 'Most pour-over recipes you find assume a V60 unless they say otherwise.',
    related: ['pour-over', 'chemex', 'gooseneck', 'grind-size'], lesson: 'm4l5',
    sources: [{ label: 'Hario — V60 brewing instructions' }],
    check: { q: 'What are the spiral ribs inside the cone for?',
      choices: [{ t: 'Keeping the paper off the wall', correct: true }, { t: 'Slowing the water on its way down' }, { t: 'Stiffening the cone so it resists heat' }],
      explain: 'The ribs hold a gap between filter and cone so air can escape and the brew keeps draining; press wet paper flat against a smooth wall and it seals, and the water stops. Most brewer design is small tricks like this for managing flow.' } },
  { id: 'french-press', term: 'French Press', cat: 'equipment', aliases: ['french press', 'cafetière', 'cafetiere', 'press pot'],
    short: 'A steeping jug with a mesh plunger — grounds sit in the water the whole time, giving a heavy, full-bodied cup.',
    deep: 'The simplest good brewer there is: coarse grind, four minutes, press slowly. Metal mesh lets oils and fine particles through where paper would trap them, which is exactly why it feels thicker than a pour-over.',
    example: 'Coarse grind, 1:15, four minutes, then press and pour it all out so it stops brewing.',
    related: ['immersion', 'body', 'grind-size', 'fines'], lesson: 'm4l5',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'Why decant a French press instead of leaving it in the jug?',
      choices: [{ t: 'It keeps brewing after the plunge', correct: true }, { t: 'Standing lets the oils separate out' }, { t: 'Wet mesh left in coffee tastes metallic' }],
      explain: 'Pressing the plunger only pushes the grounds down; they are still sitting in the water, still extracting, and the last cup out of the jug pays for it. In immersion brewing, separating the coffee from the grounds is what actually ends the brew.' } },
  { id: 'scale', term: 'Scale', cat: 'equipment',
    short: 'A small kitchen scale lets you weigh coffee and water for a repeatable brew ratio.',
    deep: 'Coffee is measured by weight because volume is unreliable: a scoop of light roast weighs more than the same scoop of a dark one, and the grind size changes how much fits in the spoon. A scale that reads to 0.1 g, ideally with a timer, turns a recipe into something you can repeat — the same ratio every morning, so when the cup changes you know it was because of something you changed. Rules of thumb like tablespoons per cup are a starting point, not a recipe.',
    example: '60 g of coffee to 1,000 g of water is a recipe; “two scoops” is a guess.',
    related: ['brew-ratio', 'gooseneck', 'grind-size'], lesson: 'm5l6',
    sources: [{ label: 'National Coffee Association — Brewing', url: 'https://www.aboutcoffee.org/brewing/' }],
    check: { q: 'Why do baristas weigh rather than scoop?',
      choices: [{ t: 'A scoop’s mass varies', correct: true }, { t: 'Scales read the water temperature too' }, { t: 'Coffee absorbs water differently by volume' }],
      explain: 'A brew ratio compares two weights, so measuring by the scoop quietly changes it every time you switch beans. Weighing is what lets you compare yesterday’s brew to today’s.' } },
  { id: 'grind-size', term: 'Grind Size', cat: 'equipment', aliases: ['grind size'],
    short: 'How coarse or fine the coffee is ground — the main dial for matching your brew method.',
    deep: 'The grind decides how much coffee surface the water can reach, which makes it the fastest way to change how quickly a brew extracts: finer is quicker, coarser is slower. Each method comes with its own contact time — seconds for espresso, minutes for a press, hours for cold brew — so the method sets the rough range and your taste decides where in that range you land. How even the grind is matters as much as how fine, and that is the whole argument for burr grinders over blades.',
    example: 'Espresso runs near table salt; a French press nearer coarse sea salt.',
    related: ['burr-grinder', 'extraction', 'fines'], lesson: 'm4l1',
    sources: [{ label: 'National Coffee Association — Brewing', url: 'https://www.aboutcoffee.org/brewing/' }],
    check: { q: 'You brew a pour-over with the grind you use for a French press. What happens?',
      choices: [{ t: 'Under-extraction', correct: true }, { t: 'Over-extraction; the water runs hotter' }, { t: 'Nothing: grind and method are independent' }],
      explain: 'Grind and contact time work against each other, so changing the method means changing the grind. A coarse grind in a fast brewer tastes sour and thin no matter how good the coffee is.' } },
  { id: 'fines', term: 'Fines', cat: 'equipment', aliases: ['fines'],
    short: 'The dust-sized particles every grinder produces alongside the grind you asked for — they over-extract and can clog the filter.',
    deep: 'No grinder is perfectly even; there is always a tail of powder. Fines give up their flavour fastest, so too many read as bitter and dry, and they slow a brew by packing into the filter bed. Better burrs make fewer of them; sifting or a slightly coarser grind manages the rest.',
    example: 'A brew that stalls and tastes harsh is often drowning in fines from a worn grinder.',
    related: ['burr-grinder', 'grind-size', 'extraction', 'channeling'], lesson: 'm5l5',
    sources: [{ label: 'Barista Hustle — grinding and particle distribution' }],
    check: { q: 'Can a good enough grinder stop producing fines?',
      choices: [{ t: 'No, only fewer of them', correct: true }, { t: 'Yes — quality burrs make none' }, { t: 'Yes, if you grind slowly and let it cool' }],
      explain: 'Breaking a brittle bean always throws off some powder, so fines are a thing to manage rather than remove: better burrs, a slightly coarser setting, sifting if you care that much. They are not purely a nuisance either — some of the body in a cup comes from them.' } },

  // ── COFFEE TRADE ─────────────────────────────────────────
  { id: 'single-origin', term: 'Single Origin', cat: 'trade', aliases: ['single origin', 'single-origin'],
    short: 'Coffee from one place — a country, region, or even a single farm — rather than a blend.',
    deep: 'Single origins let you taste the character of a specific place and harvest. Blends mix origins for consistency or a target flavour; single origins celebrate difference.',
    example: '“Ethiopia Yirgacheffe” is a single origin; “House Blend” usually isn’t.',
    related: ['terroir', 'cultivar', 'traceability'], lesson: 'm1l5',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'Is a single origin automatically better than a blend?',
      choices: [{ t: 'No', correct: true }, { t: 'Yes — blends exist to hide weak lots' }, { t: 'Yes, blends are always cheaper coffee' }],
      explain: 'Single origin is a claim about where the coffee is from, not how good it is, and plenty of unremarkable coffee is sold that way. A blend is built on purpose — for balance, for body under milk, for a taste that survives a bad harvest year.' } },

  { id: 'fair-trade', term: 'Fair Trade', cat: 'trade', aliases: ['fair trade', 'fairtrade'],
    short: 'A certification that guarantees farmers a minimum price and community premiums for their coffee.',
    deep: 'Fair Trade sets a price floor to protect growers from volatile markets and adds a premium for community projects. It’s one of several models aiming to make the supply chain fairer.',
    example: 'A Fair Trade label means the co-op was paid at least the guaranteed minimum.',
    related: ['direct-trade', 'traceability', 'specialty'], lesson: 'm1l5',
    sources: [{ label: 'Fairtrade International — Standards', url: 'https://www.fairtrade.net/en/why-fairtrade/how-we-do-it/standards.html' }],
    check: { q: 'The market price is running well above the Fair Trade minimum. What is the certification worth to a farm that year?',
      choices: [{ t: 'Little on price', correct: true }, { t: 'Double whatever the market pays' }, { t: 'A buyer who must take the crop' }],
      explain: 'A floor only pays out when prices fall through it, so certification is insurance against a crash rather than a premium in a good year — the community premium continues either way. Judge any trade label by what it promises when the market turns against the farmer.' } },

  { id: 'direct-trade', term: 'Direct Trade', cat: 'trade', aliases: ['direct trade'],
    short: 'Roasters buying straight from farmers, often paying above market for quality and relationships.',
    deep: 'Direct trade is a roaster describing how they buy: straight from the producer or through a single exporter, usually paying above the market rate, often from the same farms year after year. Nobody audits the phrase, so by itself it guarantees nothing. What makes it checkable is the detail a roaster publishes — the price they paid, the names of the farms and lots, how many years they have been buying there. Certification works the other way round: it is audited, but it usually sets a floor rather than a premium.',
    example: 'A transparency report listing the price paid per kilo turns the claim into something you can check.',
    related: ['fair-trade', 'traceability', 'specialty'], lesson: 'm1l5',
    sources: [{ label: 'Fairtrade International — Standards (the audited contrast)', url: 'https://www.fairtrade.net/en/why-fairtrade/how-we-do-it/standards.html' }],
    check: { q: 'What does “direct trade” on a bag guarantee?',
      choices: [{ t: 'Nothing on its own', correct: true }, { t: 'A minimum price set by a certifier' }, { t: 'That the roaster visited the farm' }],
      explain: 'The label tells you what the roaster intends. The evidence is whatever they publish alongside it. Certification is the opposite trade-off: someone checks it, but what it guarantees is a minimum price, not a good one.' } },
  { id: 'traceability', term: 'Traceability', cat: 'trade',
    short: 'Knowing exactly where a coffee came from, down to the farm or washing station.',
    deep: 'Traceability is how far back a coffee can be followed: to a country, a region, a washing station or co-op, a farm, sometimes even a single day’s picking. Following it further back does not automatically mean it tastes better — what it buys you is quality that can be repeated and a premium you can check. Commodity coffee is traceable to a country and a grade, so a bag that says only “Brazil” is telling you where the trail runs out.',
    example: '“Ethiopia” is an origin; “Gedeb, Worka Sakaro, lot 12” is traceability.',
    related: ['single-origin', 'direct-trade', 'washing-station'], lesson: 'm1l5',
    sources: [{ label: 'James Hoffmann — The World Atlas of Coffee' }],
    check: { q: 'A bag names the washing station but no farm. Is that a traceability failure?',
      choices: [{ t: 'No — the station is the real unit', correct: true }, { t: 'Yes; only a farm name counts' }, { t: 'Yes, unless the roaster is certified' }],
      explain: 'What matters is naming the place where the lot was actually made. In much of East Africa hundreds of small farms deliver their cherries to one washing station, and the lot is created there — so the station is the honest answer. Demanding a single farm name would only encourage roasters to make one up.' } },
  { id: 'sca', term: 'SCA', pron: 'S-C-A', cat: 'trade', aliases: ['sca', 'specialty coffee association'],
    short: 'The Specialty Coffee Association — the trade body behind the standards, flavour wheel and scoring most of this app leans on.',
    deep: 'A non-profit of producers, roasters, baristas and buyers. It publishes the brewing and water standards, the 100-point cupping scale, the barista and brewing certifications, and the Coffee Taster’s Flavor Wheel. When a bag or a café cites a score or a “standard”, this is usually whose.',
    example: 'The flavour wheel in this app is built on the SCA lexicon.',
    related: ['specialty', 'single-origin', 'tds'],
    sources: [{ label: 'SCA — Standards and research', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'The SCA publishes a recommended brewing range. What kind of authority does that carry?',
      choices: [{ t: 'None in law', correct: true }, { t: 'A food standard regulators enforce' }, { t: 'A licence roasters have to hold' }],
      explain: 'A trade association can only publish and persuade; nobody is fined for brewing outside the range. Standards like this work because the industry chooses to share them, which is also why an SCA number is a common language rather than a rule.' } },

  { id: 'origin-boards', term: 'Origin Coffee Boards', cat: 'trade', aliases: ['cecafé', 'cecafe', 'conab', 'anacafé', 'anacafe', 'icafe', 'ihcafe', 'naeb', 'aeki', 'vicofa'],
    short: 'The national bodies that regulate, promote and count each origin’s coffee — the source behind most origin statistics.',
    deep: 'Almost every producing country has one: CECAFÉ and CONAB in Brazil, Anacafé in Guatemala, ICAFE in Costa Rica, IHCAFE in Honduras, NAEB in Rwanda, the Coffee Board of India, VICOFA in Vietnam. They set regional maps and quality rules, publish harvest and export figures, and are who the Atlas cites for crop numbers.',
    example: 'Anacafé drew the eight-region map of Guatemala that buyers still use.',
    related: ['traceability', 'single-origin', 'sca'],
    sources: [{ label: 'National coffee institutes — published crop and export data' }],
    check: { q: 'You read that Guatemala has eight coffee regions. Who decided that?',
      choices: [{ t: 'Anacafé, the national coffee body', correct: true }, { t: 'The SCA, as part of its standards' }, { t: 'Exporters, from their own shipping records' }],
      explain: 'National boards draw the maps and publish the harvest and export figures that everyone else quotes, so the “regions” printed on bags are usually their definitions. Worth knowing whose numbers you are reading: a body that both promotes and counts an origin has an interest in the figures.' } },

  { id: 'specialty', term: 'Specialty Coffee', cat: 'trade', aliases: ['specialty coffee', 'specialty'],
    short: 'High-quality coffee scoring 80+ points on a 100-point scale, made with care at every step.',
    deep: 'In the trade, specialty is a threshold rather than a style: green coffee that stays inside a defect limit and scores 80 or more on the 100-point cupping form. In everyday use the word also describes a supply chain that pays for quality and can tell you where the coffee came from. It does not mean expensive, single-origin or dark — blends clear 80 all the time.',
    example: 'On a green-coffee invoice, “specialty grade” means inside the defect limit and 80+ on the form.',
    related: ['single-origin', 'arabica', 'cupping', 'sca'], lesson: 'm1l5',
    sources: [{ label: 'SCA — Evolving the cupping protocol and form', url: 'https://sca.coffee/sca-news/read/evolving-the-sca-cupping-protocol-and-form-an-overview-of-the-pilot-testing-process' }, { label: 'SCA — Standards and research', url: 'https://sca.coffee/research?page=resources' }],
    check: { q: 'What makes a coffee “specialty” in the trade sense?',
      choices: [{ t: '80 or more on the 100-point form', correct: true }, { t: 'A retail price above a set threshold' }, { t: 'Being single-origin, not a blend' }],
      explain: 'It is a tasting score with a defect count behind it. That is why a blend can be specialty while an expensive single origin falls short.' } },
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
  const learned = new Set(DICT_LEARNED_SEED);
  DICT_TERMS.forEach(term => { if (term.lesson && completedSet && completedSet.has(term.lesson)) learned.add(term.id); });
  return learned;
}

// "Term of the day" — deterministic pick among full terms, rotating by date.
function dictTermOfDay(date, pool) {
  // Free tier passes its accessible pool so the pick never exposes a term
  // outside it; an explicitly empty pool means "nothing to pick" (null), and
  // no pool at all means every full entry.
  if (pool && !pool.length) return null;
  const full = (pool && pool.length) ? pool : DICT_TERMS.filter(t => t.check); // full entries only
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
// Every term.lesson is a promise the UI prints as "where you'll learn it", and
// learnedTermSet derives knowledge state from it. Neither survives a link to a
// lesson that never says the word, so this audits the claim against the lesson
// text. Run window.dictLessonAudit() after editing either file: [] means clean.
// It reads only the fields a learner actually SEES — a data field no card renders
// (paragraphs[0] and [2..] of a fill card, for one) would otherwise pass a check
// whose whole point is that the word appears on screen.
function lessonVisibleText(l) {
  const out = [l.title, l.moduleLabel];
  const push = v => {
    if (v == null) return;
    if (typeof v === 'string' || typeof v === 'number') out.push(String(v));
    else if (Array.isArray(v)) v.forEach(push);
    else if (typeof v === 'object') ['t', 'sub', 'l', 'r', 'label', 'title', 'summary', 'fact'].forEach(k => push(v[k]));
  };
  (l.cards || []).forEach(c => {
    ['label', 'title', 'body', 'question', 'prompt', 'scenario', 'clue', 'explain', 'right', 'wrong', 'note', 'line', 'feedback', 'hold', 'a']
      .forEach(k => push(c[k]));
    push(c.choices); push(c.options); push(c.pairs); push(c.items); push(c.meta); push(c.scale); push(c.leftLabel); push(c.rightLabel);
    // Fill cards render the sentence parts plus paragraphs[1] as support copy;
    // plain concept cards render every paragraph.
    if (c.fill) { c.fill.forEach(p => push(typeof p === 'object' ? [p.a, p.o, p.label] : p)); push((c.paragraphs || [])[1]); }
    else push(c.paragraphs);
  });
  if (l.reward) push([l.reward.title, l.reward.summary, l.reward.fact, l.reward.meta]);
  return out.join(' ');
}
function dictLessonAudit() {
  const lessons = window.LESSONS || {};
  return DICT_TERMS.filter(t => t.lesson).map(t => {
    const l = lessons[t.lesson];
    if (!l) return { id: t.id, lesson: t.lesson, problem: 'lesson does not exist' };
    const text = lessonVisibleText(l).toLowerCase();
    const words = [t.term.toLowerCase()].concat(t.aliases || []);
    return words.some(w => text.includes(w)) ? null : { id: t.id, lesson: t.lesson, problem: 'lesson never mentions the term' };
  }).filter(Boolean);
}
window.dictLessonAudit = dictLessonAudit;
window.lessonVisibleText = lessonVisibleText;
window.dictTermOfDay = dictTermOfDay;
window.dictCatCounts = dictCatCounts;
