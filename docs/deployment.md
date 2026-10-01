# Deployment Instructions

## Production: GitHub Pages (automatic)

Every push to `main` triggers `.github/workflows/pages.yml`, which runs
`flutter analyze` + `flutter test`, then builds (`flutter build web --release
--base-href /chunk/`) and deploys to GitHub Pages. No manual steps.

Flutter version is pinned in the workflow file. Bump it there (and verify the
build) rather than relying on a local SDK version.

## Building for Web

### Development Build
```bash
flutter run -d chrome
```

### Production Build
```bash
flutter build web --release
```

Output will be in `build/web/` directory.

## Alternative Hosting Options

### Firebase Hosting (Free tier available)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init hosting`
4. Set public directory to `build/web`
5. Build: `flutter build web --release`
6. Deploy: `firebase deploy --only hosting`

### Netlify (Free tier available)
1. Build: `flutter build web --release`
2. Drag and drop `build/web/` folder to Netlify
3. Or connect GitHub repo for auto-deploy

### Vercel (Free tier available)
1. Install Vercel CLI: `npm install -g vercel`
2. Build: `flutter build web --release`
3. Deploy: `vercel build/web`

## Testing Deployment

After deploying, test on:
- Desktop Chrome/Safari/Firefox
- Mobile Safari (iOS)
- Mobile Chrome (Android)
- iPad Safari

## PWA Installation

Users can "Add to Home Screen" on mobile:
- **iOS Safari**: Tap Share → Add to Home Screen
- **Android Chrome**: Tap Menu → Add to Home Screen

## Performance Monitoring

Monitor in production:
- Check DevTools Performance tab for frame rates
- Test timer accuracy over 20-minute sessions
- Verify break system triggers correctly
- Check for memory leaks in long sessions

## Troubleshooting

### Breathing circle not animating smoothly
- Check browser hardware acceleration is enabled
- Test on different devices
- Verify reduced-motion is off (animations intentionally freeze when it's on)

### Timer inaccurate on mobile
- Elapsed time is wall-clock derived, so throttled background tabs stay honest
- Accuracy within a few seconds over a long session is expected
- True background operation needs the native app (v2.0)

### PWA not installable
- Verify manifest.json is being served
- Check HTTPS is enabled (required for PWA)
- Ensure service worker is registered
