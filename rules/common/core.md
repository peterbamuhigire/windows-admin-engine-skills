# Core Rules — Windows Administration Engine

> Distilled from this engine's own `AGENTS.md`.

## Never guess an identity value

Never guess a hostname, domain, tenant, subscription, cluster, or identity.
When it is not confirmed, it is not assumed — it is looked up or marked
missing.

## Never accept a secret as an ordinary argument or evidence field

Passwords, tokens, LAPS values, recovery keys, and private keys never appear as
plain command-line arguments or in a recorded evidence field. Route them
through the secret-handling mechanism the specific task requires, or state that
none exists yet and stop.

## Missing evidence is `NOT_ASSESSED`, never inferred success

If live or lab evidence for a claim is unavailable, the claim is marked
`NOT_ASSESSED`. It is never quietly treated as passing because the failure mode
would otherwise be invisible.

## Every remediation states its rollback path

A change to AD, a fleet policy, or network configuration is not complete without
a stated recovery path — what restores the prior state if the change is wrong.
