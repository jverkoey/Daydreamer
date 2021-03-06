import FigmaKit
import UIKit

extension UIColor {
    public convenience init(figmaColor: Color) {
        self.init(red: figmaColor.r, green: figmaColor.g, blue: figmaColor.b, alpha: figmaColor.a)
    }
}

extension CGPoint {
    public init(figmaTransformTranslation transform: Transform) {
        self.init(x: transform.row1[2], y: transform.row2[2])
    }
}

extension CGRect {
    public init(figmaRect: Rectangle) {
        self.init(x: figmaRect.x, y: figmaRect.y, width: figmaRect.width, height: figmaRect.height)
    }
}

extension CGSize {
    public init(figmaSize: Vector) {
        self.init(width: figmaSize.x, height: figmaSize.y)
    }
}

extension CGAffineTransform {
    public init(figmaTransformNoTranslation figmaTransform: Transform) {
        self.init(a: figmaTransform.row1[0], b: figmaTransform.row2[0],
                  c: figmaTransform.row1[1], d: figmaTransform.row2[1],
                  tx: 0,
                  ty: 0)
    }
    public init(figmaTransform: Transform) {
        self.init(a: figmaTransform.row1[0], b: figmaTransform.row2[0],
                  c: figmaTransform.row1[1], d: figmaTransform.row2[1],
                  tx: figmaTransform.row1[2],
                  ty: figmaTransform.row2[2])
    }
    public init(figmaTransform: Transform, size: Vector) {
        self.init(a: figmaTransform.row1[0], b: figmaTransform.row2[0],
                  c: figmaTransform.row1[1], d: figmaTransform.row2[1],
                  tx: figmaTransform.row1[2] + size.x / 2,
                  ty: figmaTransform.row2[2] + size.y / 2)
    }
}

