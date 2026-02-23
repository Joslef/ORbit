<h1 align="center">
  <br>
  ORbit
  <br>
</h1>

<h4 align="center">OpenRouter credit balance, always one glance away — right in your macOS menu bar.</h4>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5.0-orange?style=flat-square&logo=swift" alt="Swift 5.0">
  <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT License">
</p>

<br>

## What is ORbit?

ORbit is a lightweight macOS menu bar app that shows your [OpenRouter](https://openrouter.ai) credit balance at a glance. No browser tab needed — your balance lives right next to the clock.

- **Instant balance display** — see your credits without opening a browser
- **Auto-refresh** — balance updates every 5 minutes automatically
- **Secure by design** — API key stored exclusively in the macOS Keychain, never in plain text
- **Zero bloat** — no third-party dependencies, pure Swift + SwiftUI
- **Sandboxed** — runs with minimal permissions (outbound network only)

---

## Requirements

- macOS 14 Sonoma or later
- An [OpenRouter](https://openrouter.ai) account and API key

---

## Installation

### Build from source

1. **Clone the repository**
   ```bash
   git clone https://github.com/Joslef/ORbit.git
   cd ORbit
   ```

2. **Open in Xcode**
   ```bash
   open OpenRouterMenubar.xcodeproj
   ```

3. **Set your development team**
   - In Xcode, select the `OpenRouterMenubar` target
   - Go to **Signing & Capabilities**
   - Select your Apple Developer account under **Team**

4. **Build and run**
   - Press `⌘ + R` or click **Product → Run**
   - ORbit will appear in your menu bar

---

## Setup

### Get your OpenRouter API key

1. Go to [openrouter.ai/keys](https://openrouter.ai/keys)
2. Click **Create Key**
3. Copy the key — it starts with `sk-or-...`

### Add your key to ORbit

1. Click the ORbit icon in your menu bar
2. Select **API Key Settings...** (or press `, `)
3. Paste your API key and press **Return** or click **Save Key**
4. Your balance appears instantly in the menu bar

> Your API key is stored securely in the macOS Keychain and never leaves your device unencrypted.

---

## Menu bar display

| Display | Meaning |
|---------|---------|
| `$2.50` | Your current credit balance |
| `OR: ...` | Loading balance |
| `OR: ?` | Error fetching balance (check your key) |
| `OR: --` | No API key configured |

---

## Security

ORbit was designed with security as a priority:

- API key stored in **macOS Keychain** with `WhenUnlockedThisDeviceOnly` — never synced to iCloud
- **Hardened Runtime** enabled — prevents code injection attacks
- **App Sandbox** active — only outbound network access is permitted
- Network requests use an **ephemeral URLSession** — no on-disk response caching
- **No logging** of sensitive data anywhere in the codebase
- Zero third-party dependencies — no supply chain risk

---

## License

MIT — see [LICENSE](LICENSE) for details.
