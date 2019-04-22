import UIKit
import CoreText

struct Circle {
    var center: CGPoint
    var radius: CGFloat
}
struct Polygon {
    var corners: [CGPoint]
}

protocol Drawable {
    func draw(in context: CGContext)
}

struct Diagram : Drawable {
    func draw(in context: CGContext) {
        for f in elements {
            f.draw(in: context)
        }
    }
    mutating func add(_ other: Drawable) {
        elements.append(other)
    }
    var elements: [Drawable] = []
}

UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
let context = UIGraphicsGetCurrentContext()!

let drawables: [Drawable] = []

for drawable in drawables {
    drawable.draw(in: context)
}

extension Circle: Drawable {
    func draw(in context: CGContext) {
        context.addArc(center: center, radius: radius,
                       startAngle: 0, endAngle: .pi*2,
                       clockwise: true)
    }
}

struct Text {
    var position: CGPoint
    var attributedString: NSAttributedString
}

extension Text: Drawable {
    func draw(in context: CGContext) {
        
        // Configure the context
        context.textMatrix = .identity
        context.textPosition = position

        // Draw the text
        let line = CTLineCreateWithAttributedString(attributedString)
        CTLineDraw(line, context)
    }
}
