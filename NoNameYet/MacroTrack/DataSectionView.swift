import SwiftUI
import Charts

struct DataSectionView: View {
    @EnvironmentObject private var onboardingData: OnboardingData
    
    @State private var selectedMetric: ChartMetric = .calories
    @State private var timeRange: ChartTimeRange = .day

    var body: some View {
        ZStack {
            simpleBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("DATA ANALYTICS")
                        .font(SimplePalette.retroFont(size: 28, weight: .bold))
                        .foregroundStyle(SimplePalette.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    chartCard
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Data")
    }

    private var chartCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 20) {
                // Metric selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("METRIC")
                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)

                    HStack(spacing: 8) {
                        ForEach(ChartMetric.allCases) { metric in
                            Button(action: {
                                selectedMetric = metric
                            }) {
                                Text("\(metric.rawValue.uppercased())")
                                    .font(SimplePalette.retroFont(size: 12, weight: .bold))
                                    .foregroundStyle(selectedMetric == metric ? SimplePalette.retroBlack : SimplePalette.cardTextPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(selectedMetric == metric ? SimplePalette.retroWhite : SimplePalette.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .stroke(SimplePalette.retroBlack, lineWidth: 2)
                                            )
                                            .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Time range selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("TIME RANGE")
                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)

                    HStack(spacing: 8) {
                        ForEach(ChartTimeRange.allCases) { range in
                            Button(action: {
                                withAnimation {
                                    timeRange = range
                                }
                            }) {
                                Text(range.rawValue.uppercased())
                                    .font(SimplePalette.retroFont(size: 12, weight: .bold))
                                    .foregroundStyle(timeRange == range ? SimplePalette.retroBlack : SimplePalette.cardTextPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(timeRange == range ? SimplePalette.retroWhite : SimplePalette.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .stroke(SimplePalette.retroBlack, lineWidth: 2)
                                            )
                                            .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Divider().background(SimplePalette.cardBorder)

                // Chart
                chartView
                    .frame(height: 300)
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }

    private var chartView: some View {
        let chartData = onboardingData.getChartData(for: selectedMetric, timeRange: timeRange)

        return Chart {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date, unit: timeRange == .day ? .day : (timeRange == .week ? .weekOfYear : .month)),
                    y: .value(selectedMetric.rawValue, dataPoint.value)
                )
                .foregroundStyle(SimplePalette.accentBlue)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", dataPoint.date, unit: timeRange == .day ? .day : (timeRange == .week ? .weekOfYear : .month)),
                    y: .value(selectedMetric.rawValue, dataPoint.value)
                )
                .foregroundStyle(SimplePalette.accentBlue)
                .symbolSize(60)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                    .foregroundStyle(SimplePalette.cardBorder.opacity(0.5))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(formatDateLabel(date))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(SimplePalette.textSecondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(SimplePalette.cardBorder.opacity(0.5))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(SimplePalette.textSecondary)
                    }
                }
            }
        }
        .chartXAxisLabel("Time")
        .chartYAxisLabel("\(selectedMetric.rawValue) (\(selectedMetric.unit))")
    }

    private func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch timeRange {
        case .day:
            formatter.dateFormat = "MM/dd"
        case .week:
            formatter.dateFormat = "MM/dd"
        case .month:
            formatter.dateFormat = "MMM"
        }
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DataSectionView()
    }
    .environmentObject({
        let data = OnboardingData()
        data.generatePlaceholderPlan()
        return data
    }())
}
