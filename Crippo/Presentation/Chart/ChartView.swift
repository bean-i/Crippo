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
    
    private var isShowingToast: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.output.showToast },
            set: { viewModel.output.showToast = $0 }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text(viewModel.output.results.name)
                    .font(.largeTitle).bold()
                Text(viewModel.output.results.currentPrice)
                    .font(.largeTitle).bold()
                HStack {
                    Text(viewModel.output.results.priceChange24h)
                        .foregroundColor(Double(viewModel.output.results.priceChange24h.dropLast()) ?? 0 >= 0 ? .red : .blue)
                    Text("Today")
                        .foregroundStyle(.gray)
                }
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
            viewModel.output.isFavorite = viewModel.isFavorite(coinID: coinID)
            viewModel.action(.searchQuery(coinID))
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.action(.toggleFavorite(coinID))
                } label: {
                    
                    Image(systemName: viewModel.output.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.point)
                }
            }
        }
        .toast(
            isShowing: isShowingToast,
            message: viewModel.output.toastMessage ?? ""
        )
    }
}

// MARK: - PriceStatsView
private struct PriceStatsView: View {
    @ObservedObject var viewModel: ChartViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                StatItem(title: "고가", value: viewModel.output.results.high24h)
                StatItem(title: "신고점", value: viewModel.output.results.allTimeHighPrice)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 15) {
                StatItem(title: "저가", value: viewModel.output.results.low24h)
                StatItem(title: "신저점", value: viewModel.output.results.allTimeLowPrice)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3)
                .bold()
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
            }
        }
    }
}
