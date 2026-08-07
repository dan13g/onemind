# Alignment with the Data Vault book

The project deliberately follows the book's core decisions:

- Raw Vault preserves source truth and source-qualified identities.
- Hubs contain identity only.
- Satellites contain mutable descriptions and history.
- Links contain relationships, not descriptive status.
- Cross-source client mastering lives in Business Vault.
- Client matching is deterministic only; fuzzy logic is intentionally excluded.
- PIT tables optimise access to latest Satellite versions.
- Bridges simplify repeated traversal of Client -> Referral -> Episode -> Session.
- Dimensional marts hide Data Vault complexity from Power BI.
- Small marts are rebuildable; persistent historical Raw Vault objects are incremental.
