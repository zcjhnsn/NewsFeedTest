import UIKit

// MARK: - UIView Extension for Auto Layout
extension UIView {
    
    /// Makes view able to use AutoLayout
    func usesAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Sections of a UIView
    enum ViewSection {
        case top
        case left
        case bottom
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    /// Helper method to make a child view fill its superview
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
		anchor(top: superview?.safeAreaLayoutGuide.topAnchor, leading: superview?.safeAreaLayoutGuide.leadingAnchor, bottom: superview?.safeAreaLayoutGuide.bottomAnchor, trailing: superview?.safeAreaLayoutGuide.trailingAnchor)
    }
    
    /// Helper method to anchor the size of a view to another view's size
    ///
    /// - Parameter view: view whose size will be matched
    func anchorSize(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    
    /// Make a view fill a section of a parent view
    ///
    /// - warning: Must be a child view of another view
    ///
    /// - Parameter section: ViewSection enum
    /// - Parameter padding: any padding (default is zero)
    func fillParentViewSection(_ section: ViewSection, padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        switch section {
        case .top:
            anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.centerYAnchor, trailing: superview?.trailingAnchor, padding: padding)
        case .bottom:
            anchor(top: superview?.centerYAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor, padding: padding)
        case .left:
            anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.centerXAnchor, padding: padding)
        case .right:
            anchor(top: superview?.topAnchor, leading: superview?.centerXAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor, padding: padding)
        case .topLeft:
            anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.centerYAnchor, trailing: superview?.centerXAnchor, padding: padding)
        case .topRight:
            anchor(top: superview?.topAnchor, leading: superview?.centerXAnchor, bottom: superview?.centerYAnchor, trailing: superview?.trailingAnchor, padding: padding)
        case .bottomLeft:
            anchor(top: superview?.centerYAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.centerXAnchor, padding: padding)
        case .bottomRight:
            anchor(top: superview?.centerYAnchor, leading: superview?.centerXAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor, padding: padding)
        }
        
    }
    
    /// Place view in center of another view
    ///
    /// - Parameter view: "container" view
    func center(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func makeSquare(of size: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: size).isActive = true
        widthAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    /// Helper function for setting AutoLayout constraints programmatically
    ///
    /// - Parameters:
    ///   - top: top anchor
    ///   - leading: leading anchor
    ///   - bottom: bottom anchor
    ///   - trailing: trailing anchor
    ///   - padding: padding value (.init())
    ///   - size: size value (.init())
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
}
