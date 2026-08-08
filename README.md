# OneMind / BrightPath – Book-Aligned Data Vault Practice Project

This is the revised version of the original client-only project. The Supabase source schemas and data files under `sql/supabase/` are **unchanged** and remain the source contract.

## What changed

- Expanded from Client only to the full source-domain Enterprise Data Warehouse.
- Raw Vault now covers clients, referrals, assessments, episodes, waitlist events, sessions, clinicians, teams, locations, services, organisations, goals, risk assessments, outcomes and discharge.
- Added relationship Links for the treatment journey and workforce/service relationships.
- Preserved OneMind and BrightPath history in source-aligned Satellites.
- Removed fuzzy matching models.
- Kept deterministic Business Vault client matching only:
  1. exact normalised NHS number;
  2. exact email + DOB;
  3. exact mobile + DOB;
  4. exact surname + DOB + normalised postcode.
- Unmatched source clients receive their own master identity; ambiguous cases are not guessed.
- Moved mastered-client Hub/Link into the Business Vault, reflecting that mastering is enterprise interpretation rather than raw source truth.
- Added PIT tables (`pit_client`, `pit_episode`).
- Added Bridges (`bridge_client_journey`, `bridge_client_clinician`).
- Added derived Business Vault waiting-time logic.
- Added dimensional Client, Clinician, Service, Organisation and Date dimensions plus Referral, Assessment, Session, Outcome, Risk and Goal facts.
- Added dbt tests for core keys, deterministic matching, sessions and outcomes.

## Important source constraint

No Contract table exists in the supplied Supabase schemas, so this revision does not invent a Contract Hub or fact. BrightPath organisation rows do contain contract dates, and these remain source attributes on the BrightPath Organisation Satellite.

## Layer flow

```text
Supabase / Fivetran raw tables
        -> dbt staging views
        -> Raw Vault (Hubs / Links / source Satellites)
        -> Business Vault (deterministic matching / mastering / PIT / Bridges / derived logic)
        -> Dimensional DW (Dimensions / Facts)
        -> Semantic views / Power BI
```

## Materialisation approach

- Staging: views
- Hubs: incremental insert-only behavior
- Links: incremental insert-only behavior
- Satellites: incremental historisation using HashDiff
- Business Vault current-state helpers: views
- Master Hub/Link: incremental
- PIT / Bridge / waiting-time helpers: tables rebuilt from persistent Vault
- Dimensional marts: tables for simplicity at the current practice scale

## Suggested run

```bash
dbt deps
dbt source freshness
dbt build
```

Start your review with:

1. `models/staging/onemind/stg_onemind__clients.sql`
2. `models/raw_vault/hub_client.sql`
3. `models/raw_vault/sat_client_onemind.sql`
4. `models/business_vault/bv_client_deterministic_match.sql`
5. `models/business_vault/bv_master_client_assignment.sql`
6. `models/business_vault/bridge_client_journey.sql`
7. `models/dimensional/core/fact_session.sql`
