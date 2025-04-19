//
//  APIError.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

import Foundation

public enum APIError: Error {
    case data(Data, Int?)
    case decodeError(Data, Error)
    case message(String)
    case invalidResponse
    case cancelled
    case unauthorized(Data)
    case unknown(Error)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .data(_, statusCode):
            if let code = statusCode {
                return "サーバーから予期しないデータが返されました（エラーコード: \(code)）。しばらくしてから再度お試しください。"
            } else {
                return "サーバーから予期しないデータが返されました。しばらくしてから再度お試しください。"
            }
        case let .decodeError(_, error):
            return "データの読み込み中に問題が発生しました。\n\(error.localizedDescription)"
        case let .message(message):
            return "通信に失敗しました: \(message)"
        case .invalidResponse:
            return "サーバーから無効な応答が返されました。通信環境をご確認のうえ、再度お試しください。"
        case .cancelled:
            return "処理がキャンセルされました。通信環境をご確認のうえ、再度お試しください。"
        case .unauthorized:
            return "APIキーが正しくありません"
        case let .unknown(error):
            return "予期しないエラーが発生しました。しばらくしてからもう一度お試しください。\n\(error.localizedDescription)"
        }
    }
}
