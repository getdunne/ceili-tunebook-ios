//
//  ViewController.swift
//  CeiliTunes
//
//  Created by Shane Dunne on 2016-09-06.
//  Copyright © 2016 Shane Dunne. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    
    let startingUrl = "http://test123.podzone.net/book/1"
    
    var scrollPos: [CGFloat] = []
    var scrollIdx = 0
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(ViewController.scrollUpHandler(_:))),
            UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: UIKeyModifierFlags(rawValue: 0), action: #selector(ViewController.scrollDownHandler(_:))),
        ]
    }
    
    // Rebuild list of scroll positions
    func buildScrollPos() {
        scrollPos.removeAll()
        
        // begin with list of tune offsets from document
        var sp: [CGFloat] = []
        let tops = webView.stringByEvaluatingJavaScriptFromString("getTuneOffsets()")
        if (tops == "") {
            return
        }
        for s in (tops?.componentsSeparatedByString(","))! {
            sp.append(CGFloat((s as NSString).floatValue))
        }
        
        // add intermediate points
        let frameHeight = webView.frame.height
        var prevPos = sp[0]
        for (index, curPos) in sp.enumerate() {
            if index > 0 && index < sp.count - 1 {
                let nextPos = sp[index+1]
                let tuneHeight = curPos - prevPos
                let nextTuneHeight = nextPos - curPos
                if tuneHeight > frameHeight {
                    // Tune too tall for frame
                    scrollPos.append(prevPos + 0.7 * frameHeight)
                }
                else if (tuneHeight + 0.3 * nextTuneHeight) > frameHeight {
                    // Can't see enough of next tune
                    scrollPos.append(prevPos + 0.5 * frameHeight)
                }
            }
            scrollPos.append(curPos)
            prevPos = curPos
        }
        
        // go immediately to first scroll point
        scrollIdx = 0
        webView.scrollView.setContentOffset(CGPointMake(0, scrollPos[scrollIdx]), animated: false)
    }
    
    func scrollUpHandler(sender: UIKeyCommand) {
        if scrollIdx > 0 {
            scrollIdx -= 1
            webView.scrollView.setContentOffset(CGPointMake(0, scrollPos[scrollIdx]), animated: true)
        }
    }
    
    func scrollDownHandler(sender: UIKeyCommand) {
        if scrollIdx + 1 < scrollPos.count {
            scrollIdx += 1
            webView.scrollView.setContentOffset(CGPointMake(0, scrollPos[scrollIdx]), animated: true)
        }
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        webView.goBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipes(_:)))
        leftSwipe.direction = .Left
        webView.addGestureRecognizer(leftSwipe)
        
        let url = NSURL(string: startingUrl)
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        buildScrollPos()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        webView.reload()
        webView.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
