# Apocalypse Trading App

A post-apocalyptic trading app that allows survivors to trade resources in a secure and trust-based environment. Built with SwiftUI for iOS.

## Features

### Trading System
- Create and manage trade offers with detailed item quantities
- Automatic scanning for nearby survivors with matching offers
- Secure trade confirmation process
- Trade history tracking and management

### Survivor Profiles
- Create and manage your survivor profile
- Track your trading statistics
- Maintain a public key for secure identification
- Customize your alias and tagline

### Trader Network
- View and manage trader profiles
- Add notes and tags to track trader reliability
- Maintain a history of trades with each trader
- Build trust through successful trades

### Security
- Secure authentication system
- Biometric login support
- Encrypted data storage
- Unique public keys for each survivor

## Getting Started

### Prerequisites
- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/Apocalypse.git
```

2. Open the project in Xcode
```bash
cd Apocalypse
open Apocalypse.xcodeproj
```

3. Build and run the project in Xcode

## Project Structure

```
Apocalypse/
├── Models/
│   ├── Offer.swift
│   ├── Survivor.swift
│   ├── TradeHistory.swift
│   ├── TraderProfile.swift
│   └── UserProfile.swift
├── Views/
│   ├── HomeView.swift
│   ├── LogView.swift
│   ├── MainTabView.swift
│   ├── ProfileView.swift
│   └── TradeView.swift
└── ApocalypseApp.swift
```

## Usage

### Creating a Trade Offer
1. Navigate to the Home tab
2. Enter the items you have and need
3. Specify quantities for each item
4. Your offer will be automatically shared with nearby survivors

### Finding Trade Partners
1. Go to the Trade tab
2. The app automatically scans for nearby survivors
3. View available offers from other survivors
4. Select a matching offer to initiate a trade

### Managing Trader Profiles
1. Access the Log tab
2. View your trade history
3. Add traders to your profile list
4. Add notes and tags to track trader reliability

### Profile Management
1. Go to the Profile tab
2. Edit your alias and tagline
3. View your trading statistics
4. Access your public key for identification

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- SwiftUI for the modern UI framework
- UserDefaults for local data persistence
- Multipeer Connectivity for nearby device discovery 