import UIKit
import CoreText

struct Circle {
    var center: CGPoint
    var radius: CGFloat
}

struct Polygon {
    var corners: [CGPoint]
}

struct Diagram {
    mutating func add(other: Drawable) {
        elements.append(other)
    }
    var elements: [Drawable] = []
}

enum DrawOperation {
    /// Moves the pen to `position` without drawing anything.
    case move(to: CGPoint)

    /// Draws a line from the pen's current position to `position`, updating
    /// the pen position.
    case addLine(to: CGPoint)

    /// Draws the fragment of the circle centered at `c` having the given
    /// `radius`, that lies between `startAngle` and `endAngle`, measured in
    /// radians.
    case addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat)
}

extension DrawOperation {
    static func addCircle(center: CGPoint, radius: CGFloat) -> DrawOperation {
        return .addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi*2)
    }
}

protocol Drawable {
    var drawOperations: [DrawOperation] { get }
}

extension CGContext {
    func draw(_ drawable: Drawable) {
        for operation in drawable.drawOperations {
            switch operation {
            case .move(to: let point):
                move(to: point)
            case let .addArc(center: center, radius: radius,
                             startAngle: startAngle, endAngle: endAngle):
                addArc(center: center, radius: radius,
                       startAngle: startAngle, endAngle: endAngle,
                       clockwise: true)
            case .addLine(to: let point):
                addLine(to: point)
            }
        }
    }
}

struct TestRenderer {
    func draw(_ drawable: Drawable) {
        drawable.drawOperations.map { print($0) }
    }
}


UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
var context = UIGraphicsGetCurrentContext()!

let drawables: [Drawable] = []

for drawable in drawables {
    context.draw(drawable)
}

extension Circle: Drawable {
    var drawOperations: [DrawOperation] {
        return [.addCircle(center: center, radius: radius)]
    }
}

extension Polygon : Drawable {
    var drawOperations: [DrawOperation] {
        return
            [.move(to: corners.last!)] +
            corners.map { .addLine(to: $0) }
    }
}

extension Diagram: Drawable {
    var drawOperations: [DrawOperation] {
        return elements.flatMap { $0.drawOperations }
    }
}
