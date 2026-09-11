// monetization.jsx — the monetization CONFIG layer (paywall presentation).
// Three models under experiment: onetime (SHIPPING BASELINE), subscription,
// hybrid. Switch live via Tweaks → Purchases → Model.
//
// SEPARATION CONTRACT: this file owns HOW Foundations is sold — plans, prices,
// CTAs, footers, receipts. It never owns WHAT is unlocked: entitlement stays
// `isPlus` / featureUnlocked() in app.jsx, and every gate keeps reading those.
// Swapping the model rewrites the selling surfaces only; access logic is
// untouched by design, so any model can ship without a gating rewrite.
// Loaded before settings.jsx (first reader).

// The purchasable plans. `receipt` renders the owned card's one fact line;
// `welcome`/`welcomeNote` feed the post-purchase screen. Presentation only —
// the entitlement itself is a boolean regardless of which plan granted it.
const MONETIZATION_PLANS = {
  lifetime: { id: 'lifetime', kind: 'once', name: 'Lifetime', price: '$49.99', per: null,
    line: 'One payment · yours to keep',
    cta: 'Unlock Foundations — $49.99',
    welcome: 'The whole course is unlocked — permanently. Time to make Roasty and your grove your own.',
    welcomeNote: 'One-time purchase',
    ownedChip: 'Owned',
    receipt: (d) => 'Purchased ' + d + ' · $49.99',
    ownedFooter: ['Purchased through the App Store.', 'Nothing renews.'] },
  monthly: { id: 'monthly', kind: 'sub', name: 'Monthly', price: '$3.99', per: '/month',
    line: 'Billed monthly',
    cta: 'Subscribe — $3.99/month',
    welcome: 'The whole course is unlocked for as long as you’re subscribed. Time to make Roasty and your grove your own.',
    welcomeNote: 'Cancel anytime',
    ownedChip: 'Active',
    receipt: (d) => '$3.99/month · renews 8 Sep 2026',
    ownedFooter: ['Billed through the App Store. Cancel anytime —', 'access runs to the end of the paid period.'] },
  yearly: { id: 'yearly', kind: 'sub', name: 'Yearly', price: '$23.99', per: '/year', badge: 'Save 50%',
    line: '$2/month, billed yearly',
    cta: 'Subscribe — $23.99/year',
    welcome: 'The whole course is unlocked for as long as you’re subscribed. Time to make Roasty and your grove your own.',
    welcomeNote: 'Cancel anytime',
    ownedChip: 'Active',
    receipt: (d) => '$23.99/year · renews 8 May 2027',
    ownedFooter: ['Billed through the App Store. Cancel anytime —', 'access runs to the end of the paid period.'] },
};

// The three experiment arms. Copy slots, one claim per slot: eyebrow = model,
// heroTitle = permanence promise, paywallNote = the one fact NOT stated by the
// eyebrow, hero, plan rows or CTA on that same screen, gateCta/gateFooter = the
// gate sheet's pitch, purchasesFooter = the Purchases screen's free-state
// caption, faq = the model-specific tail of the Foundations FAQ answer.
//
// paywallNote is the slot that rots first. It sits under a screen that has
// already named the model (eyebrow), promised permanence (hero) and shown the
// price (CTA), so any restatement of those is dead weight — and a NEGATED one
// ("no subscription") is worse than dead, because it raises the doubt it denies.
// Whatever goes here must be unavailable anywhere else on the screen.
const MONETIZATION_MODELS = {
  onetime: { id: 'onetime', label: 'One-time purchase', plans: ['lifetime'], defaultPlan: 'lifetime',
    eyebrow: 'ONE-TIME PURCHASE',
    heroTitle: 'Own the whole course.',
    paywallNote: 'Fixes and improvements included',
    gateCta: 'Unlock Foundations — $49.99',
    gateFooter: 'One-time purchase · yours to keep',
    offerValue: '$49.99',
    purchasesFooter: ['Foundations is a one-time purchase', 'through the App Store.'],
    faq: 'Buy it once and it’s yours for good — nothing renews.' },
  subscription: { id: 'subscription', label: 'Subscription', plans: ['monthly', 'yearly'], defaultPlan: 'yearly',
    eyebrow: 'SUBSCRIPTION',
    heroTitle: 'The whole course, for as long as you’re brewing.',
    paywallNote: 'You keep the time you paid for',
    gateCta: 'Unlock Foundations — from $2/mo',
    gateFooter: 'Subscription · cancel anytime',
    offerValue: 'from $2/mo',
    purchasesFooter: ['Foundations is a subscription', 'through the App Store. Cancel anytime.'],
    faq: 'Monthly or yearly, your pick — access stays open while you’re subscribed. Cancel anytime; it runs to the end of the paid period.' },
  hybrid: { id: 'hybrid', label: 'Hybrid', plans: ['monthly', 'yearly', 'lifetime'], defaultPlan: 'yearly',
    eyebrow: 'SUBSCRIBE OR OWN IT',
    heroTitle: 'The whole course, your terms.',
    paywallNote: 'Fixes and improvements included, whichever you pick',
    gateCta: 'Unlock Foundations — from $2/mo',
    gateFooter: 'Or one payment, yours to keep',
    offerValue: 'from $2/mo',
    purchasesFooter: ['Subscribe monthly or yearly — or buy once', 'through the App Store and keep it.'],
    faq: 'Your choice — subscribe monthly or yearly, or buy it once and keep it forever.' },
};

// Resolve the active model from the tweak (or an explicit id). Every selling
// surface calls this at render, so flipping the tweak restyles them live.
function getMonetization(id) {
  const key = id || (window.__tweaks || {}).monetization || 'onetime';
  return MONETIZATION_MODELS[key] || MONETIZATION_MODELS.onetime;
}
function getPlan(id) { return MONETIZATION_PLANS[id] || MONETIZATION_PLANS.lifetime; }

Object.assign(window, { MONETIZATION_MODELS, MONETIZATION_PLANS, getMonetization, getPlan });
