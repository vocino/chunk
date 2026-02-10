# Deployment Instructions

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

## Hosting Options

### Option 1: GitHub Pages (Free)
1. Build the web app: `flutter build web --release`
2. Copy contents of `build/web/` to GitHub Pages branch
3. Enable GitHub Pages in repository settings

### Option 2: Firebase Hosting (Free tier available)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init hosting`
4. Set public directory to `build/web`
5. Build: `flutter build web --release`
6. Deploy: `firebase deploy --only hosting`

### Option 3: Netlify (Free tier available)
1. Build: `flutter build web --release`
2. Drag and drop `build/web/` folder to Netlify
3. Or connect GitHub repo for auto-deploy

### Option 4: Vercel (Free tier available)
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
- Consider reducing gradient complexity

### Timer inaccurate on mobile
- This is a known limitation of web timers
- Accuracy within ±2 seconds over 20 minutes is acceptable
- Native app will solve this

### PWA not installable
- Verify manifest.json is being served
- Check HTTPS is enabled (required for PWA)
- Ensure service worker is registered
