//
//  WebSocketApiResponse.swift
//  FakeBithumbAssignment
//
//  Created by momo on 2022/02/23.
//

import Foundation

/// 빗썸 Web Socket API Response 응답
struct BTSocketAPIResponse {
    /// 구독 메시지 종류
    enum ResponseType: String, Decodable {
        /// 현재가
        case ticker = "ticker"
        /// 체결
        case transaction = "transaction"
        /// 호가
        case orderBook  = "orderbookdepth"
    }
    
    /// 통화코드
    enum Symbol: String, Decodable {
        case btc = "BTC_KRW"
        case eth = "ETH_KRW"
    }
    
    /// tick 종류
    enum TickType: String, Decodable {
        case _30m = "30M"
        case _1h = "1H"
        case _12h = "12H"
        case _24h = "24H"
        case mid = "MID"
    }
    
    /// Ticker API 응답
    struct TickerResponse: Decodable {
        /// WebSocket API type
        let type: ResponseType
        /// Ticker 응답의 유의미한 값
        let content: Ticker
        
        /// Ticker 응답의 유의미한 값
        struct Ticker: Decodable {
            /// 통화 코드
            let symbol: Symbol
            /// 변동 기준시간- 30M, 1H, 12H, 24H, MID
            let tickType: TickType
            /// 일자
            let date: Int
            /// 시간
            let time: Int
            /// 시가
            let openPrice: Int
            /// 종가
            let closePrice: Int
            /// 저가
            let rowPrice: Int
            /// 고가
            let highPrice: Int
            /// 누적거래금액
            let value: Double
            /// 누적거래량
            let volume: Double
            /// 매도누적거래량
            let sellVolume: Double
            /// 매수누적거래량
            let buyVolume: Double
            /// 전일종가
            let prevClosePrice: Int
            /// 변동률
            let chgRate: Double
            /// 변동금액
            let chgAmt: Int
            /// 체결강도
            let volumePower: Double
        }
    }
    
    /// Transaction API 응답
    struct TransactionResponse: Decodable {
        /// WebSocket API type
        let type: ResponseType
        /// Transaction API의 유의미한 값
        let content: Content
        
        /// Transaction API의 유의미한 값
        struct Content: Decodable {
            /// 체결 이력
            let list: [Transaction]
            
            /// 체결
            struct Transaction: Decodable {
                /// 통화코드
                let symbol: Symbol
                /// 체결종류
                let buySellGb: BuyCell
                /// 체결가격
                let contPrice: Int
                /// 체결수량
                let contQty: Double
                /// 체결금액
                let contAmt: Double
                /// 체결시각
                let contDtm: Date
                /// 직전시세와 비교
                let updn: UpDown
                
                /// 체결종류
                enum BuyCell: String, Decodable {
                    /// 매도체결
                    case sell = "1"
                    /// 매수체결
                    case buy = "2"
                }
                
                /// 직전시세와 비교
                enum UpDown: String, Decodable {
                    /// 상승
                    case up = "up"
                    /// 하락
                    case down = "dn"
                }
            }
        }
    }
    
    /// OrderBook API 응답
    struct OrderBookResponse: Decodable {
        /// WebSocket API type
        let type: ResponseType
        /// OrderBook API의 유의미한 값
        let content: Content
        
        /// OrderBook API의 유의미한 값
        struct Content: Decodable {
            /// 호가 이력
            let list: [OrderBook]
            /// 일시
            let dateTime: Int
            
            /// 호가
            struct OrderBook: Decodable {
                /// 통화코드
                let symbol: Symbol
                /// 주문 타입
                let orderType: OrderType
                /// 호가
                let price: Int
                /// 잔량
                let quantity: Double
                /// 건수
                let total: Int
                
                /// 주문 타입
                enum OrderType: Decodable {
                    /// 매도
                    case ask
                    /// 매수
                    case bid
                }
            }
        }
    }
}
