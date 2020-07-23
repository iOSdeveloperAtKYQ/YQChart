//
//  ChartView.swift
//  Bezier
//
//  Created by Mac123 on 2020/7/16.
//  Copyright © 2020 K. All rights reserved.
//

import UIKit

enum Type {
    case line //直线图
    case curve //曲线图
}


/// 控制曲线的两个点
struct ControlPoints {
    var point1: CGPoint
    var point2: CGPoint
}

class YQChartView: UIView {
    
    /// 上下左右的间距
    let space: CGFloat = 30

    /// X轴和Y轴分别距离到上箭头和右箭头的值
    let emptySpace: CGFloat = 20

    /// Y轴的最大值
    let YMaxValue: CGFloat = 200
    
    /// Y轴的显示的点数
    let YPoint = 5
    /// Y轴每个点的间距
    var YSpace: CGFloat?
    /// X轴每个点的间距
    var XSpace: CGFloat?
    
    /// Y轴label
    var YLabels: [UILabel]
    /// X轴label
    var XLabels: [UILabel]
    
    var scrollView: UIScrollView
    /// 绘图的view
    var contentView: UIView
    
    
    /// 显示网格，默认显示
    var showGrid: Bool {
        didSet {
            for idx in 0 ..< XGrid.count {
                let layer = XGrid[idx]
                layer.isHidden = !showGrid
            }
            
            for idx in 0 ..< YGrid.count {
                let layer = YGrid[idx]
                layer.isHidden = !showGrid
            }
        }
    }
    /// X轴网格
    var XGrid: [CAShapeLayer]
    /// Y轴网格
    var YGrid: [CAShapeLayer]
    
    
    /// 显示点，默认显示
    var showPoint: Bool {
        didSet {
            for idx in 0 ..< points.count {
                let layer = points[idx]
                layer.isHidden = !showPoint
            }
        }
    }
    /// 点
    var points: [CAShapeLayer]
    
    /// 柱状图layer
    var postLayers: [CAShapeLayer]
    
    
    lazy var valueLabel: UILabel = {
        let label = UILabel.init(frame: .init(x: 0, y: 0, width: 40, height: 20))
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .white
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.gray.cgColor
        label.isHidden = true
        return label
    }()
    
    
    override init(frame: CGRect) {
        scrollView = UIScrollView.init()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        contentView = UIView.init()
        contentView.backgroundColor = UIColor.clear
        scrollView.addSubview(contentView)
        XGrid = []
        YGrid = []
        points = []
        YLabels = []
        XLabels = []
        postLayers = []
        showGrid = true
        showPoint = true
        super.init(frame: frame)
        self.setupValue()
        self.addSubview(scrollView)
        let ges = UITapGestureRecognizer.init(target: self, action: #selector(touch(gesRec:)))
        contentView.addGestureRecognizer(ges)
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            self.setupValue()
        }
    }
    
    func setupValue() {
        scrollView.frame = .init(x: space, y: space, width: frame.width - space * 2 - emptySpace, height: frame.height - space)
        contentView.frame = .init(x: 0, y: emptySpace, width: scrollView.frame.width, height: scrollView.frame.height - emptySpace)
        YSpace = (contentView.frame.height - space) / CGFloat(YPoint)
        XSpace = YSpace
    }
    

    
    override func draw(_ rect: CGRect) {
        self.drawXandYAxis(rect: rect)
        self.setupYLabel()
    }
    
    /// 画X和Y轴
    func drawXandYAxis(rect: CGRect) {
        let line = UIBezierPath.init()
        line.move(to: .init(x: space, y: space))
        line.addLine(to: .init(x: space, y: CGFloat(rect.height) - space))
        line.addLine(to: .init(x: CGFloat(rect.width) - space, y: CGFloat(rect.height) - space))
        line.lineWidth = 2
        UIColor.gray.set()
        line.stroke()
        
        let topArrow = UIBezierPath.init()
        topArrow.move(to: .init(x: space - 5, y: space + 10))
        topArrow.addLine(to: .init(x: space, y: space))
        topArrow.addLine(to: .init(x: space + 5, y: space + 10))
        topArrow.lineWidth = 2
        UIColor.gray.set()
        topArrow.stroke()
        
        let rightArrow = UIBezierPath.init()
        rightArrow.move(to: .init(x: CGFloat(rect.width) - space - 10, y: CGFloat(rect.height) - space - 5))
        rightArrow.addLine(to: .init(x: CGFloat(rect.width) - space, y: CGFloat(rect.height) - space))
        rightArrow.addLine(to: .init(x: CGFloat(rect.width) - space - 10, y: CGFloat(rect.height) - space + 5))
        rightArrow.lineWidth = 2
        UIColor.gray.set()
        rightArrow.stroke()
    }
    
    //设置Y轴文字
    func setupYLabel() {
        if self.YLabels.count == 0 {
            let YAverageValue = ceilf(Float(YMaxValue) / Float(YPoint))
            for number in 0 ... YPoint {
                let centerY = self.frame.height - space - CGFloat(number) * YSpace!
                let label = UILabel.init(frame: .init(x: 0, y: 0, width: space, height: YSpace!))
                let center = CGPoint.init(x: label.center.x, y: centerY)
                label.center = center
                label.textColor = .gray
                label.numberOfLines = 0
                label.textAlignment = .center
                label.font = .systemFont(ofSize: 10)
                label.text = String.init(format: "%.0f", min(Float(number) * YAverageValue, Float(YMaxValue)))
                self.addSubview(label)
                self.YLabels.append(label)
            }
        }
    }
    
    //设置X轴文字
    func setupXLabel(xDescribe: [String]) {
        if self.XLabels.count == 0 || self.XLabels.count < xDescribe.count {
            self.XLabels.removeAll { (label) -> Bool in
                label.removeFromSuperview()
                return true
            }
            
            for (idx, value) in xDescribe.enumerated() {
                let x = XSpace! / 2 + CGFloat(idx) * XSpace!
                let label = UILabel.init(frame: .init(x: x, y: contentView.frame.height - space, width: XSpace!, height: space))
                label.textColor = .gray
                label.numberOfLines = 0
                label.textAlignment = .center
                label.font = .systemFont(ofSize: 10)
                label.text = value
                contentView.addSubview(label)
                self.XLabels.append(label)
            }
        }
    }
    
    /// 画线
    /// - Parameters:
    ///   - values: 值
    ///   - xDescribe: X轴描述
    ///   - lineColor: 线的颜色
    ///   - type: 线的类型，line是直线图 curve是曲线图
    func drawLine(values: [CGFloat], xDescribe: [String], lineColor: UIColor, type: Type) {
        let minCount = min(values.count, xDescribe.count)
        
        let lineLayer = CAShapeLayer.init()
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 1
        lineLayer.add(setAnimation(keyPath: "strokeEnd"), forKey: "strokeEnd")
        contentView.layer.addSublayer(lineLayer)
        
        let contentSize = CGSize.init(width: contentView.frame.width, height: contentView.frame.height - space)
        //画线
        let path = UIBezierPath.init()
        var point = CGPoint.zero
        for idx in 0 ..< minCount {
            let x = XSpace! + CGFloat(idx) * XSpace!
            let y = (1.0 - values[idx] / YMaxValue) * contentSize.height
            point = .init(x: x, y: y)
            
            if idx == 0 {
                path.move(to: point)
            }else {
                if type == .line {
                    //画直线
                    path.addLine(to: point)
                }else {
                    //画曲线
                    let controlPoints = self.setControlPoint(fromPoint: path.currentPoint, toPoint: point)
                    path.addCurve(to: point, controlPoint1: controlPoints.point1, controlPoint2: controlPoints.point2)
                }
            }
            
            //画点
            let pointPath = UIBezierPath.init(arcCenter: point, radius: 2, startAngle: 0, endAngle:             CGFloat.pi * 2, clockwise: true)
            let pointLayer = CAShapeLayer.init()
            pointLayer.path = pointPath.cgPath
            pointLayer.fillColor = UIColor.white.cgColor
            pointLayer.strokeColor = lineColor.cgColor
            pointLayer.lineWidth = 1
            pointLayer.isHidden = !showPoint
            contentView.layer.addSublayer(pointLayer)
            points.append(pointLayer)
            pointLayer.add(setAnimation(keyPath: "strokeEnd"), forKey: "strokeEnd")
            
        }
        lineLayer.path = path.cgPath

        //根据最后的点去计算contentView的宽度
        if point.x + XSpace! > contentView.frame.width {
            var frame: CGRect = contentView.frame
            frame.size.width = point.x + XSpace!
            contentView.frame = frame
            scrollView.contentSize = .init(width: contentView.frame.width, height: 0)
        }
        
        //设置网格
        self.setupGrid(minCount: minCount)
        //设置Y轴文字
        self.setupXLabel(xDescribe: xDescribe)
    }
    
    /// 柱状图
    /// - Parameters:
    ///   - values: 值
    ///   - xDescribe: X轴描述
    ///   - colors: 颜色，可以是渐变
    ///   - locations: 颜色渐变位置
    func drawPost(values: [CGFloat], xDescribe: [String], colors: [UIColor], locations: [NSNumber]) {
        let minCount = min(values.count, xDescribe.count)
        let contentSize = CGSize.init(width: contentView.frame.width, height: contentView.frame.height - space)
        var point = CGPoint.zero
        for idx in 0 ..< minCount {
            let x = XSpace! + CGFloat(idx) * XSpace!
            let y = (1.0 - values[idx] / YMaxValue) * contentSize.height
            point = .init(x: x, y: y)
            //柱状图
            self.setPost(point: point, colors: colors, locations: locations)
        }

        //根据最后的点去计算contentView的宽度
        if point.x + XSpace! > contentView.frame.width {
            var frame: CGRect = contentView.frame
            frame.size.width = point.x + XSpace!
            contentView.frame = frame
            scrollView.contentSize = .init(width: contentView.frame.width, height: 0)
        }
        
        //设置网格
        self.setupGrid(minCount: minCount)
        //设置Y轴文字
        self.setupXLabel(xDescribe: xDescribe)
    }
    
    //设置网格
    func setupGrid(minCount: Int) {
        if XGrid.count == 0 {
            //X轴虚线
            self.setupXGrid()
        }
        
        if YGrid.count == 0 {
            //Y轴虚线
            self.setupYGrid(minCount: minCount)
        }else if YGrid.count < minCount {
            //数据有增多，需要重新绘画网格
            XGrid.removeAll { (layer) -> Bool in
                layer.removeFromSuperlayer()
                return true
            }
            YGrid.removeAll { (layer) -> Bool in
                layer.removeFromSuperlayer()
                return true
            }
            self.setupXGrid()
            self.setupYGrid(minCount: minCount)
        }
        
    }
    
    //X轴虚线
    func setupXGrid() {
        for number in 0 ..< YPoint {
            let XgridPath = UIBezierPath.init()
            let y = CGFloat(number) * YSpace!
            XgridPath.move(to: .init(x: 0, y: y))
            XgridPath.addLine(to: .init(x: contentView.frame.width, y: y))
            
            let XgridLayer = CAShapeLayer.init()
            XgridLayer.path = XgridPath.cgPath
            XgridLayer.fillColor = UIColor.clear.cgColor
            XgridLayer.strokeColor = UIColor.gray.cgColor
            XgridLayer.lineWidth = 0.5
            XgridLayer.lineDashPhase = 2
            XgridLayer.lineDashPattern = [3,1]
            contentView.layer.insertSublayer(XgridLayer, at: 0)
            XgridLayer.isHidden = !showGrid
            XGrid.append(XgridLayer)
        }
    }
    
    //Y轴虚线
    func setupYGrid(minCount: Int) {
        for number in 0 ..< minCount {
            let YgridPath = UIBezierPath.init()
            let x = CGFloat(number) * XSpace! + XSpace!
            YgridPath.move(to: .init(x: x, y: 0))
            YgridPath.addLine(to: .init(x: x, y: contentView.frame.height - space))
            
            let YgridLayer = CAShapeLayer.init()
            YgridLayer.path = YgridPath.cgPath
            YgridLayer.fillColor = UIColor.clear.cgColor
            YgridLayer.strokeColor = UIColor.gray.cgColor
            YgridLayer.lineWidth = 0.5
            YgridLayer.lineDashPhase = 2
            YgridLayer.lineDashPattern = [3,1]
            contentView.layer.insertSublayer(YgridLayer, at: 0)
            YgridLayer.isHidden = !showGrid
            YGrid.append(YgridLayer)
        }
    }
    
    //设置控制贝塞尔曲线的两个点
    func setControlPoint(fromPoint: CGPoint, toPoint: CGPoint) -> ControlPoints {
        let x = fromPoint.x + (toPoint.x - fromPoint.x) / 2.0
        var point1 = CGPoint.init(x: x, y: 0)
        var point2 = CGPoint.init(x: x, y: 0)
        point1.y = fromPoint.y
        point2.y = toPoint.y
        return ControlPoints.init(point1: point1, point2: point2)
    }
    
    //设置柱状图
    func setPost(point: CGPoint, colors: [UIColor], locations: [NSNumber]) {
        var cgColors = Array<CGColor>.init()
        for idx in 0 ..< colors.count {
            cgColors.append(colors[idx].cgColor)
        }
        
        if cgColors.count == 1 {
            cgColors.append(cgColors.first!)
        }
        
        let margin = XSpace! / 3.0
        let h = contentView.frame.height - point.y - space - 1
        
        let path = UIBezierPath.init()
        path.move(to: .init(x: point.x - margin, y: point.y + h))
        path.addLine(to: .init(x: point.x - margin, y: point.y))
        path.addLine(to: .init(x: point.x + margin, y: point.y))
        path.addLine(to: .init(x: point.x + margin, y: point.y + h))
        
        let postLayer = CAShapeLayer.init()
        postLayer.path = path.cgPath
        postLayer.fillColor = UIColor.clear.cgColor
        postLayer.strokeColor = UIColor.clear.cgColor
        postLayer.lineWidth = 1
        contentView.layer.addSublayer(postLayer)
        postLayers.append(postLayer)
        
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = .init(x: point.x - margin, y: point.y, width: margin * 2, height: h)
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.colors = cgColors
        contentView.layer.addSublayer(gradientLayer)
        
        //设置动画
        let animation = CABasicAnimation.init(keyPath: "locations")
        animation.fromValue = [1,0.5,0]
        animation.toValue = locations
        animation.duration = 1.5
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "locations")
    }
    
    //设置动画
    func setAnimation(keyPath: String) -> CAAnimation {
        let animation = CABasicAnimation.init(keyPath: keyPath)
        animation.duration = 2
        animation.fromValue = 0
        animation.toValue = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        return animation
    }
 
    /// 点击事件
    @objc func touch(gesRec: UITapGestureRecognizer) {
        let point = gesRec.location(in: contentView)
        let w = 20.0
        for idx in 0 ..< points.count {
            let layer = points[idx]
            let currentPoint = layer.path!.currentPoint
            let frame = CGRect.init(x: Double(currentPoint.x) - w / 2.0, y: Double(currentPoint.y) - w / 2, width: w, height: w)
            if frame.contains(point) {
                let center = CGPoint.init(x: currentPoint.x - (layer.path!.boundingBox.width) / 2, y: currentPoint.y - valueLabel.frame.height / 1.5)
                valueLabel.center = center
                valueLabel.isHidden = false
                let value = (1 - currentPoint.y / (contentView.frame.height - space)) * YMaxValue
                valueLabel.text = String.init(format: "%0.1f", value)
                return
            }
            
        }
        
        for idx in 0 ..< postLayers.count {
            let layer = postLayers[idx]
            let frame = layer.path!.boundingBox
            if frame.contains(point) {
                let center = CGPoint.init(x: frame.origin.x + frame.width / 2, y: frame.origin.y - valueLabel.frame.height / 1.5)
                valueLabel.center = center
                valueLabel.isHidden = false
                let value = (1 - frame.origin.y / (contentView.frame.height - space)) * YMaxValue
                valueLabel.text = String.init(format: "%0.1f", value)
                return
            }
        }
        
    }
    
}
