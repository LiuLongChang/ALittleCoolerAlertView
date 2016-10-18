//
//  CoolerAlertViewTool.swift
//  ALittleCoolerAlertView
//
//  Created by langyue on 16/10/18.
//  Copyright © 2016年 langyue. All rights reserved.
//

import Foundation
import UIKit


/*
 *
 *
 *
 */
let Alert_View_Current_Height = UIScreen.main.bounds.size.height
let Alert_View_Current_Width = UIScreen.main.bounds.size.width

let Alert_View_Debug_Layout : CGFloat = 0

let Alert_View_Message_Min_Line_Count : CGFloat = 3
let Alert_View_Message_Max_Line_Count : CGFloat = 20
let Alert_View_Gap : CGFloat = 10
let Alert_View_Cancel_Button_Padding_Top : CGFloat = 5
let Alert_View_Content_Padding_Left : CGFloat = 10
let Alert_View_Content_Padding_Top : CGFloat = 12
let Alert_View_Content_Padding_Bottom : CGFloat = 0
let Alert_View_Button_Padding_Left : CGFloat = 0
let Alert_View_Button_Height : CGFloat = 44
let Alert_View_Container_Width : CGFloat = Alert_View_Current_Width - 20
let ALert_View_Container_Height : CGFloat = Alert_View_Current_Height - 100
/*
 * 当前固件版本
 *
 */
let Current_System_Version = Float(UIDevice.current.systemVersion)
let iOS6 : Bool = (Current_System_Version! >= Float(6.0))
let iOS7 = (Current_System_Version! >= Float(7.0))
let iOS71 = (Current_System_Version! >= Float(7.1))
let iOS8 = (Current_System_Version! >= Float(8.0))
let iOS9 = (Current_System_Version! >= Float(9.0))
let iOS10 = (Current_System_Version! >= Float(10.0))


let UIWindowLevelCustomAlert = 1999.0
let UIWindowLevelCustomAlertBg = 1998.0


var _custom_alert_queue : NSMutableArray! = nil
var _custom_alert_current_view : AlertView! = nil
var _custom_alert_background_window : CustomAlertBgWindow! = nil



enum CustomAlertView_BtnType : NSInteger {
    case Default = 0,Destructive,Cancel
}
enum CustomALertView_BgStyle : NSInteger{
    case Gradient = 0,Solid
}
enum CustomAlertView_TransitionStyle:NSInteger{
    case SlideFromBottom,SlideFromTop,Bounce
}
/*
 *
 *
 *
 */
typealias AlertViewHandler = (_ alertView:AlertView)->Void


//
//
class Alert: NSObject {

    override init() {
        super.init()
    }
    
}


class CustomAlertItem: NSObject {

    var title : NSString! = nil
    var type : CustomAlertView_BtnType! = nil
    var action : AlertViewHandler! = nil

    override init() {
        super.init()
    }

}

/*
 *
 *
 *
 */
class CustomAlertVC: UIViewController {


    var alertView: AlertView! = nil

    override func loadView() {
        view = self.alertView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alertView.setup()
    }

}
//
//
//
//





class AlertView: UIView,CAAnimationDelegate {

    var title : String! = ""
    var message : String! = ""
    var messageIsAlignLeft : Bool! = false
    var messageNeedLineSpace : Bool! = false
    var customView : UIView! = nil
    var transitionStyle : CustomAlertView_TransitionStyle! = nil


    var viewBgColor : UIColor! = nil
    var titleColor : UIColor! = nil
    var messageColor : UIColor! = nil
    var titleFOnt : UIFont! = nil
    var messageFont : UIFont! = nil
    var buttonFont : UIFont! = nil
    var cornerRadius : CGFloat! = nil
    var shadowRadius : CGFloat! = nil


    var items : NSMutableArray! = []
    var alertWindow : UIWindow! = nil
    var visible : Bool! = false

    var titleLabel:UILabel! = nil
    var messageLabel:UILabel! = nil
    var containerView : UIView! = nil
    var buttons:NSMutableArray! = []
    var lineContentLabel: UILabel! = nil
    var lineBtnLabel:UILabel! = nil
    var layoutDirty : Bool! = false


    convenience init() {
        self.init(title:"",message:"")
    }



    convenience init(title:String,message:String){
        self.init()
        self.title = title
        if (title as NSString).length == 0 {
            self.title = ""
        }

        self.message = message
        if (message as NSString).length == 0 {
            self.message = ""
        }

        transitionStyle = .Bounce
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(customView:UIView) {
        self.init()
        self.customView = customView
        self.transitionStyle = .Bounce
    }

    convenience init(customView:UIView,style:CustomAlertView_TransitionStyle) {
        self.init(customView:customView)
        self.transitionStyle = style
    }




    class func sharedQueue()->NSMutableArray{
        if _custom_alert_queue == nil {
            _custom_alert_queue = NSMutableArray()
        }
        return _custom_alert_queue
    }
    class func currentAlertView()->AlertView{
        return _custom_alert_current_view
    }
    class func setCurrentAlertView(alertView:AlertView?){
        if alertView == nil {
            _custom_alert_current_view = nil
        }
        _custom_alert_current_view = alertView
    }




    class func showBg(){
        if _custom_alert_background_window == nil {
            _custom_alert_background_window = CustomAlertBgWindow.init(frame: UIScreen.main.bounds)
            _custom_alert_background_window.makeKeyAndVisible()
            _custom_alert_background_window.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                _custom_alert_background_window.alpha = 1
            })
        }
    }


    class func hideBgAnimated(animated:Bool){


        if animated == false {
            _custom_alert_background_window.removeFromSuperview()
            _custom_alert_background_window = nil
            return
        }

        UIView.animate(withDuration: 0.3, animations: {

            _custom_alert_background_window.alpha = 0


        }) { (finished:Bool) in

            _custom_alert_background_window.removeFromSuperview()
            _custom_alert_background_window = nil

        }

    }

    /*
     *  Setters
     *
     */
    func setTitle(title:String){
        self.title = title
        self.invaliadateLayout()
    }

    func setMessage(message:String){
        self.message = message
        self.invaliadateLayout()
    }


    func addBtn(title:String,type:CustomAlertView_BtnType,handler:@escaping AlertViewHandler){
        let item : CustomAlertItem = CustomAlertItem()
        item.title = title as NSString
        item.type = type
        item.action = handler
        self.items.add(item)
    }

    func show(){

        if AlertView.sharedQueue().contains(self) {
            AlertView.sharedQueue().add(self)
        }

        if self.visible == true {
            return
        }

        if AlertView.currentAlertView().visible == true {
            let alert = AlertView.currentAlertView()
            alert.dismissAnimate(animated: true, cleanUp: false)
        }

        self.visible = true
        AlertView.setCurrentAlertView(alertView: self)

        AlertView.showBg()


        let viewController = CustomAlertVC.init(nibName: nil, bundle: nil)
        viewController.alertView = self

        if self.alertWindow == nil {
            let window = UIWindow.init(frame: UIScreen.main.bounds)
            window.autoresizingMask = [UIViewAutoresizing.flexibleWidth,.flexibleHeight]
            window.isOpaque = false
            window.windowLevel = UIWindowLevel(UIWindowLevelCustomAlert)
            window.rootViewController = viewController
            self.alertWindow = window
        }
        self.alertWindow.makeKeyAndVisible()

        self.validateLayout()


//        self.transitionInCompletion { () in
//            let index = AlertView.sharedQueue().index(of: self)
//            if index < (AlertView.sharedQueue().count - 1) {
//                self.dismissAnimate(animated: true, cleanUp: false)
//            }
//        }

    }


    func dismissAnimated(animated:Bool){
        self.dismissAnimate(animated: animated, cleanUp: true)
    }


    func dismissAnimate(animated:Bool,cleanUp:Bool){

        let isVisible = self.visible
        let dismissComplete : ((Void)->Void) = { () in


            self.visible = false
            self.teardown()
            AlertView.setCurrentAlertView(alertView: nil)
            var nextAlertView : AlertView! = nil
            let index = AlertView.sharedQueue().index(of: self)
            if (index != NSNotFound) && (index < AlertView.sharedQueue().count - 1)  {
                nextAlertView = AlertView.sharedQueue()[index + 1] as? AlertView
            }

            if (cleanUp == true) {
                AlertView.sharedQueue().remove(self)
            }

            if (isVisible == false) {
                return
            }

            if (nextAlertView != nil) {
                nextAlertView.show()
            }else{
                if AlertView.sharedQueue().count > 0 {
                    let alert = AlertView.sharedQueue().lastObject as? AlertView
                    if (alert != nil) {
                        alert?.show()
                    }
                }
            }
        }



        if (animated == true) && (isVisible == true) {

            //self.transitionOutCompletion(completion: dismissComplete)
            if AlertView.sharedQueue().count == 1 {
                AlertView.hideBgAnimated(animated: true)
            }

        }else{

            dismissComplete()
            if AlertView.sharedQueue().count == 0 {
                AlertView.hideBgAnimated(animated: false)
            }

        }

    }





    func transitionInCompletion(completion:@escaping ((Void)->Void)){


        switch self.transitionStyle.rawValue {
        case CustomAlertView_TransitionStyle.SlideFromBottom.rawValue:

            var rect = self.containerView.frame;
            let originRect = rect
            rect.origin.y = bounds.size.height
            self.containerView.frame = rect
            UIView.animate(withDuration: 0.3, animations: {

                self.containerView.frame = originRect

                }, completion: { (finish) in

                        completion()

            })


            break

        case CustomAlertView_TransitionStyle.SlideFromBottom.rawValue:


            var rect = self.containerView.frame
            let originalRect = rect
            rect.origin.y = -rect.size.height
            self.containerView.frame = rect
            UIView.animate(withDuration: 0.3, animations: {

                self.containerView.frame = originalRect

                }, completion: { (finish) in

                    completion()
                    
            })
            
            break

        case CustomAlertView_TransitionStyle.SlideFromBottom.rawValue:

            let animation = CAKeyframeAnimation.init(keyPath: "transform.scale")
            animation.values = [0.01,1.2,0.9,1]
            animation.keyTimes = [0,0.4,0.6,1]
            animation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)]
            animation.duration = 0.5
            animation.delegate = self
            animation.setValue(completion as Any, forKey: "handler")
            self.containerView.layer.add(animation, forKey: "bouce")
            break

            //15   22  23  25 26 27  21     15  21  23  25  22  17
            
        default:

            break
        }

    }




//    func transitionOutCompletion(completion:@escaping (Void)->Void){
//
//
//        switch self.transitionStyle.rawValue {
//        case CustomAlertView_TransitionStyle.SlideFromBottom.rawValue:
//
//            var rect = self.containerView.frame
//            rect.origin.y = self.bounds.size.height
//            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn,.curveEaseOut,.curveEaseInOut], animations: {
//
//                self.containerView.frame = rect
//
//                }, completion: { (finish) in
//
//                    completion()
//
//            })
//
//            break
//
//        case CustomAlertView_TransitionStyle.SlideFromTop.rawValue:
//
//            var rect = self.containerView.frame
//            rect.origin.y = -rect.size.height
//            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
//
//                self.containerView.frame = rect
//
//                }, completion: { (finish) in
//
//                    completion()
//
//            })
//
//            break
//
//        case CustomAlertView_TransitionStyle.Bounce.rawValue:
//
//            let animation = CAKeyframeAnimation.init(keyPath: "transform.scale")
//            animation.values = [1,1.2,0.01]
//            animation.keyTimes = [0,0.4,1]
//            animation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)]
//            animation.duration = 0.35
//            animation.delegate = self
//            animation.setValue(completion, forKey: "handler")
//            self.containerView.layer.add(animation, forKey: "bounce")
//            self.containerView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
//
//            break
//
//        default: break
//
//
//        }
//
//    }


    func resetTransition(){
        self.containerView.layer.removeAllAnimations()
    }

    /*
     *  Layout
     *
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        self.validateLayout()
    }

    func invaliadateLayout(){
        self.layoutDirty = true
        self.setNeedsLayout()
    }

    func validateLayout(){


        if (self.layoutDirty == false) {
            return
        }
        self.layoutDirty = false



        let height = self.preferredHeight()
        let left = bounds.size.width - Alert_View_Container_Width * 0.5
        let top = (bounds.size.height - height) * 0.5
        self.containerView.transform = CGAffineTransform.identity
        self.containerView.frame = CGRect.init(x: left, y: top, width: Alert_View_Container_Width, height: height)
        self.containerView.layer.cornerRadius = 6.0
        self.containerView.layer.shadowPath = UIBezierPath.init(roundedRect: self.containerView.bounds, cornerRadius: self.containerView.layer.cornerRadius).cgPath



        var y = Alert_View_Content_Padding_Top
        if self.titleLabel != nil {
            self.titleLabel.text = self.title
            let height = self.heightForTitleLabel()
            self.titleLabel.frame = CGRect.init(x: Alert_View_Content_Padding_Left, y: y, width: self.containerView.bounds.size.width - Alert_View_Content_Padding_Left * 2, height: height)
            y += height
        }



        if self.messageLabel != nil {
            if y > Alert_View_Content_Padding_Top {
                y += Alert_View_Gap
            }
            self.messageLabel.text = self.message
            if self.messageNeedLineSpace == true {
                let att : NSAttributedString = self.getAttrLineSpaceForContent(content: self.message as NSString)
                self.messageLabel.attributedText = att
            }
            let height = self.heightForMessageLabel()
            self.messageLabel.frame = CGRect.init(x: Alert_View_Content_Padding_Left, y: y, width: containerView.bounds.size.width - Alert_View_Content_Padding_Left * CGFloat(2), height: height)
            y += height
        }



        if self.customView != nil {
            var rect = self.customView.frame
            if rect.size.width > self.containerView.frame.size.width {
                rect.size.width = self.containerView.frame.size.width
            }
            if rect.size.height > ALert_View_Container_Height {
                rect.size.height = ALert_View_Container_Height
            }
            self.customView.frame = rect
            y += CGFloat(rect.size.height)
        }




        if self.items.count > 0 {

            self.lineContentLabel.backgroundColor = UIColor.lightGray
            let lineHeight = 1.0
            self.lineContentLabel.frame = CGRect.init(x: CGFloat(0), y: CGFloat(y + Alert_View_Gap), width: self.containerView.bounds.size.width, height: CGFloat(lineHeight))
            y += 1
            if y > Alert_View_Content_Padding_Top {
                y += Alert_View_Gap
            }


            if self.items.count == 2 {

                let width = (self.containerView.bounds.size.width - CGFloat(Alert_View_Button_Padding_Left) * CGFloat(2)) * CGFloat(0.5)
                var btn = self.buttons[0] as! UIButton
                btn.frame = CGRect.init(x: CGFloat(Alert_View_Button_Padding_Left), y: width, width: width, height: CGFloat(Alert_View_Button_Height))
                btn = self.buttons[1] as! UIButton
                btn.frame = CGRect.init(x: CGFloat(Alert_View_Button_Padding_Left) + width, y: CGFloat(y), width: CGFloat(lineHeight), height: CGFloat(Alert_View_Button_Height))

                self.lineBtnLabel.backgroundColor = UIColor.lightGray
                let lineHeight = 1.0
                self.lineBtnLabel.frame = CGRect.init(x: CGFloat(Alert_View_Button_Padding_Left) + CGFloat(width), y: CGFloat(y), width: CGFloat(lineHeight), height: CGFloat(Alert_View_Button_Height))

            }else{


                for i in 0..<self.buttons.count {

                    let btn = self.buttons[i] as! UIButton
                    btn.frame = CGRect.init(x: Alert_View_Button_Padding_Left, y: y, width: self.containerView.bounds.size.width - Alert_View_Button_Padding_Left * 2, height: Alert_View_Button_Height)
                    if self.buttons.count > 1 {

                        if (i == self.buttons.count - 1) && ((self.items[i] as! CustomAlertItem).type == CustomAlertView_BtnType.Cancel) {
                            var rect = btn.frame
                            rect.origin.y += Alert_View_Cancel_Button_Padding_Top
                            btn.frame = rect
                        }
                        y += Alert_View_Button_Height + Alert_View_Gap
                    }
                }
            }
        }
    }


    func getAttrLineSpaceForContent(content:NSString)->NSAttributedString{
        if iOS6 {return NSAttributedString()}
        let attributeStr = NSMutableAttributedString(string:content as String)
        let lineStyle = NSMutableParagraphStyle()
        lineStyle.lineSpacing = 5.0
        attributeStr.addAttribute(NSParagraphStyleAttributeName, value: lineStyle, range: NSMakeRange(0, content.length))
        return attributeStr
    }


    func preferredHeight()->CGFloat{

        var height = Alert_View_Content_Padding_Top
        if self.title != nil {
            height += self.heightForTitleLabel()
        }

        if self.message != nil {
            if height > Alert_View_Content_Padding_Top {
                height += Alert_View_Gap
            }
            height += self.heightForMessageLabel()
        }

        if customView != nil {
            var rect = self.customView.frame
            if rect.size.height > ALert_View_Container_Height {
                rect.size.height = ALert_View_Container_Height
            }
            height += rect.size.height
        }

        if self.items.count > 0 {
            height += 1
            if height > Alert_View_Content_Padding_Top {
                height += Alert_View_Gap
            }

            if self.items.count <= 2 {
                height += Alert_View_Button_Height
            }else{
                height += (Alert_View_Button_Height + Alert_View_Gap) * CGFloat(self.items.count) - Alert_View_Gap
                if (self.buttons.count > 2) && ((self.items.lastObject as! CustomAlertItem).type == CustomAlertView_BtnType.Cancel) {
                    height += Alert_View_Cancel_Button_Padding_Top
                }
            }
        }
        height += Alert_View_Content_Padding_Bottom
        return height
    }


    func heightForTitleLabel()->CGFloat{
        if self.titleLabel != nil {
            let size = (self.title as NSString).size_Font(font: self.titleLabel.font, maxW: Alert_View_Container_Width - Alert_View_Content_Padding_Left * 2)
            return size.height
        }
        return 0
    }


    func heightForMessageLabel()->CGFloat{


        let minHeight = Alert_View_Message_Min_Line_Count * self.messageLabel.font.lineHeight
        if self.messageLabel != nil {

            let maxHeight = Alert_View_Message_Max_Line_Count * self.messageLabel.font.lineHeight
            var size = (self.message as NSString).size_Font(font: self.messageLabel.font, maxSize: CGSize.init(width: Alert_View_Container_Width - Alert_View_Content_Padding_Left * 2, height: maxHeight))
            if messageNeedLineSpace == true {
                size = self.getContentSizeForHasLineSpaceByContent(content: self.message as NSString, font: self.messageLabel.font, maxWidth: Alert_View_Container_Width - Alert_View_Content_Padding_Left * 2)
            }
            return max(minHeight, size.height)
        }
        return minHeight
    }




    func getContentSizeForHasLineSpaceByContent(content:NSString,font:UIFont,maxWidth:CGFloat)->CGSize{
        var sizeContent = content.size_Font(font: font, maxW: maxWidth)
        let strSize : NSString = "擦"
        let size = strSize.size_Font(font: font, maxW: maxWidth)
        if size.height > 0 {
            sizeContent.height += sizeContent.height/size.height * 5
        }
        return sizeContent
    }


    /*
     *  MARK: Setup
     *
     *
     */


    func setup(){
        self.setupContainerView()
        self.updateTitleLabel()
        self.updateMessageLabel()
        self.setupButtons()
        self.invaliadateLayout()
    }



    func teardown(){

        self.containerView.removeFromSuperview()
        self.containerView = nil
        self.titleLabel = nil
        self.messageLabel = nil
        self.lineContentLabel = nil
        self.lineBtnLabel = nil
        self.buttons.removeAllObjects()
        self.alertWindow.removeFromSuperview()
        self.alertWindow = nil


    }


    func setupContainerView(){

        self.containerView = UIView.init(frame: bounds)
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.cornerRadius = self.cornerRadius
        self.containerView.layer.shadowOffset = CGSize.zero
        self.containerView.layer.shadowRadius = 0.5
        self.addSubview(self.containerView)

        if (customView != nil) {
            self.containerView.addSubview(customView)
        }
    }


    func updateTitleLabel(){
        if self.title != nil {
            if self.titleLabel == nil {
                self.titleLabel = UILabel.init(frame: self.bounds)
                self.titleLabel.textAlignment = .center
                self.titleLabel.backgroundColor = UIColor.clear
                self.titleLabel.font = self.titleFOnt
                self.titleLabel.textColor = self.titleColor
                self.titleLabel.adjustsFontSizeToFitWidth = true
                self.titleLabel.minimumScaleFactor = 0.75
                self.containerView.addSubview(self.titleLabel)
            }
            self.titleLabel.text = self.title
        }else{
            self.titleLabel.removeFromSuperview()
            self.titleLabel = nil
        }
        if self.lineContentLabel == nil {
            self.lineContentLabel = UILabel.init(frame: self.bounds)
            self.lineContentLabel.backgroundColor = UIColor.clear
            self.containerView.addSubview(self.lineContentLabel)
        }
        self.invaliadateLayout()
    }


    func updateMessageLabel(){

        if self.message != nil {
            if self.messageLabel == nil {
                self.messageLabel = UILabel.init(frame: self.bounds)
                if messageIsAlignLeft == true {
                    self.messageLabel.textAlignment = .left
                }else{
                    self.messageLabel.textAlignment = .center
                }

                self.messageLabel.backgroundColor = UIColor.clear
                self.messageLabel.font = self.messageFont
                self.messageLabel.textColor = self.messageColor
                self.messageLabel.numberOfLines = Int(Alert_View_Message_Max_Line_Count)
                self.containerView.addSubview(self.messageLabel)
            }
            self.messageLabel.text = self.message
        }else{
            self.messageLabel.removeFromSuperview()
            self.messageLabel = nil
        }
        self.invaliadateLayout()

    }


    func setupButtons(){


        if self.lineContentLabel == nil {
            self.lineContentLabel = UILabel.init(frame: bounds)
            self.lineContentLabel.backgroundColor = UIColor.clear
            self.containerView.addSubview(self.lineContentLabel)
        }

        self.buttons = NSMutableArray()

        for i in 0..<self.items.count {
            let btn = self.buttonForItemIndex(index: i) 
            self.buttons.add(btn)
            self.containerView.addSubview(btn)
        }

        if self.items.count == 2 {
            if self.lineBtnLabel == nil {
                self.lineBtnLabel = UILabel.init(frame: self.bounds)
                self.lineBtnLabel.backgroundColor = UIColor.clear
                self.containerView.addSubview(self.lineBtnLabel)
            }
        }

    }

    func buttonForItemIndex(index:NSInteger)->UIButton{
        let item = self.items[index] as! CustomAlertItem
        let btn = UIButton.init(type: .custom)
        btn.tag = index
        btn.autoresizingMask = .flexibleWidth
        btn.titleLabel?.font = self.buttonFont
        btn.setTitle(item.title as String?, for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitleColor(UIColor.blue, for: .highlighted)
        btn.addTarget(self, action: #selector(AlertView.buttonAction(btn:)), for: .touchUpInside)
        return btn
    }


    /*
     *  Actions
     *
     */
    func buttonAction(btn:UIButton){
        let item : CustomAlertItem = self.items[btn.tag] as! CustomAlertItem
        if (item.action != nil) {
            item.action(self)
        }
        self.dismissAnimated(animated: true)
    }


    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let completion : ((Void)->Void)? = anim.value(forKey: "handler") as? ((Void)->Void)
        if completion != nil {
            completion!()
        }
    }


    /*
     *
     *  UIAppearance    setters
     *
     */
    func setViewBgColor(viewBgColor:UIColor){
        if self.viewBgColor == viewBgColor {
            return
        }
        self.viewBgColor = viewBgColor
        self.containerView.backgroundColor = viewBgColor
    }


    func setTitleFont(titleFont:UIFont){
        if self.titleFOnt == titleFont {
            return
        }
        self.titleFOnt = titleFont
        self.titleLabel.font = titleFont
        self.invaliadateLayout()
    }


    func setMessageFont(messageFont:UIFont){
        if self.messageFont == messageFont {
            return
        }
        self.messageFont = messageFont
        self.messageLabel.font = messageFont
        self.invaliadateLayout()
    }


    func setTitleColor(titleColor:UIColor){
        if self.titleColor == titleColor {
            return
        }
        self.titleColor = titleColor
        self.titleLabel.textColor = titleColor
    }


    func setMessageColor(messageColor:UIColor){
        if self.messageColor == messageColor {
            return
        }
        self.messageColor = messageColor
        self.messageLabel.textColor = messageColor
    }


    func setButtonFont(buttonFont:UIFont){
        if self.buttonFont == buttonFont {
            return
        }
        self.buttonFont = buttonFont
        for item in self.buttons {
            (item as! UIButton).titleLabel?.font = buttonFont
        }
    }


    func setCornerRadius(cornerRadius:CGFloat){
        if self.cornerRadius == cornerRadius {
            return
        }
        self.cornerRadius = cornerRadius
        self.containerView.layer.cornerRadius = cornerRadius
    }




    func setShadowRadius(shadowRadius:CGFloat){
        if self.shadowRadius == shadowRadius {
            return
        }
        self.shadowRadius = shadowRadius
        self.containerView.layer.shadowRadius = shadowRadius
    }







}






/*
 *
 *
 *
 */


class CustomAlertBgWindow: UIWindow {


    var style : CustomALertView_BgStyle! = nil



    override init(frame: CGRect) {
        super.init(frame: frame)

        autoresizingMask = [.flexibleWidth,.flexibleHeight]
        isOpaque = false
        windowLevel = UIWindowLevel(UIWindowLevelCustomAlertBg)

    }


    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        switch style.rawValue {
        case CustomALertView_BgStyle.Gradient.rawValue:

            let locationCount = 2
            let locations = [CGFloat(0.0),CGFloat(1.0)]
            let colors = [CGFloat(0.0),CGFloat(0.0),CGFloat(0.0),CGFloat(0.0),CGFloat(0.0),CGFloat(0.0),CGFloat(0.0),CGFloat(0.75)]

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient.init(colorSpace: colorSpace, colorComponents: colors, locations: locations, count: locationCount)

            let center = CGPoint.init(x: bounds.size.width, y: bounds.size.height / 2)
            let radius = min(bounds.size.width, bounds.size.height)

            context!.drawRadialGradient(gradient!,startCenter: center,startRadius: 0,endCenter: center,endRadius: radius,options: .drawsAfterEndLocation)
            print("1")
            break

        case CustomALertView_BgStyle.Solid.rawValue:

            UIView.animate(withDuration: 0.5, animations: {

                UIColor.init(white: 0, alpha: 0.5).set()
                context!.fill(self.bounds)

            })

            break

        default:
            break
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


/*
 *
 *
 *
 */
extension NSString{

    func size_Font(font:UIFont,maxW:CGFloat) -> CGSize {
        var attrs : [String:AnyObject] = [:]
        attrs[NSFontAttributeName] = font
        let maxSize = CGSize.init(width: maxW, height: CGFloat(MAXFLOAT))
        return self.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: attrs, context: nil).size;
    }

    func size_Font(font:UIFont,maxSize:CGSize)->CGSize{
        var attrs : [String:AnyObject] = [:]
        attrs[NSFontAttributeName] = font
        return self.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: attrs, context: nil).size;
    }

    func size_Font(font:UIFont)->CGSize{
        return self.size_Font(font: font, maxW: CGFloat(MAXFLOAT))
    }
    
}







