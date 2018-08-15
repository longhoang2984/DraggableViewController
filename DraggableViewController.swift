//
//  DraggableViewController.swift
//  LiveStreamViewer
//
//  Created by Long Hoang on 8/7/18.
//  Copyright © 2018 Long Hoang. All rights reserved.
//

import UIKit

enum UIPanGestureRecognizerDirection : Int {
     case undefined
     case up
     case down
     case left
     case right
}

protocol DraggableViewControllerDelegate: class {
     func removeDraggableFloatingViewController()
}

class DraggableViewController: UIViewController, UIGestureRecognizerDelegate {
     var bodyView: UIView = UIView()
     //please add controller on this
     var controllerView: UIView = UIView()
     //please add loading spiner on this
     var messageView: UIView = UIView()
     var videoWrapperFrame = CGRect.zero
     var minimizedVideoFrame = CGRect.zero
     var pageWrapperFrame = CGRect.zero
     var wFrame = CGRect.zero
     var vFrame = CGRect.zero
     var _touchPositionInHeaderY: CGFloat = 0.0
     var _touchPositionInHeaderX: CGFloat = 0.0
     var direction: UIPanGestureRecognizerDirection?
     var tapRecognizer: UITapGestureRecognizer?
     var transparentBlackSheet: UIView = UIView()
     var isExpandedMode = false
     var pageWrapper: UIView = UIView()
     var videoWrapper: UIView = UIView()
     var videoView: UIView = UIView()
     var borderView: UIView = UIView()
     var maxH: CGFloat = 0.0
     var maxW: CGFloat = 0.0
     var videoHeightRatio: CGFloat = 0.0
     var finalViewOffsetY: CGFloat = 0.0
     var minimamVideoHeight: CGFloat = 0.0
     var parentView: UIView = UIView()
     var isDisplayController = false
     var hideControllerTimer: Timer?
     var isMinimizingByGesture = false
     var isAppear = false
     var isSetuped = false
     var windowFrame = CGRect.zero
     var centerDraggableView: CGPoint = .zero
     let finalMargin: CGPoint = CGPoint(x: 3, y: 60)
     let minimamVideoWidth: CGFloat = 140
     let flickVelocity: CGFloat = 1000
     
     func didExpand() {
     }
     func didMinimize() {
     }
     func didStartMinimizeGesture() {
          UIApplication.shared.isStatusBarHidden = false
     }
     func didFullExpandByGesture() {
     }
     func didDisappear() {
     }
     func didReAppear() {
     }
     
     func show() {
          if !isSetuped {
               setup()
          } else {
               if !isAppear {
                    reAppearWithAnimation()
               }
          }
     }
     
     func setup() {
          isSetuped = true
          print("showVideoViewControllerOnParentVC")
          if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
               UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
          }
          //        UIApplication.shared.setStatusBarHidden(true, with: .slide)
          getWindow().addSubview(view)
          perform(#selector(self.showThisView), with: nil, afterDelay: 0.0)
          isAppear = true
     }
     func setupViews(withVideoView vView: UIView?, videoViewHeight videoHeight: CGFloat) {
          print("setupViewsWithVideoView")
          videoView = vView ?? UIView()
          windowFrame = UIScreen.main.bounds
          maxH = windowFrame.size.height
          maxW = windowFrame.size.width
          let videoWidth = maxW
          videoHeightRatio = videoHeight / videoWidth
          minimamVideoHeight = minimamVideoWidth * videoHeightRatio
          finalViewOffsetY = maxH - minimamVideoHeight - finalMargin.y
          videoWrapper = UIView()
          videoWrapper.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
          videoView.frame = videoWrapper.frame
          centerDraggableView = videoView.center
          controllerView.frame = videoWrapper.frame
          messageView.frame = videoWrapper.frame
          pageWrapper = UIView()
          pageWrapper.frame = CGRect(x: 0, y: 0, width: maxW, height: maxH)
          
          videoWrapperFrame = videoWrapper.frame
          pageWrapperFrame = pageWrapper.frame
          borderView = UIView()
          borderView.clipsToBounds = true
          borderView.layer.masksToBounds = false
          borderView.layer.borderColor = UIColor.white.cgColor
          borderView.layer.borderWidth = 0.5
          borderView.alpha = 0
          borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
          bodyView.frame = CGRect(x: 0, y: videoHeight, width: maxW, height: maxH - videoHeight)
     }
     @objc func showThisView() {
          videoView.backgroundColor = UIColor.black
          videoWrapper.backgroundColor = UIColor.black
          pageWrapper.addSubview(bodyView)
          videoWrapper.addSubview(videoView)
          view.addSubview(pageWrapper)
          view.addSubview(videoWrapper)
          transparentBlackSheet = UIView(frame: windowFrame)
          transparentBlackSheet.backgroundColor = UIColor.black
          transparentBlackSheet.alpha = 1
          appearAnimation()
     }
     func appearAnimation() {
          view.frame = CGRect(x: windowFrame.size.width - 50, y: windowFrame.size.height - 50, width: windowFrame.size.width, height: windowFrame.size.height)
          view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
          view.alpha = 0
          UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
               self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
               self.view.alpha = 1
               self.view.frame = CGRect(x: self.windowFrame.origin.x, y: self.windowFrame.origin.y, width: self.windowFrame.size.width, height: self.windowFrame.size.height)
          }) { finished in
               self.afterAppearAnimation()
          }
     }
     
     func afterAppearAnimation() {
          videoWrapper.backgroundColor = UIColor.clear
          videoView.backgroundColor = videoWrapper.backgroundColor
          getWindow().addSubview(transparentBlackSheet)
          getWindow().addSubview(pageWrapper)
          getWindow().addSubview(videoWrapper)
          view.isHidden = true
          videoView.addSubview(borderView)
          videoWrapper.addSubview(controllerView)
          messageView.isHidden = true
          videoWrapper.addSubview(messageView)
          showControllerView()
          let expandedTap = UITapGestureRecognizer(target: self, action: #selector(self.onTapExpandedVideoView))
          expandedTap.numberOfTapsRequired = 1
          expandedTap.delegate = self
          videoWrapper.addGestureRecognizer(expandedTap)
          vFrame = videoWrapperFrame
          wFrame = pageWrapperFrame
          let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(_:)))
          pan.delegate = self
          videoWrapper.addGestureRecognizer(pan)
          isExpandedMode = true
     }
     func disappear() {
          isAppear = false
     }
    
     func reAppearWithAnimation() {
          borderView.alpha = 0
          transparentBlackSheet.alpha = 0
          videoWrapper.alpha = 0
          pageWrapper.alpha = 0
          pageWrapper.frame = pageWrapperFrame
          videoWrapper.frame = videoWrapperFrame
          videoView.frame = videoWrapperFrame
          controllerView.frame = videoView.frame
          bodyView.frame = CGRect(x: 0, y: videoView.frame.size.height, width: bodyView.frame.size.width, height: bodyView.frame.size.height)
          borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
          pageWrapper.frame = CGRect(x: windowFrame.size.width - 50, y: windowFrame.size.height - 150, width: pageWrapper.frame.size.width, height: pageWrapper.frame.size.height)
          videoWrapper.frame = CGRect(x: windowFrame.size.width - 50, y: windowFrame.size.height - 150, width: videoWrapper.frame.size.width, height: videoWrapper.frame.size.height)
          UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
               self.pageWrapper.alpha = 1
               self.pageWrapper.frame = CGRect(x: self.windowFrame.origin.x, y: self.windowFrame.origin.y, width: self.pageWrapper.frame.size.width, height: self.pageWrapper.frame.size.height)
               self.videoWrapper.alpha = 1
               self.videoWrapper.frame = CGRect(x: self.windowFrame.origin.x, y: self.windowFrame.origin.y, width: self.videoWrapper.frame.size.width, height: self.videoWrapper.frame.size.height)
          }) { finished in
               self.transparentBlackSheet.alpha = 1.0
               if let gestures = self.videoWrapper.gestureRecognizers {
                    for recognizer: UIGestureRecognizer in gestures {
                         if (recognizer is UITapGestureRecognizer) {
                              self.videoWrapper.removeGestureRecognizer(recognizer)
                         }
                    }
               }
               
               let expandedTap = UITapGestureRecognizer(target: self, action: #selector(self.onTapExpandedVideoView))
               expandedTap.numberOfTapsRequired = 1
               expandedTap.delegate = self
               self.videoWrapper.addGestureRecognizer(expandedTap)
               self.isExpandedMode = true
               self.didExpand()
               self.didReAppear()
          }
     }
     
     func bringToFront() {
          if isSetuped {
               getWindow().bringSubview(toFront: view)
               getWindow().bringSubview(toFront: transparentBlackSheet)
               getWindow().bringSubview(toFront: pageWrapper)
               getWindow().bringSubview(toFront: videoWrapper)
          }
     }
     func getWindow() -> UIWindow {
          return UIApplication.shared.delegate!.window!!
     }
     
     func removeAllViews() {
          //        UIApplication.shared.setStatusBarHidden(false, with: .slide)
          videoWrapper.removeFromSuperview()
          pageWrapper.removeFromSuperview()
          transparentBlackSheet.removeFromSuperview()
          view.removeFromSuperview()
     }
     
     deinit {
     }
     
     func showMessageView() {
          messageView.isHidden = false
     }
     
     func hideMessageView() {
          messageView.isHidden = true
     }
     
     func setHideControllerTimer() {
          if let `hideControllerTimer` = hideControllerTimer {
               if hideControllerTimer.isValid {
                    hideControllerTimer.invalidate()
               }
          }
          
          self.hideControllerTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hideControllerView), userInfo: nil, repeats: false)
     }
     
     @objc func showControllerView() {
          isDisplayController = true
          setHideControllerTimer()
          UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
               self.controllerView.alpha = 1.0
          }) { finished in
          }
     }
     @objc func hideControllerView() {
          isDisplayController = false
          guard let `hideControllerTimer` = hideControllerTimer else { return }
          if hideControllerTimer.isValid {
               hideControllerTimer.invalidate()
          }
          UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
               self.controllerView.alpha = 0.0
          }) { finished in
          }
     }
     
     func showControllerAfterExpanded() {
          Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showControllerView), userInfo: nil, repeats: false)
     }
     @objc func onTapExpandedVideoView() {
          print("onTapExpandedVideoView")
          if controllerView.alpha == 0.0 {
               showControllerView()
          } else if controllerView.alpha == 1.0 {
               hideControllerView()
          }
     }
     @objc func expandView(onTap sender: UITapGestureRecognizer?) {
          expandView()
          showControllerAfterExpanded()
     }
     
     @objc func panAction(_ recognizer: UIPanGestureRecognizer?) {
          guard let `recognizer` = recognizer, let activeView = recognizer.view else { return }
          let touchPosInViewY: CGFloat = recognizer.location(in: view).y
          if recognizer.state == .began {
               direction = UIPanGestureRecognizerDirection.undefined
               let velocity: CGPoint = recognizer.velocity(in: recognizer.view)
               detectPanDirection(velocity)
               isMinimizingByGesture = false
               _touchPositionInHeaderY = recognizer.location(in: videoWrapper).y
               _touchPositionInHeaderX = recognizer.location(in: videoWrapper).x
               if direction == UIPanGestureRecognizerDirection.down {
                    if videoView.frame.size.height > minimamVideoHeight {
                         print("minimize gesture start")
                         isMinimizingByGesture = true
                         didStartMinimizeGesture()
                    }
               }
               centerDraggableView = activeView.center
          } else if recognizer.state == .changed {
               if isExpandedMode {
                    if direction == UIPanGestureRecognizerDirection.down || direction == UIPanGestureRecognizerDirection.up {
                         let newOffsetY: CGFloat = touchPosInViewY - _touchPositionInHeaderY
                         adjustView(onVerticalPan: newOffsetY, recognizer: recognizer)
                    } else if direction == UIPanGestureRecognizerDirection.right || direction == UIPanGestureRecognizerDirection.left {
                         adjustView(onHorizontalPan: recognizer)
                    }
               }else {
                    let translation = recognizer.translation(in: activeView.superview)
                    UIView.animate(withDuration: 0.25, animations: {
                         activeView.center = CGPoint(x: self.centerDraggableView.x + translation.x, y: self.centerDraggableView.y + translation.y)
                    })
               }
          } else if recognizer.state == .ended {
               if isExpandedMode && isMinimizingByGesture {
                    let velocity: CGPoint = recognizer.velocity(in: recognizer.view)
                    if direction == UIPanGestureRecognizerDirection.down || direction == UIPanGestureRecognizerDirection.up {
                         if velocity.y < -flickVelocity {
                              expandView()
                              if isMinimizingByGesture == false {
                                   showControllerAfterExpanded()
                              }
                              recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                              return
                         } else if velocity.y > flickVelocity {
                              minimizeView()
                              recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                              return
                         }else if recognizer.view?.frame.origin.y ?? 0 > (windowFrame.size.width / 2) {
                              minimizeView()
                              recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                              return
                         } else if recognizer.view?.frame.origin.y ?? 0 < (windowFrame.size.width / 2) || recognizer.view?.frame.origin.y ?? 0 < 0 {
                              expandView()
                              if isMinimizingByGesture == false {
                                   showControllerAfterExpanded()
                              }
                              recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                              return
                         }
                    }else if direction == UIPanGestureRecognizerDirection.left {
                         if pageWrapper.alpha <= 0 {
                              if velocity.x < -flickVelocity || pageWrapper.alpha < 0.3 {
                                   fadeOutView(toLeft: recognizer) {
                                        self.disappear()
                                   }
                                   return
                              } else if (recognizer.view ?? UIView()).frame.origin.x < 0 {
                                   disappear()
                              } else {
                                   animateMiniView(toNormalPosition: recognizer, completion: {})
                              }
                         }
                    }else if direction == UIPanGestureRecognizerDirection.right {
                         if pageWrapper.alpha <= 0 {
                              if velocity.x > flickVelocity {
                                   fadeOutView(toRight: recognizer) {
                                        self.disappear()
                                   }
                                   return
                              }
                              if (recognizer.view ?? UIView()).frame.origin.x > windowFrame.size.width - 50 {
                                   disappear()
                              } else {
                                   animateMiniView(toNormalPosition: recognizer, completion: {})
                              }
                         }
                    }
                    isMinimizingByGesture = false
               }else {
                    //                let location = recognizer.location(in: activeView.superview)
                    let location = activeView.frame.origin
                    var position = CGPoint.zero
                    if location.y < screenHeight / 2 {
                         if location.x < 0 {
                              position = CGPoint(x: location.x - activeView.frame.width, y: location.y)
                         }else if location.x + activeView.frame.width / 2 > screenWidth {
                              position = CGPoint(x: location.x + activeView.frame.width*2, y: location.y)
                         } else if location.x < screenWidth / 2 {
                              position = CGPoint(x: finalMargin.x, y: finalMargin.y + self.view.frame.origin.y)
                         }else if location.x > screenWidth / 2 {
                              position = CGPoint(x: screenWidth - activeView.frame.size.width - finalMargin.x, y: finalMargin.y + self.view.frame.origin.y)
                         }
                    }else {
                         if location.x < 0 {
                              position = CGPoint(x: location.x - activeView.frame.width, y: location.y)
                         }else if location.x  + activeView.frame.width / 2 > screenWidth {
                              position = CGPoint(x: location.x + activeView.frame.width*2, y: location.y)
                         } else if location.x < screenWidth / 2 {
                              position = CGPoint(x: finalMargin.x, y: screenHeight - finalMargin.y - activeView.frame.size.height)
                         }else if location.x > screenWidth / 2 {
                              position = CGPoint(x: screenWidth - activeView.frame.size.width - finalMargin.x, y: screenHeight - finalMargin.y - activeView.frame.size.height)
                         }
                    }
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                         activeView.frame.origin = position
                    }, completion: { (_) in
                         if location.x < 0 || location.x + activeView.frame.width  / 2 > screenWidth {
                              self.didDisappear()
                              self.disappear()
                         }
                    })
               }
          }
     }
     
     func detectPanDirection(_ velocity: CGPoint) {
          let isVerticalGesture: Bool = fabs(Float(velocity.y)) > fabs(Float(velocity.x))
          if isVerticalGesture {
               if velocity.y > 0 {
                    direction = UIPanGestureRecognizerDirection.down
               } else {
                    direction = UIPanGestureRecognizerDirection.up
               }
          } else {
               if velocity.x > 0 {
                    direction = UIPanGestureRecognizerDirection.right
               } else {
                    direction = UIPanGestureRecognizerDirection.left
               }
          }
     }
     
     func adjustView(onVerticalPan newOffsetY: CGFloat, recognizer: UIPanGestureRecognizer?) {
          guard let `recognizer` = recognizer else { return }
          var newOffsetY = newOffsetY
          let touchPosInViewY: CGFloat = recognizer.location(in: view).y
          var progressRate: CGFloat = newOffsetY / finalViewOffsetY
          if progressRate >= 0.99 {
               progressRate = 1
               newOffsetY = finalViewOffsetY
          }
          calcNewFrame(withParsentage: progressRate, newOffsetY: newOffsetY, location: recognizer.translation(in: view))
          if progressRate <= 1 && pageWrapper.frame.origin.y >= 0 {
               pageWrapper.frame = wFrame
               videoWrapper.frame = vFrame
               videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
               bodyView.frame = CGRect(x: 0, y: videoView.frame.size.height, width: bodyView.frame.size.width, height: bodyView.frame.size.height)
               borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
               controllerView.frame = videoView.frame
               let percentage: CGFloat = touchPosInViewY / windowFrame.size.height
               transparentBlackSheet.alpha = 1.0 - (percentage * 1.5)
               pageWrapper.alpha = transparentBlackSheet.alpha
               if percentage > 0.2 {
                    borderView.alpha = percentage
               } else {
                    borderView.alpha = 0
               }
               if isDisplayController {
                    controllerView.alpha = 1.0 - (percentage * 2)
               }
               if direction == UIPanGestureRecognizerDirection.down {
                    bringToFront()
               }
               if direction == UIPanGestureRecognizerDirection.up && videoView.frame.origin.y <= 10 {
                    didFullExpandByGesture()
               }
          }else if wFrame.origin.y < finalViewOffsetY && wFrame.origin.y > 0 {
               pageWrapper.frame = wFrame
               videoWrapper.frame = vFrame
               videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
               bodyView.frame = CGRect(x: 0, y: videoView.frame.size.height, width: bodyView.frame.size.width, height: bodyView.frame.size.height)
               borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
               borderView.alpha = progressRate
               controllerView.frame = videoView.frame
          }
          recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
     }
     
     func adjustView(onHorizontalPan recognizer: UIPanGestureRecognizer?) {
          guard let `recognizer` = recognizer else { return }
          let x: CGFloat = recognizer.location(in: view).x
          if pageWrapper.alpha <= 0 {
               if direction == UIPanGestureRecognizerDirection.left {
                    let velocity: CGPoint? = recognizer.velocity(in: recognizer.view)
                    let isVerticalGesture: Bool = fabs(Float(velocity?.y ?? 0.0)) > fabs(Float(velocity?.x ?? 0.0))
                    let translation: CGPoint = recognizer.translation(in: recognizer.view)
                    recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
                    if !isVerticalGesture {
                         let percentage: CGFloat = x / windowFrame.size.width
                         recognizer.view?.alpha = percentage
                    }
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
               }else if direction == UIPanGestureRecognizerDirection.right {
                    let velocity: CGPoint = recognizer.velocity(in: recognizer.view)
                    let isVerticalGesture: Bool = fabs(Float(velocity.y)) > fabs(Float(velocity.x))
                    let translation: CGPoint = recognizer.translation(in: recognizer.view)
                    recognizer.view?.center = CGPoint(x: (recognizer.view ?? UIView()).center.x + translation.x, y: (recognizer.view ?? UIView()).center.y)
                    if !isVerticalGesture {
                         if velocity.x > 0 {
                              let percentage: CGFloat = x / windowFrame.size.width
                              recognizer.view?.alpha = 1.0 - percentage
                         } else {
                              let percentage: CGFloat = x / windowFrame.size.width
                              recognizer.view?.alpha = percentage
                         }
                    }
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
               }
          }
     }
     
     func calcNewFrame(withParsentage persentage: CGFloat, newOffsetY: CGFloat, location: CGPoint = .zero) {
          let newWidth: CGFloat = minimamVideoWidth + ((maxW - minimamVideoWidth) * (1 - persentage))
          let newHeight: CGFloat = newWidth * videoHeightRatio
          let newOffsetX: CGFloat = location.x
          vFrame.size.width = newWidth
          vFrame.size.height = newHeight
          vFrame.origin.y = newOffsetY
          wFrame.origin.y = newOffsetY
          vFrame.midX += newOffsetX
          wFrame.midX += newOffsetX
     }
     func setFinalFrame() {
          vFrame.size.width = minimamVideoWidth
          vFrame.size.height = vFrame.size.width * videoHeightRatio
          vFrame.origin.y = maxH - vFrame.size.height - finalMargin.y
          vFrame.origin.x = maxW - vFrame.size.width - finalMargin.x
          wFrame.origin.y = vFrame.origin.y
          wFrame.origin.x = vFrame.origin.x
     }
     
     
     func expandView() {
          UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
               self.pageWrapper.frame = self.pageWrapperFrame
               self.videoWrapper.frame = self.videoWrapperFrame
               self.videoWrapper.alpha = 1
               self.videoView.frame = self.videoWrapperFrame
               self.pageWrapper.alpha = 1.0
               self.transparentBlackSheet.alpha = 1.0
               self.borderView.alpha = 0.0
               self.bodyView.frame = CGRect(x: 0, y: self.videoView.frame.size.height, width: self.bodyView.frame.size.width, height: self.bodyView.frame.size.height)
               self.borderView.frame = CGRect(x: self.videoView.frame.origin.y - 1, y: self.videoView.frame.origin.x - 1, width: self.videoView.frame.size.width + 1, height: self.videoView.frame.size.height + 1)
               self.controllerView.frame = self.videoView.frame
               self.wFrame = self.pageWrapperFrame
               self.vFrame = self.videoWrapperFrame
               self.videoView.layer.cornerRadius = 0
               self.videoView.clipsToBounds = true
          }) { finished in
               if let gestures = self.videoWrapper.gestureRecognizers {
                    for recognizer: UIGestureRecognizer in gestures {
                         if (recognizer is UITapGestureRecognizer) {
                              self.videoWrapper.removeGestureRecognizer(recognizer)
                         }
                    }
               }
               let expandedTap = UITapGestureRecognizer(target: self, action: #selector(self.onTapExpandedVideoView))
               expandedTap.numberOfTapsRequired = 1
               expandedTap.delegate = self
               self.videoWrapper.addGestureRecognizer(expandedTap)
               self.isExpandedMode = true
               self.didExpand()
               self.vFrame = self.videoWrapperFrame
               self.wFrame = self.pageWrapperFrame
               self.messageView.frame = self.videoView.frame
          }
     }
     
     func minimizeView() {
          setFinalFrame()
          hideControllerView()
          UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
               self.pageWrapper.frame = self.wFrame
               self.videoWrapper.frame = self.vFrame
               self.videoView.frame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.x, width: self.vFrame.size.width, height: self.vFrame.size.height)
               self.pageWrapper.alpha = 0
               self.transparentBlackSheet.alpha = 0.0
               self.borderView.alpha = 1.0
               self.borderView.frame = CGRect(x: self.videoView.frame.origin.y - 1, y: self.videoView.frame.origin.x - 1, width: self.videoView.frame.size.width + 1, height: self.videoView.frame.size.height + 1)
               self.controllerView.frame = self.videoView.frame
               self.videoView.layer.cornerRadius = 5
               self.videoView.clipsToBounds = true
          }) { finished in
               self.didMinimize()
               self.tapRecognizer = nil
               if self.tapRecognizer == nil {
                    if let gestures = self.videoWrapper.gestureRecognizers {
                         for recognizer: UIGestureRecognizer in gestures {
                              if (recognizer is UITapGestureRecognizer) {
                                   self.videoWrapper.removeGestureRecognizer(recognizer)
                              }
                         }
                    }
                    self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandView(onTap:)))
                    self.tapRecognizer?.numberOfTapsRequired = 1
                    self.tapRecognizer?.delegate = self
                    self.videoWrapper.addGestureRecognizer(self.tapRecognizer!)
               }
               self.isExpandedMode = false
               self.messageView.frame = self.videoView.frame
               self.minimizedVideoFrame = self.videoWrapper.frame
               if self.direction == UIPanGestureRecognizerDirection.down {
                    self.bringToFront()
               }
          }
     }
     
     func animateMiniView(toNormalPosition recognizer: UIPanGestureRecognizer?, completion: @escaping () -> Void) {
          setFinalFrame()
          UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
               self.pageWrapper.frame = self.wFrame
               self.videoWrapper.frame = self.vFrame
               self.videoView.frame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.x, width: self.vFrame.size.width, height: self.vFrame.size.height)
               self.pageWrapper.alpha = 0
               self.videoWrapper.alpha = 1
               self.borderView.alpha = 1
               self.controllerView.frame = self.videoView.frame
          }) { finished in
               if finished {
                    completion()
               }
          }
          recognizer?.setTranslation(CGPoint.zero, in: recognizer?.view)
     }
     
     func fadeOutView(toRight recognizer: UIPanGestureRecognizer?, completion: @escaping () -> Void) {
          vFrame.origin.x = maxW + minimamVideoWidth
          wFrame.origin.x = maxW + minimamVideoWidth
          UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
               self.pageWrapper.frame = self.wFrame
               self.videoWrapper.frame = self.vFrame
               self.videoView.frame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.x, width: self.vFrame.size.width, height: self.vFrame.size.height)
               self.pageWrapper.alpha = 0
               self.videoWrapper.alpha = 0
               self.borderView.alpha = 0
               self.controllerView.frame = self.videoView.frame
          }) { finished in
               if finished {
                    completion()
               }
               self.didDisappear()
          }
          recognizer?.setTranslation(CGPoint.zero, in: recognizer?.view)
     }
     
     func fadeOutView(toLeft recognizer: UIPanGestureRecognizer?, completion: @escaping () -> Void) {
          vFrame.origin.x = -maxW
          wFrame.origin.x = -maxW
          UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
               self.pageWrapper.frame = self.wFrame
               self.videoWrapper.frame = self.vFrame
               self.videoView.frame = CGRect(x: self.videoView.frame.origin.x, y: self.videoView.frame.origin.x, width: self.vFrame.size.width, height: self.vFrame.size.height)
               self.pageWrapper.alpha = 0
               self.videoWrapper.alpha = 0
               self.borderView.alpha = 0
               self.controllerView.frame = self.videoView.frame
          }) { finished in
               if finished {
                    completion()
               }
               self.didDisappear()
          }
          recognizer?.setTranslation(CGPoint.zero, in: recognizer?.view)
     }
     
     // MARK:- Pan Gesture Delagate
     func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
          if let panGesture = gestureRecognizer as? UIPanGestureRecognizer, isExpandedMode {
               let velocity: CGPoint = panGesture.velocity(in: panGesture.view)
               detectPanDirection(velocity)
               if direction == UIPanGestureRecognizerDirection.down {
                    return true
               }else {
                    return false
               }
          }else {
               return true
          }
     }
     private func gestureRecognizerShould(_ gestureRecognizer: UIGestureRecognizer?) -> Bool {
          if (gestureRecognizer?.view?.frame.origin.y ?? 0.0) < 0 {
               return false
          } else {
               return true
          }
     }
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
          return true
     }
     
     override var prefersStatusBarHidden: Bool {
          return true
     }
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
          return UIInterfaceOrientationMask.portrait
     }
     
     override var shouldAutorotate: Bool {
          return false
     }
}

extension CGRect {
     var x: CGFloat {
          get {
               return self.origin.x
          }
          set {
               self = CGRect(x: newValue, y: self.y, width: self.width, height: self.height)
          }
     }
     
     var y: CGFloat {
          get {
               return self.origin.y
          }
          set {
               self = CGRect(x: self.x, y: newValue, width: self.width, height: self.height)
          }
     }
     
     var width: CGFloat {
          get {
               return self.size.width
          }
          set {
               self = CGRect(x: self.x, y: self.y, width: newValue, height: self.height)
          }
     }
     
     var height: CGFloat {
          get {
               return self.size.height
          }
          set {
               self = CGRect(x: self.x, y: self.y, width: self.width, height: newValue)
          }
     }
     
     
     var top: CGFloat {
          get {
               return self.origin.y
          }
          set {
               y = newValue
          }
     }
     
     var bottom: CGFloat {
          get {
               return self.origin.y + self.size.height
          }
          set {
               self = CGRect(x: x, y: newValue - height, width: width, height: height)
          }
     }
     
     var left: CGFloat {
          get {
               return self.origin.x
          }
          set {
               self.x = newValue
          }
     }
     
     var right: CGFloat {
          get {
               return x + width
          }
          set {
               self = CGRect(x: newValue - width, y: y, width: width, height: height)
          }
     }
     
     
     var midX: CGFloat {
          get {
               return self.x + self.width / 2
          }
          set {
               self = CGRect(x: newValue - width / 2, y: y, width: width, height: height)
          }
     }
     
     var midY: CGFloat {
          get {
               return self.y + self.height / 2
          }
          set {
               self = CGRect(x: x, y: newValue - height / 2, width: width, height: height)
          }
     }
     
     
     var center: CGPoint {
          get {
               return CGPoint(x: self.midX, y: self.midY)
          }
          set {
               self = CGRect(x: newValue.x - width / 2, y: newValue.y - height / 2, width: width, height: height)
          }
     }
     
     init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
          self.init(x:x, y:y, width:w, height:h)
     }
}
