//
//  NetworkService.swift
//  Market
//
//  Created by Дмитриев Антон on 26.04.2026.
//

import Foundation

struct CurrencyRate {
    let code: String
    let rate: Double
}

struct ExchangeOffer {
    let sellerName: String
    let pair: String
    let rate: Double
    let reserve: Double
}

enum NetworkError: Error {
    case noInternet
    case parsing
    case forbidden
    case unknown
}

final class NetworkService: NSObject {
    func loadRates(completion: @escaping (Result<[CurrencyRate], NetworkError>) -> Void) {
        guard let url = URL(string: "https://www.cbr.ru/scripts/XML_daily.asp") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.noInternet))
                return
            }

            if let http = response as? HTTPURLResponse,
               400...499 ~= http.statusCode {
                completion(.failure(.forbidden))
                return
            }

            guard let data else {
                completion(.failure(.unknown))
                return
            }

            let parser = XMLRateParser()

            let result = parser.parse(data: data)

            if result.isEmpty {
                completion(.failure(.parsing))
            } else {
                completion(.success(result))
            }

        }.resume()
    }

    func makeExchange(amount: Double, completion: @escaping (Result<Void, NetworkError>) -> Void) {

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let success = Bool.random()

            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
}

final class XMLRateParser: NSObject, XMLParserDelegate {
    private var rates: [CurrencyRate] = []

    private var currentCode = ""
    private var currentValue = ""
    private var currentElement = ""

    func parse(data: Data) -> [CurrencyRate] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()

        return rates
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "CharCode" {
            currentCode += string
        }

        if currentElement == "Value" {
            currentValue += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "Valute" {
            let rate = Double(
                currentValue
                    .replacingOccurrences(of: ",", with: ".")
            ) ?? 0

            rates.append(
                CurrencyRate(
                    code: currentCode.trimmingCharacters(in: .whitespacesAndNewlines),
                    rate: rate
                )
            )

            currentCode = ""
            currentValue = ""
        }

        currentElement = ""
    }
}

final class OfferGenerator {
    func makeOffers(
        from: String,
        to: String,
        rates: [CurrencyRate]
    ) -> [ExchangeOffer] {

        guard let toRate = rates.first(where: { $0.code == to })?.rate
        else { return [] }

        var offers: [ExchangeOffer] = []

        for i in 1...10 {

            let discount = Double.random(in: 0.90...1.05)

            let price = toRate * discount

            offers.append(
                ExchangeOffer(
                    sellerName: "Seller \(i)",
                    pair: "\(from)-\(to)",
                    rate: price,
                    reserve: Double.random(in: 1000...50000)
                )
            )
        }

        return offers.sorted { $0.rate > $1.rate }
    }
}
