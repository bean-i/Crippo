//
//  ChartView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI

struct ChartView: View {
    
    let coin: MarketCoin // 이전 화면에서 코인ID만 받아와도 될 듯.

    var body: some View {
        VStack(spacing: 16) {
            Text(coin.priceString)
                .font(.largeTitle).bold()
            Text(coin.changeString)
                .foregroundColor(coin.priceChange24h >= 0 ? .red : .blue)

            PriceStatsView(coin: coin)

            SparklineChart(data: coin.sparklineIn7d?.price ?? [])
                .frame(height: 200)
                .padding(.horizontal)

            Text("\(coin.lastUpdatedString) 업데이트")
                .font(.caption2)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()
        }
        .padding()
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // 즐겨찾기
                } label: {
                    Image(systemName: "star")
                        .foregroundColor(.purple)
                }
            }
        }
    }
}

// 가격/변동률 문자 포맷팅
private extension MarketCoin {
    var priceString: String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = ","
        return "₩\(fmt.string(from: NSNumber(value: currentPrice)) ?? "")"
    }
    var changeString: String {
        String(format: "%+.2f%% Today", priceChange24h)
    }
    var lastUpdatedString: String {
        ChartViewConstants.dateFormatter.string(from: lastUpdated ?? Date())
    }
}

// 재사용 PriceStatsView
private struct PriceStatsView: View {
    let coin: MarketCoin

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                StatItem(title: "고가", value: coin.high24h)
                Spacer()
                StatItem(title: "저가", value: coin.low24h)
            }
            HStack {
                StatItem(title: "신고점", value: coin.ath)
                Spacer()
                StatItem(title: "신저점", value: coin.atl)
            }
        }
    }
}

private struct StatItem: View {
    let title: String
    let value: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(title == "고가" || title == "신고점" ? .red : .blue)
            Text(value.map { String(format: "₩%.0f", $0) } ?? "-")
                .font(.subheadline)
        }
    }
}


fileprivate enum ChartViewConstants {
    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d HH:mm:ss"
        return f
    }()
}

private struct SparklineChart: View {
    let data: [Double]

    var body: some View {
        GeometryReader { geo in
            let pts = data
            let maxVal = pts.max() ?? 1
            let minVal = pts.min() ?? 0
            let range = maxVal - minVal
            let stepX = geo.size.width / CGFloat(max(pts.count - 1, 1))

            // 1) Area
            Path { path in
                pts.enumerated().forEach { i, val in
                    let x = CGFloat(i) * stepX
                    let y = geo.size.height - (CGFloat(val - minVal)/CGFloat(range)) * geo.size.height
                    if i == 0 { path.move(to: .init(x: x, y: y)) }
                    else       { path.addLine(to: .init(x: x, y: y)) }
                }
                path.addLine(to: .init(x: geo.size.width, y: geo.size.height))
                path.addLine(to: .init(x: 0, y: geo.size.height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.point.opacity(0.3),
                        Color.point.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // 2) Line
            Path { path in
                pts.enumerated().forEach { i, val in
                    let x = CGFloat(i) * stepX
                    let y = geo.size.height - (CGFloat(val - minVal)/CGFloat(range)) * geo.size.height
                    if i == 0 { path.move(to: .init(x: x, y: y)) }
                    else       { path.addLine(to: .init(x: x, y: y)) }
                }
            }
            .stroke(Color.point, lineWidth: 2)

            // 3) Marker (예시 idx = 2)
            if pts.indices.contains(2) {
                let x = CGFloat(2) * stepX
                let y = geo.size.height - (CGFloat(pts[2] - minVal)/CGFloat(range)) * geo.size.height
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.point, lineWidth: 2)
                    )
                    .position(x: x, y: y)
            }
        }
    }
}
