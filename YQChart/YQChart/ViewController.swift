//
//  ViewController.swift
//  Bezier
//
//  Created by Mac123 on 2020/7/16.
//  Copyright © 2020 K. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var chartView: YQChartView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let v = YQChartView.init(frame: .init(x: 0, y: 200, width: 320, height: 300))
        let chartView = YQChartView.init()
        chartView.frame = .init(x: 0, y: 100, width: self.view.frame.width, height: 300)
        chartView.backgroundColor = .white
        self.view.addSubview(chartView)
        self.chartView = chartView
        
        self.chartView?.drawLine(values: [188.8,165,177.7,155,155,190], xDescribe: ["1","2","3","4","5","6"], lineColor: .blue, type: .line)
        
        self.chartView?.drawLine(values: [111.1,148,100,135.5,120,105,132,121], xDescribe: ["1","2","3","4","5","6","7","8"], lineColor: .orange, type: .curve)
        
        self.chartView?.drawPost(values: [23,46.5,67,23.7,98,75,88,66,4,18], xDescribe: ["1","2","3","4","5","6","7","8","9","10"], colors: [UIColor.red, UIColor.yellow], locations: [0, 0.5, 1])
    }

    @IBAction func showGrid(_ sender: UISwitch) {
        self.chartView?.showGrid = sender.isOn
    }
    
    @IBAction func showPoint(_ sender: UISwitch) {
        self.chartView?.showPoint = sender.isOn
    }
    
}

