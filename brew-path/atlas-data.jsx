// atlas-data.jsx — Coffee Atlas content model: 15 origins, map coordinates,
// exploration-state helpers, and progress math.
//
// Careful wording is intentional throughout: flavour is described as a
// *tendency* ("often associated with"), never a fixed rule. Every origin
// carries source references and a last-reviewed date.

// Internal map coordinate space. Markers are hand-placed (mx,my) so clusters
// stay legible; the continents in atlas-map.jsx are drawn to match.
const ATLAS_MAP = { w: 1000, h: 560 };

// Three regions the belt naturally falls into. `cx` is the pan focus.
const ATLAS_REGIONS = {
  americas: {
    id: 'americas', label: 'The Americas', short: 'Americas', cx: 235,
    blurb: 'From Mexico down the spine of the Andes to Brazil — washed and natural coffees grown along a long volcanic corridor.',
  },
  africa: {
    id: 'africa', label: 'Africa and Arabia', short: 'Africa', cx: 600,
    blurb: 'Coffee’s ancestral home. High plateaus and the Great Rift Valley, where Coffea arabica was first cultivated.',
  },
  asia: {
    id: 'asia', label: 'Asia and the Pacific', short: 'Asia', cx: 820,
    blurb: 'Monsoon-fed estates and volcanic islands — distinctive processing traditions and the world’s robusta heartland.',
  },
};

// Exploration states, in rank order. A state only ever advances.
const ATLAS_STATES = ['not-explored', 'discovered', 'lesson', 'tasted'];
const ATLAS_STATE_META = {
  'not-explored': { rank: 0, label: 'Not explored', short: 'NEW',        color: 'var(--ink-mute)' },
  'discovered':   { rank: 1, label: 'Discovered',   short: 'DISCOVERED', color: 'color-mix(in oklab, var(--accent) 40%, var(--ink-mute))' },
  'lesson':       { rank: 2, label: 'Lesson done',  short: 'LESSON',     color: 'var(--sage)' },
  'tasted':       { rank: 3, label: 'Coffee tasted', short: 'TASTED',    color: 'var(--accent)' },
};
const atlasRank = (s) => (ATLAS_STATE_META[s] ? ATLAS_STATE_META[s].rank : 0);

// ── The 15 origins ──────────────────────────────────────────
// flavour.note uses careful, hedged language by design.
const ATLAS_ORIGINS = [
  {
    slug: 'ethiopia', name: 'Ethiopia', region: 'africa', mx: 595, my: 250,
    tag: 'The birthplace', emoji: null,
    intro: 'Widely regarded as the birthplace of Coffea arabica, where coffee still grows semi-wild and is woven into daily ritual. Thousands of distinct heirloom varieties remain uncatalogued.',
    growing: ['Yirgacheffe', 'Sidama', 'Guji', 'Harrar', 'Limu'],
    altitude: '1,500–2,200 m', climate: 'Cool highland; single wet season, dry harvest.',
    species: ['Arabica'], varieties: ['Indigenous “heirloom” landraces', '74110 / 74112 selections'],
    processing: 'Both washed and natural are long-held traditions; dry-processed (natural) coffees have deep historical roots here.',
    harvest: 'October – December',
    history: 'Cultivation and trade trace back many centuries in the highlands; coffee’s spread to Yemen and beyond is often linked to this region. The coffee ceremony remains central to social life.',
    flavour: { note: 'Washed lots are often associated with floral and citrus notes such as jasmine and bergamot; naturals are frequently described as berry-forward and wine-like.', tags: ['Floral', 'Citrus', 'Berry', 'Tea-like'] },
    sources: ['Ethiopian Coffee and Tea Authority', 'SCA origin references'], reviewed: 'Mar 2026',
    activity: { type: 'identify',
      prompt: 'Read the clues. Which origin is described?',
      clues: ['Often called the birthplace of arabica', 'Home to thousands of heirloom varieties', 'Famous for floral, tea-like washed coffees'],
      options: ['Ethiopia', 'Brazil', 'Vietnam', 'Panama'], answer: 'Ethiopia' },
  },
  {
    slug: 'kenya', name: 'Kenya', region: 'africa', mx: 612, my: 300,
    tag: 'Bright and structured', emoji: null,
    intro: 'Known for meticulous washed processing and a rigorous auction system. Grown largely by smallholder cooperatives on the rich volcanic soils around Mt. Kenya.',
    growing: ['Nyeri', 'Kirinyaga', 'Murang’a', 'Embu', 'Kiambu'],
    altitude: '1,400–2,100 m', climate: 'Equatorial highland; two rainy seasons, two harvests.',
    species: ['Arabica'], varieties: ['SL28', 'SL34', 'Ruiru 11', 'Batian'],
    processing: 'Predominantly washed, traditionally with an extended soak step — a hallmark of Kenyan preparation.',
    harvest: 'Main: Oct – Dec · Fly: Jun – Aug',
    history: 'Commercial production was established in the early 20th century. The SL-series varieties, selected locally in the 1930s–40s, became prized worldwide.',
    flavour: { note: 'Often associated with vivid acidity and blackcurrant or tomato-like savouriness, with notes commonly described as juicy and structured.', tags: ['Blackcurrant', 'Bright acidity', 'Savoury', 'Juicy'] },
    sources: ['Agriculture and Food Authority (Kenya)', 'SCA origin references'], reviewed: 'Feb 2026',
    activity: { type: 'compare',
      prompt: 'Which origin is more often associated with bright, blackcurrant-like acidity?',
      a: 'Kenya', b: 'Brazil', answer: 'Kenya',
      because: 'Kenyan washed coffees are frequently described as sharply acidic; Brazilian naturals tend toward low acidity and nutty sweetness.' },
  },
  {
    slug: 'rwanda', name: 'Rwanda', region: 'africa', mx: 575, my: 312,
    tag: 'Hills and washing stations', emoji: null,
    intro: 'A “land of a thousand hills” where coffee is grown on steep smallholdings and processed at shared washing stations that transformed quality over the past two decades.',
    growing: ['Western Province (Lake Kivu)', 'Southern Province (Huye)', 'Nyamasheke'],
    altitude: '1,400–2,000 m', climate: 'Temperate highland; long dry season for drying.',
    species: ['Arabica'], varieties: ['Red Bourbon', 'BM139 / Jackson selections'],
    processing: 'Mostly washed at centralised stations; the “potato defect” is actively screened for during sorting.',
    harvest: 'March – June',
    history: 'Introduced under colonial administration, the sector pivoted toward specialty quality in the 2000s, with washing-station investment driving a widely-noted turnaround.',
    flavour: { note: 'Frequently described as clean and sweet, often associated with red-fruit, floral, and orange-blossom impressions.', tags: ['Red fruit', 'Floral', 'Clean', 'Honeyed'] },
    sources: ['National Agricultural Export Board (NAEB)', 'SCA origin references'], reviewed: 'Jan 2026',
    activity: { type: 'match',
      prompt: 'Match each region to what it is best known for',
      pairs: [ { l: 'Lake Kivu', r: 'Washed Bourbon' }, { l: 'Huye Mountain', r: 'Floral cup profile' }, { l: 'Washing station', r: 'Potato-defect sorting' } ] },
  },
  {
    slug: 'yemen', name: 'Yemen', region: 'africa', mx: 622, my: 232,
    tag: 'Ancient and natural', emoji: null,
    intro: 'Among the oldest sites of commercial coffee, grown on terraced mountains with minimal water. The port of Mokha gave its name to a style and, loosely, to “mocha”.',
    growing: ['Haraz', 'Bani Matar', 'Yafe’i', 'Ismaili'],
    altitude: '1,500–2,400 m', climate: 'Arid mountain; very low rainfall, terrace farming.',
    species: ['Arabica'], varieties: ['Ancient Yemeni landraces (e.g. Udaini, Dawairi)'],
    processing: 'Almost entirely natural (dry) — fruit is sun-dried on rooftops and terraces, a centuries-old necessity in a dry climate.',
    harvest: 'October – December',
    history: 'Coffee was traded through the port of Mokha from roughly the 15th century, making Yemen a cradle of the global coffee trade long before cultivation spread elsewhere.',
    flavour: { note: 'Often associated with deep, dried-fruit and spice character — impressions sometimes described as raisin, cocoa, or incense-like.', tags: ['Dried fruit', 'Spice', 'Cocoa', 'Wild'] },
    sources: ['Historical trade records', 'Specialty importer origin notes'], reviewed: 'Mar 2026',
    activity: { type: 'identify',
      prompt: 'Read the clues. Which origin is described?',
      clues: ['One of the oldest coffee-trading regions', 'Almost all coffee is natural / dry-processed', 'Lent its port’s name to a coffee style'],
      options: ['Yemen', 'Costa Rica', 'India', 'Colombia'], answer: 'Yemen' },
  },
  {
    slug: 'colombia', name: 'Colombia', region: 'americas', mx: 250, my: 285,
    tag: 'Year-round and balanced', emoji: null,
    intro: 'A vast, varied origin spanning three Andean ranges. Because regions harvest at different times, Colombia supplies fresh coffee for much of the year.',
    growing: ['Huila', 'Nariño', 'Antioquia', 'Tolima', 'Cauca'],
    altitude: '1,200–2,000 m', climate: 'Tropical mountain; varies by range, often two harvests.',
    species: ['Arabica'], varieties: ['Caturra', 'Castillo', 'Colombia', 'Typica', 'Pink Bourbon'],
    processing: 'Overwhelmingly washed, typically on small family farms with their own micro-mills.',
    harvest: 'Main + “mitaca” secondary crop (varies by region)',
    history: 'Coffee became central to the rural economy through the 19th and 20th centuries; the Federación Nacional de Cafeteros and the “Juan Valdez” figure shaped its global identity.',
    flavour: { note: 'Often associated with balanced sweetness and a rounded acidity; commonly described with caramel, red-apple, and citrus impressions depending on region.', tags: ['Caramel', 'Red apple', 'Balanced', 'Citrus'] },
    sources: ['Federación Nacional de Cafeteros', 'SCA origin references'], reviewed: 'Feb 2026',
    activity: { type: 'locate',
      prompt: 'Find this origin on the map',
      hint: 'A long Andean country — the only South American origin that touches both the Pacific and the Caribbean' },
  },
  {
    slug: 'brazil', name: 'Brazil', region: 'americas', mx: 330, my: 355,
    tag: 'The volume giant', emoji: null,
    intro: 'The largest coffee producer in the world by a wide margin. Much of it grows on broad, gently rolling plateaus suited to mechanised harvesting.',
    growing: ['Sul de Minas', 'Cerrado Mineiro', 'Mogiana', 'Bahia', 'Espírito Santo'],
    altitude: '800–1,350 m', climate: 'Warm plateau; distinct dry season aids natural drying.',
    species: ['Arabica', 'Robusta (“Conilon”)'], varieties: ['Yellow and Red Catuaí', 'Mundo Novo', 'Bourbon', 'Icatu'],
    processing: 'Known for natural and “pulped natural” methods, well-matched to the dry harvest climate.',
    harvest: 'May – September',
    history: 'Coffee drove Brazil’s economy from the 19th century onward. Today it shapes global supply and price, and grows both arabica and a large volume of conilon robusta.',
    flavour: { note: 'Often associated with low acidity and nutty-chocolate sweetness; frequently described as smooth and full-bodied, which suits espresso blends.', tags: ['Chocolate', 'Nutty', 'Low acidity', 'Full body'] },
    sources: ['CECAFÉ / CONAB', 'SCA origin references'], reviewed: 'Feb 2026',
    activity: { type: 'compare',
      prompt: 'Which origin is more often associated with a heavy, low-acid, chocolatey body?',
      a: 'Brazil', b: 'Ethiopia', answer: 'Brazil',
      because: 'Brazilian naturals tend toward nutty-chocolate body; Ethiopian coffees are more often described as floral and tea-like.' },
  },
  {
    slug: 'peru', name: 'Peru', region: 'americas', mx: 250, my: 360,
    tag: 'Organic and smallholder', emoji: null,
    intro: 'A large but historically under-the-radar origin, with much coffee grown organically by smallholder cooperatives across remote Andean and Amazonian slopes.',
    growing: ['Cajamarca', 'Amazonas', 'San Martín', 'Cusco', 'Puno'],
    altitude: '1,200–1,900 m', climate: 'Tropical highland; remote, often shade-grown.',
    species: ['Arabica'], varieties: ['Typica', 'Bourbon', 'Caturra', 'Catimor'],
    processing: 'Predominantly washed, with a strong base of certified organic and Fairtrade cooperative production.',
    harvest: 'April – September',
    history: 'Coffee has grown here since the 18th century, but specialty recognition is more recent, propelled by cooperative organisation and certification programmes.',
    flavour: { note: 'Often associated with gentle sweetness and mild acidity; commonly described with soft chocolate, nut, and light floral impressions.', tags: ['Mild', 'Chocolate', 'Nutty', 'Gentle'] },
    sources: ['Junta Nacional del Café (Peru)', 'Fairtrade origin notes'], reviewed: 'Jan 2026',
    activity: { type: 'match',
      prompt: 'Match each fact to the right category',
      pairs: [ { l: 'Cajamarca', r: 'Growing region' }, { l: 'Organic', r: 'Common certification' }, { l: 'Washed', r: 'Typical process' } ] },
  },
  {
    slug: 'guatemala', name: 'Guatemala', region: 'americas', mx: 175, my: 205,
    tag: 'Volcanic and varied', emoji: null,
    intro: 'A compact but remarkably diverse origin, with eight recognised growing regions shaped by volcanoes, microclimates, and altitude.',
    growing: ['Antigua', 'Huehuetenango', 'Atitlán', 'Cobán', 'Fraijanes'],
    altitude: '1,300–2,000 m', climate: 'Volcanic highland; varied microclimates by region.',
    species: ['Arabica'], varieties: ['Bourbon', 'Caturra', 'Catuaí', 'Pacamara'],
    processing: 'Mainly washed, with sun-drying on patios or raised beds.',
    harvest: 'December – April',
    history: 'Coffee became a leading export in the late 19th century. The national coffee body (Anacafé) formalised the eight-region map that many specialty buyers reference today.',
    flavour: { note: 'Often associated with cocoa and baking-spice depth in volcanic regions like Antigua, and with brighter, fruit-forward profiles at altitude in Huehuetenango.', tags: ['Cocoa', 'Baking spice', 'Orange', 'Full'] },
    sources: ['Anacafé', 'SCA origin references'], reviewed: 'Feb 2026',
    activity: { type: 'locate',
      prompt: 'Find this origin on the map',
      hint: 'A Central American origin just south of Mexico, famous for its volcanic Antigua valley' },
  },
  {
    slug: 'costa-rica', name: 'Costa Rica', region: 'americas', mx: 188, my: 242,
    tag: 'Honey-process pioneer', emoji: null,
    intro: 'A small, quality-focused origin known for micro-mills and for popularising the “honey” processing spectrum. It is almost entirely arabica — a decades-old ban on robusta was only lifted in 2018.',
    growing: ['Tarrazú', 'Central Valley', 'West Valley', 'Tres Ríos', 'Brunca'],
    altitude: '1,200–1,900 m', climate: 'Tropical highland; clear wet/dry seasons.',
    species: ['Arabica'], varieties: ['Caturra', 'Catuaí', 'Villa Sarchí', 'Geisha'],
    processing: 'A pioneer of honey processing (white / yellow / red / black) where varying amounts of fruit mucilage are left on during drying.',
    harvest: 'November – March',
    history: 'Coffee shaped the national economy from the early 19th century. A wave of micro-mill building in the 2000s let individual farms control their own processing.',
    flavour: { note: 'Often associated with clean sweetness and balance; honey lots are frequently described as syrupy with stone-fruit and brown-sugar impressions.', tags: ['Brown sugar', 'Stone fruit', 'Clean', 'Balanced'] },
    sources: ['ICAFE (Costa Rica)', 'SCA origin references'], reviewed: 'Jan 2026',
    activity: { type: 'match',
      prompt: 'Match each honey style to how much fruit mucilage is left on',
      pairs: [ { l: 'White honey', r: 'Least mucilage' }, { l: 'Red honey', r: 'More mucilage' }, { l: 'Black honey', r: 'Most mucilage' } ] },
  },
  {
    slug: 'honduras', name: 'Honduras', region: 'americas', mx: 205, my: 210,
    tag: 'Fast-rising and diverse', emoji: null,
    intro: 'Now one of Central America’s largest producers, with rapidly improving infrastructure and six distinct, officially-recognised growing regions.',
    growing: ['Marcala', 'Copán', 'Montecillos', 'Comayagua', 'Agalta'],
    altitude: '1,000–1,700 m', climate: 'Tropical highland; humidity can challenge drying.',
    species: ['Arabica'], varieties: ['Catuaí', 'Bourbon', 'Lempira', 'Parainema'],
    processing: 'Mainly washed; investment in covered and raised-bed drying has notably improved consistency.',
    harvest: 'November – April',
    history: 'Historically overshadowed by neighbours, Honduras grew rapidly in the 2000s–2010s with support from its coffee institute (IHCAFE) and regional denominations.',
    flavour: { note: 'Often associated with mild sweetness; commonly described with caramel, hazelnut, and light-fruit impressions that vary widely by region.', tags: ['Caramel', 'Hazelnut', 'Mild', 'Light fruit'] },
    sources: ['IHCAFE', 'SCA origin references'], reviewed: 'Jan 2026',
    activity: { type: 'identify',
      prompt: 'Read the clues. Which origin is described?',
      clues: ['One of Central America’s largest producers', 'Six official growing regions incl. Marcala and Copán', 'Drying improvements drove a fast quality rise'],
      options: ['Honduras', 'Kenya', 'Indonesia', 'Peru'], answer: 'Honduras' },
  },
  {
    slug: 'mexico', name: 'Mexico', region: 'americas', mx: 150, my: 150,
    tag: 'Northern frontier', emoji: null,
    intro: 'The northernmost major arabica origin, with much production by indigenous smallholders in the southern states and a strong organic tradition.',
    growing: ['Chiapas', 'Oaxaca', 'Veracruz', 'Puebla'],
    altitude: '900–1,700 m', climate: 'Tropical highland; shade-grown is common.',
    species: ['Arabica'], varieties: ['Typica', 'Bourbon', 'Caturra', 'Marsellesa'],
    processing: 'Predominantly washed, with a large share of certified-organic production.',
    harvest: 'November – March',
    history: 'Coffee spread through the south in the 19th century. Smallholder cooperatives, many indigenous-led, became pioneers of the organic and Fairtrade movements.',
    flavour: { note: 'Often associated with gentle, mellow profiles; commonly described with light chocolate, nut, and soft-citrus impressions, especially in higher Chiapas lots.', tags: ['Mellow', 'Light chocolate', 'Nutty', 'Soft citrus'] },
    sources: ['SAGARPA / regional councils', 'Fairtrade origin notes'], reviewed: 'Jan 2026',
    activity: { type: 'locate',
      prompt: 'Find this origin on the map',
      hint: 'The northernmost major arabica origin — look at the top of the Americas cluster' },
  },
  {
    slug: 'panama', name: 'Panama', region: 'americas', mx: 220, my: 250,
    tag: 'Home of Geisha', emoji: null,
    intro: 'A tiny origin with an outsized reputation, centred on the Boquete highlands. Famous for elevating the Geisha (Gesha) variety to record-setting auction prices.',
    growing: ['Boquete', 'Volcán', 'Renacimiento (Chiriquí)'],
    altitude: '1,300–1,900 m', climate: 'Cool volcanic highland; misty “bajareque”.',
    species: ['Arabica'], varieties: ['Geisha / Gesha', 'Caturra', 'Catuaí', 'Bourbon'],
    processing: 'All three of washed, natural, and honey are used, often on the same estate for comparison.',
    harvest: 'December – March',
    history: 'A 2004 competition win for an Hacienda La Esmeralda Geisha lot reshaped specialty coffee, sparking global interest in the variety and in micro-lot auctions.',
    flavour: { note: 'Panamanian Geisha is often associated with intense florals and bergamot; commonly described as jasmine-like and tea-delicate, though other varieties differ.', tags: ['Jasmine', 'Bergamot', 'Tea-like', 'Tropical'] },
    sources: ['Specialty Coffee Association of Panama', 'Best of Panama auction records'], reviewed: 'Mar 2026',
    activity: { type: 'identify',
      prompt: 'Read the clues. Which origin is described?',
      clues: ['A small origin centred on Boquete', 'Made the Geisha variety world-famous', 'Sets records at micro-lot auctions'],
      options: ['Panama', 'Brazil', 'Rwanda', 'Vietnam'], answer: 'Panama' },
  },
  {
    slug: 'indonesia', name: 'Indonesia', region: 'asia', mx: 865, my: 345,
    tag: 'Islands and wet-hulling', emoji: null,
    intro: 'A sprawling archipelago of volcanic islands, each with its own character. Sumatra is known for a distinctive wet-hulled process found in few other places.',
    growing: ['Sumatra (Gayo, Lintong)', 'Java', 'Sulawesi (Toraja)', 'Flores', 'Bali'],
    altitude: '900–1,800 m', climate: 'Humid equatorial; frequent rain complicates drying.',
    species: ['Arabica', 'Robusta'], varieties: ['Typica', 'Catimor / Tim Tim', 'S-795', 'Ateng'],
    processing: 'Sumatra is known for wet-hulling (“Giling Basah”), where parchment is removed at high moisture — a key driver of its signature cup.',
    harvest: 'Varies by island (often Oct – Mar)',
    history: 'Dutch colonial planting in the 17th–18th centuries made “Java” an early byword for coffee. Leaf-rust later pushed a shift toward robusta and tougher hybrids on several islands.',
    flavour: { note: 'Wet-hulled Sumatra is often associated with low acidity and earthy, herbal, cedar-like depth; commonly described as full-bodied and savoury.', tags: ['Earthy', 'Herbal', 'Cedar', 'Full body'] },
    sources: ['Indonesian Coffee Exporters Assoc. (AEKI)', 'SCA origin references'], reviewed: 'Feb 2026',
    activity: { type: 'match',
      prompt: 'Match each island to what it is known for',
      pairs: [ { l: 'Sumatra', r: 'Wet-hulled, earthy' }, { l: 'Sulawesi', r: 'Toraja highlands' }, { l: 'Java', r: 'Historic estates' } ] },
  },
  {
    slug: 'india', name: 'India', region: 'asia', mx: 760, my: 255,
    tag: 'Shade and monsoon', emoji: null,
    intro: 'Almost all coffee is grown under shade in the southern hills, alongside spices. India is also home to the unusual “monsooned” process born from history.',
    growing: ['Karnataka (Coorg, Chikmagalur)', 'Kerala', 'Tamil Nadu'],
    altitude: '700–1,600 m', climate: 'Monsoon-driven; dense shade canopy, two monsoons.',
    species: ['Arabica', 'Robusta'], varieties: ['S-795', 'Kent', 'Selection 9', 'Cauvery'],
    processing: 'Washed and natural are both used; “Monsooned Malabar” deliberately exposes dried beans to monsoon winds to mellow and swell them.',
    harvest: 'November – March',
    history: 'Legend credits the pilgrim Baba Budan with bringing seeds to the hills around the 17th century. Monsooning began as an accident of long sea voyages and was later reproduced on purpose.',
    flavour: { note: 'Monsooned coffees are often associated with very low acidity and heavy, musty-spicy body; washed lots are more often described as mild and nutty.', tags: ['Low acidity', 'Spice', 'Full body', 'Nutty'] },
    sources: ['Coffee Board of India', 'SCA origin references'], reviewed: 'Jan 2026',
    activity: { type: 'compare',
      prompt: 'Which origin is the home of the “monsooned” process?',
      a: 'India', b: 'Colombia', answer: 'India',
      because: 'Monsooned Malabar is unique to India’s coast; Colombia is known instead for washed, balanced coffees.' },
  },
  {
    slug: 'vietnam', name: 'Vietnam', region: 'asia', mx: 858, my: 260,
    tag: 'The robusta powerhouse', emoji: null,
    intro: 'The world’s second-largest producer overall and the largest grower of robusta, concentrated in the Central Highlands. Increasingly exploring specialty arabica too.',
    growing: ['Central Highlands (Đắk Lắk, Lâm Đồng)', 'Buôn Ma Thuột', 'Cầu Đất (arabica)'],
    altitude: '500–1,500 m', climate: 'Tropical; robusta thrives at lower, warmer elevations.',
    species: ['Robusta', 'Arabica'], varieties: ['Robusta cultivars', 'Catimor (arabica)'],
    processing: 'Mostly natural (dry) for robusta; a growing share of washed arabica from cooler areas like Cầu Đất.',
    harvest: 'October – January',
    history: 'French colonists introduced coffee in the 19th century. Rapid expansion from the 1990s made Vietnam a dominant force in global robusta supply.',
    flavour: { note: 'Robusta is often associated with bold, heavy body and lower acidity, with notes commonly described as woody, dark-chocolate, and grain-like; it lends body and crema to blends.', tags: ['Bold', 'Dark chocolate', 'Woody', 'Low acidity'] },
    sources: ['Vietnam Coffee–Cocoa Assoc. (VICOFA)', 'SCA origin references'], reviewed: 'Feb 2026',
    activity: { type: 'identify',
      prompt: 'Read the clues. Which origin is described?',
      clues: ['The world’s largest grower of robusta', 'Centred on the Central Highlands', 'Coffee often served strong, with condensed milk'],
      options: ['Vietnam', 'Ethiopia', 'Costa Rica', 'Kenya'], answer: 'Vietnam' },
  },
];

// ── Helpers ─────────────────────────────────────────────────
const atlasOrigin   = (slug) => ATLAS_ORIGINS.find(o => o.slug === slug) || null;
const atlasByRegion = (rid)  => ATLAS_ORIGINS.filter(o => o.region === rid);

// Build a progress summary from a state map { slug: stateString }.
function atlasProgress(states) {
  states = states || {};
  const total = ATLAS_ORIGINS.length;
  let explored = 0, lessons = 0, tasted = 0;
  ATLAS_ORIGINS.forEach(o => {
    const r = atlasRank(states[o.slug]);
    if (r >= 1) explored++;
    if (r >= 2) lessons++;
    if (r >= 3) tasted++;
  });
  return { total, explored, lessons, tasted };
}

// Demo seed — leaves the map partly explored so states are visible and the
// passport reads "8 of 15 origins explored".
const ATLAS_SEED = {
  states: {
    ethiopia: 'tasted', colombia: 'tasted', brazil: 'tasted',
    kenya: 'lesson', guatemala: 'lesson',
    'costa-rica': 'discovered', indonesia: 'discovered', yemen: 'discovered',
  },
  favs: ['ethiopia', 'kenya', 'colombia'],
};

window.ATLAS_MAP = ATLAS_MAP;
window.ATLAS_REGIONS = ATLAS_REGIONS;
window.ATLAS_STATES = ATLAS_STATES;
window.ATLAS_STATE_META = ATLAS_STATE_META;
window.ATLAS_ORIGINS = ATLAS_ORIGINS;
window.ATLAS_SEED = ATLAS_SEED;
window.atlasRank = atlasRank;
window.atlasOrigin = atlasOrigin;
window.atlasByRegion = atlasByRegion;
window.atlasProgress = atlasProgress;
