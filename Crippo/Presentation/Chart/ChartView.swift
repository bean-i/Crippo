//
//  ChartView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI

struct ChartView: View {
    
    @StateObject private var viewModel = ChartViewModel()
    let coinID: String  // 이전 화면에서 코인 ID를 받아옴
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(viewModel.output.results.name)
                    .font(.largeTitle).bold()
                Text(viewModel.output.results.currentPrice)
                    .font(.largeTitle).bold()
                Text(viewModel.output.results.priceChange24h)
                    .foregroundColor(Double(viewModel.output.results.priceChange24h.dropLast()) ?? 0 >= 0 ? .red : .blue)
            }
            PriceStatsView(viewModel: viewModel)

            SparklineChart(viewModel: viewModel)
                .frame(height: 200)
                .padding(.horizontal)

            Text("\(viewModel.output.results.lastUpdate) 업데이트")
                .font(.caption2)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()
        }
        .task {
            viewModel.action(.searchQuery(coinID))
        }
        .padding()
//        .navigationTitle(viewModel.output.results.name)
//        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // 즐겨찾기
                } label: {
                    Image(systemName: "star")
                        .foregroundColor(.point)
                }
            }
        }
    }
}

// 재사용 PriceStatsView
private struct PriceStatsView: View {
    @ObservedObject var viewModel: ChartViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                StatItem(title: "고가", value: viewModel.output.results.high24h)
                StatItem(title: "신고점", value: viewModel.output.results.allTimeHighPrice)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                StatItem(title: "저가", value: viewModel.output.results.low24h)
                StatItem(title: "신저점", value: viewModel.output.results.allTimeLowPrice)
            }
        }
    }
}

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(title == "고가" || title == "신고점" ? .red : .blue)
            Text(value.isEmpty ? "-" : value)
                .font(.subheadline)
        }
    }
}

private struct SparklineChart: View {
    @ObservedObject var viewModel: ChartViewModel

    var body: some View {
        GeometryReader { geo in
            let pts = viewModel.output.results.sparkline.price
            
            if !pts.isEmpty {
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
                            Color.purple.opacity(0.3),
                            Color.purple.opacity(0.8)
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
                .stroke(Color.purple, lineWidth: 2)

                // 3) Marker (예시 idx = 2)
                if pts.indices.contains(2) {
                    let x = CGFloat(2) * stepX
                    let y = geo.size.height - (CGFloat(pts[2] - minVal)/CGFloat(range)) * geo.size.height
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.purple, lineWidth: 2)
                        )
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// ChartViewConstants 유지
fileprivate enum ChartViewConstants {
    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d HH:mm:ss"
        return f
    }()
}
