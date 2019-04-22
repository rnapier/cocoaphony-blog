import CoreGraphics

class Shape {
    var center: CGPoint
    init(center: CGPoint) {
        self.center = center
    }
}

class Circle: Shape {
    var radius: CGFloat
    init(center: CGPoint, radius: CGFloat) {
        self.radius = radius
        super.init(center: center)
    }
}

//class Polygon: Shape {
//    var corners: [CGPoint]
//    init(corners: [CGPoint]) {
//        self.corners = corners
//        super.init(center: ???)
//    }
//}
