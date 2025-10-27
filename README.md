# ImageFeed 📸

ImageFeed is an iOS application that allows users to view, like, and cache images from the Unsplash API. The app includes user authentication, profile management, and persistent local storage. Built as part of the Yandex Practicum iOS Developer curriculum and extended as a personal project.

---

## ✨ Features

- 🔐 OAuth 2.0 Authorization (Unsplash)
- 🖼 Load and cache photos from API
- ❤️ Like/Unlike functionality
- 👤 User profile with avatar and logout
- 🧠 MVP Architecture
- 🧪 Unit & UI Testing
- 🗂 Persistent data caching using Core Data

---

## 🛠 Technologies Used

- **Language:** Swift
- **UI:** UIKit, AutoLayout (programmatic)
- **Architecture:** MVP
- **Networking:** URLSession, REST API, JSON
- **Persistence:** Core Data, UserDefaults, Keychain
- **Image Caching:** Kingfisher
- **Testing:** XCTest, XCUITest

---

## 📂 Project Structure

ImageFeed
├── Auth
├── AuthService
├── Constants
├── ImagesList
├── ImagesListService
├── Profile
├── SingleImage
├── TabBarController
├── SplashViewController
├── ImageFeedTests
└── ImageFeedUITests


---

## 🏗 Architecture

The app uses the **MVP** pattern:
- `ViewController` handles only UI and delegates logic
- `Presenter` manages business logic and interacts with services
- `Service` layer handles networking, caching, and persistence

---

## 🚀 Getting Started

1. Clone the repository:
```bash
git clone https://github.com/DmitriiSeitsman/ImageFeed.git
Open ImageFeed.xcodeproj in Xcode.
Run the project on a simulator or device:
Cmd + R
🔑 To use Unsplash API, you need a valid access token and redirect URI.
