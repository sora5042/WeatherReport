//
//  StringExtension.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/20.
//

import Foundation

extension String {
    /// 指定した入力・出力フォーマットで日付文字列を変換する
    /// - Parameters:
    ///   - inputFormat: 元の日付文字列のフォーマット
    ///   - outputFormat: 変換後のフォーマット
    ///   - locale: ロケール（省略時は"ja_JP"）
    /// - Returns: 変換後の日付文字列（変換できない場合はnil）
    func convertDateFormat(inputFormat: String, outputFormat: String, locale: Locale = Locale(identifier: "ja_JP")) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = locale

        guard let date = inputFormatter.date(from: self) else {
            return nil
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        outputFormatter.locale = locale

        return outputFormatter.string(from: date)
    }
}
