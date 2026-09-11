# Opening the dictionary with a query and the field focused

The dictionary is opened plain: an empty search field, no keyboard up. No
route parameter seeds the field, and nothing in the app focuses it.

## Why this is out of scope

The prototype's dictionary screen accepts a starting query and a focus flag,
and the shell's open-dictionary function takes both. Nothing passes them. The
one caller is the header's dictionary entry, and it opens the dictionary with
neither; no route sets the query seed. A learner using the design can never
reach the dictionary with a word already in the field, so there is no
behaviour to port — only plumbing with nothing connected to it.

Ruled by the owner on 11 September 2026: the feature is not wanted. A later
surface that needs a "look this word up" tap owns that tap, and would open a
term entry rather than a search — which is how every existing link into the
dictionary already works.

## Prior requests

- #574 — "The dictionary search can open with a query and the field focused"
