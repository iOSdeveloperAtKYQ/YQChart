# YQChart
一个简单易用的绘图，包含折线图、曲线图、柱状图。支持动画、颜色渐变、滑动。
# 效果图
![](https://github.com/iOSdeveloperAtKYQ/YQChart/blob/master/效果图/效果图.gif)
# 使用方法
添加一条折线图
```swift
self.chartView?.drawLine(values: [188.8,165,177.7,155,155,190], xDescribe: ["1","2","3","4","5","6"], lineColor: .blue, type: .line)
```
添加一条曲线图
```swift
self.chartView?.drawLine(values: [111.1,148,100,135.5,120,105,132,121], xDescribe: ["1","2","3","4","5","6","7","8"], lineColor: .orange, type: .curve)
```
添加柱状图
```swift
self.chartView?.drawPost(values: [23,46.5,67,23.7,98,75,88,66,4,18], xDescribe: ["1","2","3","4","5","6","7","8","9","10"], colors: [UIColor.red, UIColor.yellow], locations: [0, 0.5, 1])
```
