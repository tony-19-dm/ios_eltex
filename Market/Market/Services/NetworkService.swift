//
//  NetworkService.swift
//  Market
//
//  Created by Дмитриев Антон on 26.04.2026.
//

import Foundation

enum NetworkError: Error {
    case noInternet
    case parsingError
    case unauthorized
    case serverError(code: Int)
    case unknown
    case invalidInput
    case insufficientReserve
}

struct ExchangeRateDTO: Decodable {
    let rates: [String: Double]
}

final class NetworkService {
    func request<T: Decodable>(
        url: URL,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        AppLogger.network.requestStarted(url: url)

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as NSError? {
                if error.domain == NSURLErrorDomain {
                    AppLogger.network.requestFailure(url: url, err: .noInternet)
                    completion(.failure(.noInternet))
                } else {
                    AppLogger.network.requestFailure(url: url, err: .unknown)
                    completion(.failure(.unknown))
                }
                return
            }

            guard let http = response as? HTTPURLResponse else {
                AppLogger.network.requestFailure(url: url, err: .unknown)
                completion(.failure(.unknown))
                return
            }

            AppLogger.network.requestSuccess(url: url, statusCode: http.statusCode)

            if (400...499).contains(http.statusCode) {
                AppLogger.network.requestFailure(url: url, err: .parsingError)
                completion(.failure(.parsingError))
                return
            }

            if (500...599).contains(http.statusCode) {
                let networkError = NetworkError.serverError(code: http.statusCode)
                AppLogger.network.requestFailure(url: url, err: networkError)
                completion(.failure(networkError))
                return
            }

            guard let data = data else {
                AppLogger.network.requestParsingFailure(url: url)
                completion(.failure(.parsingError))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                AppLogger.network.requestParsingFailure(url: url)
                completion(.failure(.parsingError))
            }
        }

        task.resume()
    }
}

extension NetworkError {
    var localizedMessage: String {
        switch self {
        case .noInternet:
            return "Нет подключения к интернету"
        case .parsingError:
            return "Что-то пошло не так, попробуйте позже"
        case .unauthorized:
            return "Нет прав на просмотр данного раздела"
        case .invalidInput:
            return "Введите корректную сумму"
        case .insufficientReserve:
            return "Сумма превышает резерв продавца"
        default:
            return "Неизвестная ошибка"
        }
    }
}
