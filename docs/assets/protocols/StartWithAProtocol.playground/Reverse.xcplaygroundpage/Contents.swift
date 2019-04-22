import UIKit
import CoreText

struct Circle {
    var center: CGPoint
    var radius: CGFloat
}
struct Polygon {
    var corners: [CGPoint]
}

protocol Canvas {
    func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
    func addText(_ attributedString: NSAttributedString, at location: CGPoint)
}

extension Canvas {
    func addCircle(center: CGPoint, radius: CGFloat) {
        addArc(center: center, radius: radius,
               startAngle: 0, endAngle: .pi*2,
               clockwise: true)
    }
}

extension CGContext: Canvas {
    func addText(_ attributedString: NSAttributedString, at location: CGPoint) {
        // Save the current context parameters so we can restore them
        let oldTextPosition = textPosition
        let oldTextMatrix = textMatrix

        // Configure the context
        textMatrix = .identity
        textPosition = location

        // Draw the line
        let line = CTLineCreateWithAttributedString(attributedString)
        CTLineDraw(line, self)

        // Restore the context
        textPosition = oldTextPosition
        textMatrix = oldTextMatrix
    }
}

protocol Drawable {
    func draw(onto canvas: Canvas)
}

UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
var context = UIGraphicsGetCurrentContext()!

let drawables: [Drawable] = []

for drawable in drawables {
    drawable.draw(onto: context)
}

extension Circle: Drawable {
    func draw(onto canvas: Canvas) {
        canvas.addCircle(center: center, radius: radius)
    }
}

struct Text {
    var attributedString: NSAttributedString
    var location: CGPoint
}

extension Text: Drawable {
    func draw(onto canvas: Canvas) {
        canvas.addText(attributedString, at: location )
    }
}

