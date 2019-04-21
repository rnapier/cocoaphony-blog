import CoreGraphics

protocol Shape {
    var center: CGPoint { get set }
}

protocol Circle: Shape {
    var radius: CGPoint { get set }
}

struct CircleImpl: Circle {
    var center: CGPoint
    var radius: CGPoint
}


//protocol Rectangle: Shape {
//    var rect: CGRect { get set }
//}
//
//struct RectangleImpl: Rectangle {
//    var center: CGPoint { return CGPoint(x: rect.midX, y: rect.midY) }
//    var rect: CGRect
//}
