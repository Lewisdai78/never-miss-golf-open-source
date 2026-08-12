# Never Miss Golf website

An anonymous, static product site for the Never Miss Golf prototype.

## Privacy baseline

- No account, forms, cookies, analytics, advertising, maps, or remote fonts.
- No personal name, face, school, home, course, coordinate, or location history.
- No link to the private development repository.
- The product boundary is explicit: the reminder does not silently start Apple Workout.

## Local development

Requires Node.js 22.13 or newer and pnpm.

```sh
pnpm install
pnpm dev
```

## Verification

```sh
pnpm build
pnpm test
pnpm lint
```

The worker adds a restrictive Content Security Policy and disables browser access to camera, microphone, and geolocation.

The hosted preview is owner-only until the separate public-release checklist is complete.
