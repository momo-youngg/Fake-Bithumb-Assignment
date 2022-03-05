//
//  CandleStickChartView.swift
//  FakeBithumbAssignment
//
//  Created by momo on 2022/02/26.
//

import UIKit

import Then

class CandleStickChartView: UIView {
    
    // MARK: - instance property
    
    /// 스크롤 뷰
    private let scrollView: UIScrollView = UIScrollView().then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
    }
    /// 스크롤 뷰를 가득 채울 레이어
    private let mainLayer: CALayer = CALayer()
    /// dateTimeLayer를 제외하고 실제 차트가 그려질 레이어 (스크롤에 포함)
    private let dataLayer: CALayer = CALayer()
    /// 아래 날짜, 시간 영역을 그려 줄 레이어 (스크롤에 포함)
    private let dateTimeLayer: CALayer = CALayer()
    /// 오른쪽 값 영역을 그려줄 레이어
    private let valueLayer: CALayer = CALayer()
    /// 가로줄을 그려줄 레이어
    private let horizontalGridLayer: CALayer = CALayer()
    /// 세로줄을 그려줄 레이어 (스크롤에 포함)
    private let verticalGridLayer: CALayer = CALayer()
    
    /// 양봉 색상
    private let redColor: CGColor = CGColor(red: 194/255, green: 72/255, blue: 79/255, alpha: 1.0)
    /// 음봉 색상
    private let blueColor: CGColor = CGColor(red: 50/255, green: 93/255, blue: 202/255, alpha: 1.0)
    /// 기본 선 색상
    private let defaultColor: CGColor = CGColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1.0)
    /// 그리드 선 색상
    private let gridColor: CGColor = CGColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    /// 기본 선 너비
    private let defaultLineWidth: CGFloat = 1.0
    /// 그리드 선 너비
    private let gridWidth: CGFloat = 0.5
    /// 기본 텍스트 크기
    private let defaultFontSize: CGFloat = 11.0
    /// 오른쪽 값 영역의 너비
    private let valueWidth: CGFloat = 50.0
    /// 오른쪽 값 영역에 표시될 값의 개수
    private let numbersOfValueInFrame: Int = 10
    /// 아래 날짜, 시간 영역의 높이
    private let dateTimeHeight: CGFloat = 40.0
    /// 한 화면에 나올 날짜, 시간 레이블의 개수
    private let numbersOfDateTimeInFrame: Int = 3
    /// 수치 표시할 때 튀어나온 선 길이
    private let thornLength: CGFloat = 10.0
    /// 수치 표시할 때 튀어나온 선 - 수치 텍스트 간격
    private let thornTextSpace: CGFloat = 5.0
    /// 날짜, 시간 레이블의 크기
    private let defaultTextSize: CGSize = CGSize(width: 60.0, height: 20.0)
    /// 캔들스틱 너비
    private var candleStickWidth: CGFloat = 5.0
    /// 확대 후 최대 캔들스틱 너비
    private var maxCandleStickWidth: CGFloat = 20.0
    /// 축소 후 최소 캔들스틱 너비
    private var minCandleStickWidth: CGFloat = 2.0
    /// 캔들스틱 얇은 선 너비
    private var candleStickLineWidth: CGFloat = 1.5
    /// 캔들스틱 간격
    private var candleStickSpace: CGFloat = 2.0
    /// 캔들스틱 차트 영역 위, 빈 공간 비율
    private let verticalFrontRearSpaceRate: CGFloat = 0.1
    /// 그래프 맨앞, 맨 뒤의 빈 공간
    private var horizontalFrontRearSpace: CGFloat {
        get {
            self.bounds.size.width / 3
        }
    }
    
    /// 캔들스틱 값들
    private var candleSticks: [CandleStick] = []
    /// 현재 화면에 그려야 할 캔들스틱 인덱스 범위
    private var drawingTargetIndex: ClosedRange<Int> = (0...0)
    /// 현재 화면에 있는 캔들스틱 중 최고 가격
    private var maxPrice: Double = 0.0
    /// 현재 화면에 있는 캔들스틱 중 최저 가격
    private var minPrice: Double = 0.0
    /// 처음으로 그려지는 상태인지?
    private var isInitialState: Bool = true
    
    // MARK: - Initializer
        
    init(with candleSticks: [CandleStick]) {
        self.candleSticks = candleSticks
        super.init(frame: .zero)
        self.scrollView.delegate = self
        self.setupLayers()
        self.setupPinchGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollView.delegate = self
        self.setupLayers()
        self.setupPinchGesture()
    }
    
    // MARK: - custom func
    
    private func setupPinchGesture() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    func updateCandleSticks(of candleSticks: [CandleStick]) {
        DispatchQueue.main.async {
            self.candleSticks = candleSticks
            self.setNeedsLayout()
        }
    }
    
    private func updateDrawingTargetIndex() {
        let contentOffset: CGPoint = self.scrollView.contentOffset
        let currentXRange = (contentOffset.x...(contentOffset.x + self.scrollView.bounds.width))
        let targetIndex = (0..<self.candleSticks.count).filter {
            currentXRange.contains(self.getXCoord(indexOf: $0))
        }
        guard let min = targetIndex.min(), let max = targetIndex.max() else {
            return
        }
        self.drawingTargetIndex = (min...max)
    }
    
    private func updateMaxMinPrice() {
        guard let maxIndex: Int = self.drawingTargetIndex.max(
            by: { self.candleSticks[$0].highPrice < self.candleSticks[$1].highPrice }
        ) else {
            return
        }
        guard let minIndex: Int = self.drawingTargetIndex.min(
            by: { self.candleSticks[$0].lowPrice < self.candleSticks[$1].lowPrice }
        ) else {
            return
        }
        self.maxPrice = self.candleSticks[maxIndex].highPrice
        self.minPrice = self.candleSticks[minIndex].lowPrice
    }
    
    private func setupLayers() {
        // 스크롤에 포함될 전체 영역인 mainLayer
        self.mainLayer.addSublayer(self.verticalGridLayer)
        self.mainLayer.addSublayer(self.dataLayer)
        self.mainLayer.addSublayer(self.dateTimeLayer)
        self.scrollView.layer.addSublayer(self.mainLayer)
        // 가로줄, 값은 스크롤 되지 않음
        self.layer.addSublayer(self.horizontalGridLayer)
        self.layer.addSublayer(self.valueLayer)
        // subView로 추가
        self.addSubview(self.scrollView)
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        self.cleanLayers()
        self.setFrame()
        self.drawDivivisionLine()
        guard !self.candleSticks.isEmpty else {
            return
        }
        self.moveScrollIfInitialState()
        self.updateDrawingTargetIndex()
        self.updateMaxMinPrice()
        self.drawDateTime()
        self.drawValue()
        self.drawChart()
        CATransaction.commit()
    }
    
    private func moveScrollIfInitialState() {
        guard isInitialState && !self.candleSticks.isEmpty else {
            return
        }
        self.scrollView.contentOffset = CGPoint(
            x: self.scrollView.contentSize.width -
            self.horizontalFrontRearSpace -
            self.scrollView.bounds.width / 2.0,
            y: 0
        )
        self.isInitialState = false
    }
    
    private func setFrame() {
        let chartContentWidth: CGFloat = 2 * self.horizontalFrontRearSpace
        + CGFloat(self.candleSticks.count) * self.candleStickWidth
        + (CGFloat(self.candleSticks.count) - 1) * self.candleStickSpace
        let chartContentHeight: CGFloat = self.bounds.height - self.dateTimeHeight
        
        self.scrollView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.bounds.size.width - self.valueWidth,
            height: self.bounds.size.height
        )
        self.scrollView.contentSize = CGSize(
            width: chartContentWidth,
            height: self.bounds.size.height
        )
        self.mainLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: chartContentWidth,
            height: self.bounds.size.height
        )
        self.dataLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: chartContentWidth,
            height: chartContentHeight
        )
        self.dateTimeLayer.frame = CGRect(
            x: 0,
            y: chartContentHeight,
            width: chartContentWidth,
            height: self.dateTimeHeight
        )
        self.valueLayer.frame = CGRect(
            x: self.bounds.size.width - self.valueWidth,
            y: 0,
            width: self.valueWidth,
            height: chartContentHeight
        )
        self.horizontalGridLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: self.bounds.size.width - self.valueWidth,
            height: chartContentHeight
        )
        self.verticalGridLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: chartContentWidth - self.valueWidth,
            height: chartContentHeight
        )
    }
    
    private func cleanLayers() {
        self.dataLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.dateTimeLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.valueLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.horizontalGridLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.verticalGridLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    private func drawChart() {
        self.drawingTargetIndex.forEach { index in
            let candleStick: CandleStick = candleSticks[index]
            let xCoord: CGFloat = getXCoord(indexOf: index)
            let color: CGColor = candleStick.type == .blue ? self.blueColor : self.redColor
            guard let openingPriceYCoord: CGFloat = self.getYCoord(of: candleStick.openingPrice) else {
                return
            }
            guard let highPriceYCoord: CGFloat = self.getYCoord(of: candleStick.highPrice) else {
                return
            }
            guard let lowPriceYCoord: CGFloat = self.getYCoord(of: candleStick.lowPrice) else {
                return
            }
            guard let tradePriceYCoord: CGFloat = self.getYCoord(of: candleStick.tradePrice) else {
                return
            }
            let lineLayer: CALayer = CALayer().then {
                $0.frame = CGRect(
                    x: xCoord - self.candleStickLineWidth / 2,
                    y: highPriceYCoord,
                    width: self.candleStickLineWidth,
                    height: lowPriceYCoord - highPriceYCoord
                )
                $0.backgroundColor = color
            }
            let rectLayer: CALayer = CALayer().then {
                $0.frame = CGRect(
                    x: xCoord - self.candleStickWidth / 2,
                    y: min(openingPriceYCoord, tradePriceYCoord),
                    width: self.candleStickWidth,
                    height: max(openingPriceYCoord, tradePriceYCoord) -
                    min(openingPriceYCoord, tradePriceYCoord)
                )
                $0.backgroundColor = color
            }
            self.dataLayer.addSublayer(lineLayer)
            self.dataLayer.addSublayer(rectLayer)
        }
    }
    
    private func drawDateTime() {
        // 몇개의 캔들스틱당 날짜 & 세로그리드를 그려 줘야 하는지?
        let drawPerCandleStickCount: Int = Int(
            (self.scrollView.bounds.size.width / CGFloat(self.numbersOfDateTimeInFrame)) / (self.candleStickWidth + self.candleStickSpace)
        )
        let timeFormatter = DateFormatter().then {
            $0.dateFormat = "M/d HH:mm"
        }
        self.drawingTargetIndex.forEach { index in
            guard ((self.candleSticks.count-1) - index) % drawPerCandleStickCount == 0 else {
                return
            }
            let xCoord: CGFloat = getXCoord(indexOf: index)
            let date: Date = self.candleSticks[index].date
            let thornLineLayer: CAShapeLayer = CAShapeLayer.lineLayer(
                from: CGPoint(x: xCoord, y: 0),
                to: CGPoint(x: xCoord, y: self.thornLength),
                color: self.defaultColor,
                width: self.defaultLineWidth
            )
            let textLayer: CATextLayer = CATextLayer().then {
                $0.frame = CGRect(
                    x: xCoord - (self.defaultTextSize.width / 2),
                    y: self.thornLength + self.thornTextSpace,
                    width: self.defaultTextSize.width,
                    height: self.defaultTextSize.height
                )
                $0.foregroundColor = self.defaultColor
                $0.backgroundColor = UIColor.clear.cgColor
                $0.alignmentMode = CATextLayerAlignmentMode.center
                $0.contentsScale = UIScreen.main.scale
                $0.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                $0.fontSize = self.defaultFontSize
                $0.string = timeFormatter.string(from: date)
            }
            self.dateTimeLayer.addSublayer(thornLineLayer)
            self.dateTimeLayer.addSublayer(textLayer)
            let gridLayer: CAShapeLayer = CAShapeLayer.lineLayer(
                from: CGPoint(x: xCoord, y: 0),
                to: CGPoint(x: xCoord, y: self.bounds.height - self.dateTimeHeight),
                color: self.gridColor,
                width: gridWidth
            )
            self.verticalGridLayer.addSublayer(gridLayer)
        }
    }
    
    private func drawDivivisionLine() {
        let horizontalLine: CAShapeLayer = CAShapeLayer.lineLayer(
            from: CGPoint(x: -(2 * self.mainLayer.bounds.size.width), y: 0),
            to: CGPoint(x: (2 * self.mainLayer.bounds.size.width), y: 0),
            color: self.defaultColor,
            width: self.defaultLineWidth
        )
        let verticalLine: CAShapeLayer = CAShapeLayer.lineLayer(
            from: .zero,
            to: CGPoint(x: 0, y: self.bounds.height - self.dateTimeHeight),
            color: self.defaultColor,
            width: self.defaultLineWidth
        )
        self.dateTimeLayer.addSublayer(horizontalLine)
        self.valueLayer.addSublayer(verticalLine)
    }
    
    private func drawValue() {
        let valueGap: Double = (self.maxPrice - self.minPrice) / Double(self.numbersOfValueInFrame - 1)
        (0..<self.numbersOfValueInFrame).forEach { valueCount in
            let value: Double = self.maxPrice - valueGap * Double(valueCount)
            guard let yCoord: CGFloat = getYCoord(of: value) else {
                return
            }
            let thornLineLayer: CAShapeLayer = CAShapeLayer.lineLayer(
                from: CGPoint(x: 0, y: yCoord),
                to: CGPoint(x: self.thornLength, y: yCoord),
                color: self.defaultColor,
                width: self.defaultLineWidth
            )
            let textLayer: CATextLayer = VerticalCenterCATextLayer().then {
                $0.frame = CGRect(
                    x: self.thornLength + self.thornTextSpace,
                    y: yCoord - self.defaultTextSize.height / 2,
                    width: self.defaultTextSize.width,
                    height: self.defaultTextSize.height
                )
                $0.foregroundColor = self.defaultColor
                $0.backgroundColor = UIColor.clear.cgColor
                $0.alignmentMode = CATextLayerAlignmentMode.left
                $0.contentsScale = UIScreen.main.scale
                $0.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                $0.fontSize = self.defaultFontSize
                $0.string = String(Int(value))
            }
            self.valueLayer.addSublayer(thornLineLayer)
            self.valueLayer.addSublayer(textLayer)
            
            let gridLayer: CAShapeLayer = CAShapeLayer.lineLayer(
                from: CGPoint(x: 0, y: yCoord),
                to: CGPoint(x: self.verticalGridLayer.bounds.width, y: yCoord),
                color: self.gridColor,
                width: gridWidth
            )
            self.horizontalGridLayer.addSublayer(gridLayer)
        }
    }
    
    private func getYCoord(of current: Double) -> CGFloat? {
        let chartContentHeight: CGFloat = self.bounds.size.height - self.dateTimeHeight
        return ((self.maxPrice - current) / (self.maxPrice - self.minPrice)) *
        (chartContentHeight * (1 - self.verticalFrontRearSpaceRate)) +
        (chartContentHeight * self.verticalFrontRearSpaceRate) / 2
    }
    
    private func getXCoord(indexOf index: Int) -> CGFloat {
        return (self.horizontalFrontRearSpace + self.candleStickWidth / 2.0) +
        CGFloat(index - 1) * (self.candleStickWidth + self.candleStickSpace)
    }
    
    // MARK: - @objc

    @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        let newCandleStickWidth = self.candleStickWidth * pinch.scale
        if (newCandleStickWidth > self.maxCandleStickWidth ||
            newCandleStickWidth < self.minCandleStickWidth) {
            return
        }
        self.candleStickWidth *= pinch.scale
        self.candleStickSpace *= pinch.scale
        self.candleStickLineWidth *= pinch.scale
        let newX = self.scrollView.contentOffset.x * pinch.scale
        self.scrollView.contentOffset = CGPoint(x: newX, y: 0)
        setNeedsLayout()
        pinch.scale = 1
    }
}

extension CandleStickChartView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }
}

extension CandleStickChartView {
    /// 캔들스틱 값
    struct CandleStick {
        /// 일시
        let date: Date
        /// 시가
        let openingPrice: Double
        /// 고가
        let highPrice: Double
        /// 저가
        let lowPrice: Double
        /// 종가
        let tradePrice: Double
        /// 거래량
        let tradeVolume: Double
        /// 양봉 or 음봉
        var type: CandleType {
            get {
                return self.openingPrice < self.tradePrice ? .red : .blue
            }
        }
        
        /// 양봉 or 음봉
        enum CandleType {
            /// 양봉
            case red
            /// 음봉
            case blue
        }
    }
}

class VerticalCenterCATextLayer : CATextLayer {
    override func draw(in context: CGContext) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/10
        context.saveGState()
        context.translateBy(x: 0, y: yDiff)
        super.draw(in: context)
        context.restoreGState()
    }
}
