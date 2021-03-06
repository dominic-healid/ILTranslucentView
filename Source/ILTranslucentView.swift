//
//  ILTranslucentView.swift
//  ILTranslucentView
//
//  Created by Tomasz Szulc on 25/07/14.
//  http://github.com/tomkowz
//

/// Rewritten from https://github.com/ivoleko/ILTranslucentView

import UIKit

class ILTranslucentView: UIView {

    private var _translucent = true
    var translucent : Bool {
        set {
            _translucent = newValue
            if self.toolbarBG == nil {
                return
            }
            
            self.toolbarBG!.isTranslucent = newValue
            
            if newValue {
                self.toolbarBG!.isHidden = false
                self.toolbarBG!.barTintColor = self.ilColorBG
                self.backgroundColor = UIColor.clear
            } else {
                self.toolbarBG!.isHidden = true
                self.backgroundColor = self.ilColorBG
            }
        }
        get {
            return _translucent
        }
    }
    
    private var _translucentAlpha : CGFloat = 1.0
    public var translucentAlpha : CGFloat {
        set {
            if newValue > 1 {
                _translucentAlpha = 1
            } else if (newValue < 0) {
                _translucentAlpha = 0
            } else {
                _translucentAlpha = newValue
            }
            
            if self.toolbarBG != nil {
                self.toolbarBG!.alpha = _translucentAlpha
            }
        }
        get {
            return _translucentAlpha
        }
    }
    
    var translucentStyle : UIBarStyle {
        set {
            if self.toolbarBG != nil {
                self.toolbarBG!.barStyle = newValue
            }
        }
        get {
            if self.toolbarBG != nil {
                return self.toolbarBG!.barStyle
            } else {
                return UIBarStyle.default
            }
        }
    }
    
    private var _translucentTintColor = UIColor.clear
    var translucentTintColor : UIColor {
        set {
            _translucentTintColor = newValue
            if (self.isItClearColor(color: newValue)) {
                self.toolbarBG!.barTintColor = self.ilDefaultColorBG
            } else {
                self.toolbarBG!.barTintColor = self.translucentTintColor
            }
        }
        get {
            return _translucentTintColor
        }
    }
    
    private var ilColorBG : UIColor?
    private var ilDefaultColorBG : UIColor?
    
    private var toolbarBG : UIToolbar?
    private var nonExistentSubview : UIView?
    private var toolbarContainerClipView : UIView?
    private var overlayBackgroundView : UIView?
    private var initComplete = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createUI()
    }
}

extension ILTranslucentView {
    private func createUI() {
        self.ilColorBG = self.backgroundColor
        
        self.translucent = true
        self.translucentAlpha = 1

        let _nonExistentSubview = UIView(frame: self.bounds)
        _nonExistentSubview.backgroundColor = UIColor.clear
        _nonExistentSubview.clipsToBounds = true
        _nonExistentSubview.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        self.nonExistentSubview = _nonExistentSubview
        self.insertSubview(self.nonExistentSubview!, at: 0)

        let _toolbarContainerClipView = UIView(frame: self.bounds)
        _toolbarContainerClipView.backgroundColor = UIColor.clear
        _toolbarContainerClipView.clipsToBounds = true
        _toolbarContainerClipView.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        self.toolbarContainerClipView = _toolbarContainerClipView
        self.nonExistentSubview!.addSubview(self.toolbarContainerClipView!)

        var rect = self.bounds
        rect.origin.y -= 1
        rect.size.height += 1
        
        let _toolbarBG = UIToolbar(frame: rect)
        _toolbarBG.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.toolbarBG = _toolbarBG
        
        self.toolbarContainerClipView!.addSubview(self.toolbarBG!)
        self.ilDefaultColorBG = self.toolbarBG!.barTintColor
        
        var _overlayBackgroundView = UIView(frame: self.bounds)
        _overlayBackgroundView.backgroundColor = self.backgroundColor
        _overlayBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.overlayBackgroundView = _overlayBackgroundView
        self.toolbarContainerClipView!.addSubview(self.overlayBackgroundView!)
        
        self.backgroundColor = UIColor.clear
        self.initComplete = true
    }
    
    private func isItClearColor(color: UIColor) -> Bool {
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return red == 0.0 && green == 0.0 && blue == 0.0 && alpha == 0.0
    }
    
    @objc override var frame : CGRect {
        set {
            if self.toolbarContainerClipView == nil {
                super.frame = newValue
                return
            }
            
            var rect = newValue
            rect.origin = CGPoint.zero
            
            let width = self.toolbarContainerClipView!.frame.width
            if width > rect.width {
                rect.size.width = width
            }
            
            let height = self.toolbarContainerClipView!.frame.height
            if height > rect.height {
                rect.size.height = height
            }
            
            self.toolbarContainerClipView!.frame = rect
            
            super.frame = newValue
            self.nonExistentSubview!.frame = self.bounds
        }
        get {
            return super.frame
        }
    }
    
    @objc override var bounds : CGRect {
        set {
            var rect = newValue
            rect.origin = CGPoint.zero
            
            let width = self.toolbarContainerClipView!.bounds.width
            if width > rect.width {
                rect.size.width = width
            }
            
            let height = self.toolbarContainerClipView!.bounds.height
            if height > rect.height {
                rect.size.height = height
            }
            
            self.toolbarContainerClipView!.bounds = rect
            super.bounds = newValue
            self.nonExistentSubview!.frame = self.bounds
        }
        get {
            return super.bounds
        }
    }
    
    @objc override var backgroundColor : UIColor! {
        set {
            if self.initComplete {
                self.ilColorBG = newValue
                if (self.translucent) {
                    self.overlayBackgroundView!.backgroundColor = newValue
                    super.backgroundColor = UIColor.clear
                }
            } else {
                super.backgroundColor = self.ilColorBG
            }
        }
        get {
            return super.backgroundColor
        }
    }
    
    @objc override var subviews: [UIView] {
        if self.initComplete {
            var array = super.subviews as Array<UIView>
            
            var index = 0
            for view in array {
                if view == self.nonExistentSubview {
                    break
                }
                index += 1
            }
            
            if index < array.count {
                array.remove(at: index)
            }
            
            return array
        } else {
            return super.subviews
        }
    }
    
    
    override func sendSubviewToBack(_ view: UIView)  {
        if self.initComplete {
            self.insertSubview(view, aboveSubview: self.toolbarContainerClipView!)
        } else {
            super.sendSubviewToBack(view)
        }
    }
    
    override func insertSubview(_ view: UIView, at index: Int) {
        if self.initComplete {
            super.insertSubview(view, at: index + 1)
        } else {
            super.insertSubview(view, at: index)
        }
    }
    
    override func exchangeSubview(at index1: Int, withSubviewAt index2: Int)  {
        if self.initComplete {
            super.exchangeSubview(at: (index1 + 1), withSubviewAt: (index2 + 1))
        } else {
            super.exchangeSubview(at: index1, withSubviewAt: index2)
        }
    }
}
