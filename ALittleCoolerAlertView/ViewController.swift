//
//  ViewController.swift
//  ALittleCoolerAlertView
//
//  Created by langyue on 16/10/18.
//  Copyright © 2016年 langyue. All rights reserved.
//

import UIKit





let networkLoadingView_Key = "networkLoadingView_Key"

class ViewController: UIViewController {

    var networkLoadingView : UIView! = nil


    func setNetworkLoadingView(networkLoadingView:UIView){
        objc_setAssociatedObject(self, networkLoadingView_Key, networkLoadingView, .OBJC_ASSOCIATION_RETAIN)
    }
    func getNetworkLoadingView()->UIView{
        return objc_getAssociatedObject(self, networkLoadingView_Key) as! UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func alertBtnAction(_ sender: UIButton) {

        switch sender.tag-300 {
        case 0:

            let alertView = AlertView.init(title: "提示", message: "美女你走光了")
            alertView.addBtn(title: "取消", type: .Default, handler: { (alert) in

            })
            alertView.addBtn(title: "确定", type: .Cancel, handler: { (alert) in

            })
            alertView.show()

        case 1:

            let alertView = AlertView.init(title: "提示", message: "美女你走光了")
            alertView.addBtn(title: "取消", type: .Default, handler: { (alert) in

            })
            alertView.addBtn(title: "确定", type: .Cancel, handler: { (alert) in

            })
            alertView.transitionStyle = CustomAlertView_TransitionStyle.SlideFromTop

            alertView.show()


        case 2:

            let alertView = AlertView.init(title: "提示", message: "美女你走光了")
            alertView.addBtn(title: "取消", type: .Default, handler: { (alert) in

            })  
            alertView.addBtn(title: "确定", type: .Cancel, handler: { (alert) in

            })
            alertView.transitionStyle = CustomAlertView_TransitionStyle.Bounce
            alertView.show()

        case 3:

            Alert.show(str: "呵呵！", hasSuccessIcon: true, parentView: self.view)

        case 4:


            self.networkLoadingView = AlertLoading.alertLoading(msg: "请稍后", frame: CGRect.init(x: (Int(self.view.frame.size.width-130)/2), y: 100, width: 130, height: 100), isBelowNav: true)
            view.addSubview(self.networkLoadingView)


        default: break

        }



    }



    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.networkLoadingView != nil {
            self.networkLoadingView.removeFromSuperview()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

