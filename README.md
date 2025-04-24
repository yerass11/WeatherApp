# WeatherApp

# 🌦 WeatherApp

**WeatherApp** — это iOS-приложение для отображения текущей погоды, прогноза, качества воздуха и погодных предупреждений. Реализовано с использованием **SwiftUI**, **MVVM-архитектуры** и **современной concurrency-модели Swift (async/await)**.

## 🧠 Архитектура

Приложение построено по **MVVM**:
WeatherApp
├── Models/         // Сущности: CurrentWeather, Forecast, AirQuality и т.д.
├── ViewModels/     // Бизнес-логика и обработка состояния UI
├── Views/          // SwiftUI Views
├── Services/       // Сетевые вызовы и кэш
│   └── Manager/    // LocationManager, WeatherCache
└── WeatherApp.swift

## 🔧 Используемые технологии

- Swift
- SwiftUI
- Async/Await
- URLSession
- JSONDecoder
- Singleton-кэш для повышения производительности
- TaskGroup для параллельной загрузки данных

## ⚙️ Возможности

- Получение текущей погоды с WeatherAPI
- Прогноз погоды на 3 дня
- Поддержка геолокации
- Индекс качества воздуха (PM2.5, PM10, EPA)
- Погодные предупреждения *(заглушка или реализация с `/alerts.json`)*
- Кеширование с TTL (5 минут) для снижения количества API-запросов
- Поддержка отмены запросов при смене города

## 🚀 Как запустить

1. Получи API-ключ на [WeatherAPI.com](https://www.weatherapi.com/).
2. Вставь свой API-ключ в `WeatherService.swift`:

```swift
private let apiKey = "YOUR_API_KEY"
```

3. Запусти проект в Xcode 15+ на iOS 17+ симуляторе или устройстве.

## 🚀 Запуск проекта

Открой проект в **Xcode 15+** и запусти его на симуляторе или устройстве с **iOS 17+**.

---

## 📦 To-do / Возможные улучшения

- [ ] Улучение UI  
- [ ] Уведомления при резком ухудшении погоды   
- [ ] Локализация через `Localizable.strings`

