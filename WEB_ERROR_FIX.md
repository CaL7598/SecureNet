# Fixing Web Mode Errors

## Common Errors and Solutions

### Error 1: "Cannot find module '@expo/webpack-config'"

**Solution:**
```bash
cd mobile-app
npm install @expo/webpack-config react-dom
```

### Error 2: "Cannot find module 'react-dom'"

**Solution:**
```bash
cd mobile-app
npm install react-dom
```

### Error 3: "Web support is not available"

**Solution:**
1. Install web dependencies:
   ```bash
   npm install @expo/webpack-config react-dom
   ```

2. Make sure `webpack.config.js` exists in `mobile-app/` directory

3. Clear cache and restart:
   ```bash
   npm start -- --clear
   ```

### Error 4: "Module not found" errors

**Solution:**
```bash
cd mobile-app
rm -rf node_modules package-lock.json
npm install
npm start -- --clear
```

### Error 5: "Port 19006 already in use"

**Solution:**
```bash
# Kill the process using the port, or
# Expo will automatically use the next available port
npm start -- --port 19007
```

## Complete Fix Steps

If you're getting any web-related errors, run these commands:

```bash
cd mobile-app

# 1. Install web dependencies
npm install @expo/webpack-config react-dom

# 2. Clear cache
npm start -- --clear

# 3. Try again
npm run web
```

## Verify Installation

After installing dependencies, check `package.json` should have:
- `"react-dom": "18.2.0"`
- `"@expo/webpack-config": "^19.0.0"`

## Still Having Issues?

1. **Check Expo version:**
   ```bash
   npx expo --version
   ```

2. **Update Expo:**
   ```bash
   npm install expo@latest
   ```

3. **Check Node version:**
   ```bash
   node --version
   ```
   Should be Node 16+ for Expo 49

4. **Share the exact error message** and I can help fix it!
