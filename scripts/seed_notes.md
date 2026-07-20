# Seed notes

`SeedService.seedDefaultRooms()` creates the six standard demo rooms only when
the `rooms` collection is empty. It is intentionally not called during app
startup. Wire it to an Admin-only debug/setup action after Firebase is configured.

The operation is idempotent for the normal case: a second call sees an existing
room and creates zero documents. Run it with an authenticated Admin account.
