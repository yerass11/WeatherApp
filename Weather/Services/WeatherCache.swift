import Foundation

class WeatherCache {
    static let shared = WeatherCache()
    
    private init() {}
    
    // Храним кэш как словарь: ключ — идентификатор (например, "forecast_Moscow"), значение — кортеж (данные, время сохранения)
    private var cache: [String: (data: Any, timestamp: Date)] = [:]
    
    /// Попытка вернуть кэшированные данные, если они не устарели
    func getCachedData<T>(for key: String, expiration: TimeInterval) -> T? {
        if let cached = cache[key] as? (data: T, timestamp: Date) {
            if Date().timeIntervalSince(cached.timestamp) < expiration {
                return cached.data
            } else {
                // Если срок истёк – удаляем данные
                cache[key] = nil
            }
        }
        return nil
    }
    
    /// Установка данных в кэш
    func setCachedData<T>(data: T, for key: String) {
        cache[key] = (data: data, timestamp: Date())
    }
}
