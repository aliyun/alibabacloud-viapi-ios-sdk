//
//  SegmentationViewController.swift
//  SegmentDemo
//
//  Created by fcq on 2021/5/13.
//

import UIKit
import AVFoundation
import VideoToolbox
import MetalKit
import CoreVideo
import Photos

class SegmentationViewController: UIViewController {
    
    private let videoCapture = VideoCapture()
    private let imageView = UIImageView()
    private let bgImageView = UIImageView()
    private var scopeButton = UIButton()
    private let effectView = DamoPageView(effect: UIBlurEffect(style: .dark))
    private var menuShowing = false
    private var backgroundImage: UIImage?
    private var selectVideoURL: URL?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let takePicBtn = UIButton()
    private var palyerView = UIView()
    // 分割器
    private var segmentator: HuManRealTimeVideoSegmentor?
    private var limitFrame = 1
    // 需要写入的帧
    private var inputImages = [UIImage]()
    private var outputImages = [UIImage]()
    private var frameCount = 0
    
    private var imageDirection = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        videoCapture.startCapturing()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        palyerView.frame = view.bounds
        view.addSubview(palyerView)
        view.addSubview(bgImageView)
        view.addSubview(imageView)
       // bgImageView.frame = view.frame;
        bgImageView.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(0);
            make?.centerY.mas_equalTo()(0);
            make?.width.mas_equalTo()(self.view.frame.size.width);
            make?.height.mas_equalTo()(self.view.frame.size.height);
                }
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toucupPreview)))
      
        let button = UIButton(frame: CGRect(x: 15, y: 44, width: 60, height: 30))
        button.setTitle("关闭", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(segAction), for: .touchUpInside)
        view.addSubview(button)
        
        let flipButton = UIButton(frame: CGRect(x: view.frame.width - 15 - 40, y: 44, width: 40, height: 40))
        flipButton.setImage(UIImage(named: "ic_switch_camera"), for: .normal)
        flipButton.addTarget(self, action: #selector(flip), for: .touchUpInside)
        view.addSubview(flipButton)
        
        takePicBtn.frame = CGRect(x: view.frame.width-55, y:  100 , width: 40, height: 40);
        takePicBtn.setImage(UIImage(named: "ic_menu_camera"), for: .normal)//setTitle("保存", for: .normal)
        takePicBtn.addTarget(self, action:#selector(savePhone) , for: .touchUpInside)
        view.addSubview(takePicBtn)
        
        scopeButton.frame = CGRect(x: (view.frame.width - 55), y: 155, width: 40, height: 40)
        scopeButton.setImage(UIImage(named: "ic_blend_bg"), for: .normal);
        scopeButton.tintColor = .orange;
        scopeButton.alpha = 0.6
        scopeButton.addTarget(self, action: #selector(startIdentify), for: .touchUpInside)
        view.addSubview(scopeButton)
        
        
        // MenuView
        effectView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 180)
        effectView.delegate = self
        view.addSubview(effectView)
        
        // segmentator
        let licPath = Bundle.main.path(forResource: "damo-viapi", ofType: "license")
        let modelPath = Bundle.main.path(forResource: "segvHuman", ofType:"nn")
        segmentator = HuManRealTimeVideoSegmentor()
        segmentator?.checkVideoLicensePath(licPath!, withCallBack: { errorCode in
            print("check证书结果:\(errorCode)")
        })
        self.segmentator?.createVideoSegmentationObject(callBack: { errorCode in
            print("创建对象失败，错误码为\(errorCode)")
        });
        self.segmentator?.initVideoSegmentationModelPath(modelPath!,withCallBack: { errorCode in
            print("初始化对象失败，错误码为\(errorCode)")
        });
        self.segmentator?.getVideoLicenseExpirTime(callBack: {expireString in
            print("视频证书过期时间:\(expireString)")
        })
        
        // Camera
        setupAndBeginCapturingVideoFrames()
        //感知设备方向 - 开启监听设备方向
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
               //添加通知，监听设备方向改变
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedRotation),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        setupAndBeginCapturingVideoFrames()
    }
    override var shouldAutorotate: Bool{
        return true
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        return .all
//    }
    
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }
            self.videoCapture.delegate = self
            
            self.videoCapture.startCapturing()
        }
    }
    
    @objc private func flip() {
        videoCapture.flipCamera { (error) in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }
    
    @objc private func startIdentify() {
        menuShowing = !menuShowing;
        menuView(show: menuShowing)
    }
    @objc private func toucupPreview() {
        if menuShowing == false {
            return
        }
      
        menuView(show: false)
    }
    
    private func menuView(show: Bool) {
        if show {
            menuShowing = true
            UIView.animate(withDuration: 0.25) {
                self.effectView.frame = CGRect(x: 0, y: self.view.frame.height - 180, width: self.view.frame.width, height: 180)
            }
        } else {
            menuShowing = false
            UIView.animate(withDuration: 0.25) {
                self.effectView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 180)
            }
        }
    }
    
    //通知监听触发的方法
    @objc func receivedRotation(){
          // 屏幕方向
          switch UIDevice.current.orientation {
          case UIDeviceOrientation.unknown:
              print("方向未知")
            break
          case .portrait: // Device oriented vertically, home button on the bottom
              print("屏幕直立")
            imageDirection = 1;
            self.bgImageView.transform = CGAffineTransform(rotationAngle: 0);
            self.bgImageView.mas_updateConstraints { (make) in
                make?.width.mas_equalTo()(self.view.frame.size.width);
                make?.height.mas_equalTo()(self.view.frame.size.height);
            }
            break
          case .portraitUpsideDown: // Device oriented vertically, home button on the top
              print("屏幕倒立")
            imageDirection = 2;
            self.bgImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi);
            self.bgImageView.mas_updateConstraints { (make) in
                make?.width.mas_equalTo()(self.view.frame.size.width);
                make?.height.mas_equalTo()(self.view.frame.size.height);
            }
            break
          case .landscapeLeft: // Device oriented horizontally, home button on the right
              print("屏幕左在上方")
            imageDirection = 3;
            self.bgImageView.transform = CGAffineTransform(rotationAngle:  CGFloat.pi/2);
            self.bgImageView.mas_updateConstraints { (make) in
                make?.width.mas_equalTo()(self.view.frame.size.height);
                make?.height.mas_equalTo()(self.view.frame.size.width);
            }
            break
          case .landscapeRight: // Device oriented horizontally, home button on the left
              print("屏幕右在上方")
            imageDirection = 4;
            self.bgImageView.transform = CGAffineTransform(rotationAngle:  CGFloat.pi / 2*3);
            self.bgImageView.mas_updateConstraints { (make) in
                make?.width.mas_equalTo()(self.view.frame.size.height);
                make?.height.mas_equalTo()(self.view.frame.size.width);
            }
            break
          @unknown default: break
          
          }
        
      }
    
    @objc func segAction() {
        dismiss(animated: false) {
            self.segmentator?.destroyVideoSegmentationObject(callBack: { errorCode in
                print("摧毁对象失败,错误码:\(errorCode)")
            })
        };
    }
}

// CaptureDelegate
extension SegmentationViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame sampleBuffer: CMSampleBuffer) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        if self.backgroundImage != nil {
            
            /// B 这里强解包
            let p: Unmanaged<CVPixelBuffer> =    (segmentator?.segmentationVideo(from: pixelBuffer, rotation: getPhoneRotation(), isFront: true, withCallBack: { errorCode in
                print("调用分割能力失败，错误码为:\(errorCode)")
            }))!
            let rp = p.takeRetainedValue() as CVPixelBuffer
            var image: CGImage?
            VTCreateCGImageFromCVPixelBuffer(rp, options: nil, imageOut: &image)
            // 2.显示
            DispatchQueue.main.async {
                if(image == nil){
                    return;
                }
                self.imageView.image = UIImage(cgImage: image!)
            }
        } else {
            var image: CGImage?
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
            // 2.显示
            DispatchQueue.main.async {
                self.imageView.image = UIImage(cgImage: image!)
            }
        }
    }
    
    @objc func savePhone(){
        UIGraphicsBeginImageContextWithOptions(self.bgImageView.frame.size, false, 0)
        
        var bgimage:UIImage?
        var imagep:UIImage?
        if imageDirection == 1 {
           // bgimage = Tool.image(self.bgImageView.image!, rotation: .up)
            imagep = Tool.image(self.imageView.image!, rotation: .up)
        }else if imageDirection == 2{
            //bgimage = Tool.image(self.bgImageView.image!, rotation: .down)
            imagep = Tool.image(self.imageView.image!, rotation: .down)

        } else if imageDirection == 3{
           // bgimage = Tool.image(self.bgImageView.image!, rotation: .rightMirrored)
            imagep = Tool.image(self.imageView.image!, rotation: .left)
        }else {
          //  bgimage = Tool.image(self.bgImageView.image!, rotation: .left)
            imagep = Tool.image(self.imageView.image!, rotation: .right)
        }
        if self.bgImageView.image == nil {
            bgimage = UIImage.init(color: .white, size: CGSize(width: self.view.frame.size.width , height: self.view.frame.size.height))
        }else{
            bgimage = self.bgImageView.image
        }
        UIGraphicsBeginImageContext(bgimage!.size);

        bgimage?.draw(in: CGRect(x: 0, y: 0, width: bgimage!.size.width, height: bgimage!.size.height))
        imagep?.draw(in: CGRect(x: (bgimage!.size.width - imagep!.size.width)/2, y: (bgimage!.size.height - imagep!.size.height)/2, width:  imagep!.size.width, height: imagep!.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image!)
        }, completionHandler: { (isSuccess, error) in
            
            DispatchQueue.main.async {
                if isSuccess {// 成功
                    print("Success")
                    ViProgressHub.showMessage("保存相册成功", in: self.view)
                }
            }
        })
        
        //        return image
        
    }
    
   
    
    
    @objc func getPhoneRotation()->(VISegmentRotation){
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            return VISegmentRotation_0
        case .portraitUpsideDown:
            return VISegmentRotation_180
        case .landscapeLeft:
            return VISegmentRotation_270
        case .landscapeRight:
            return VISegmentRotation_90
        default:
            return VISegmentRotation_0
        }
    }
}
// 选中的背景图
extension SegmentationViewController: DamoPageViewDelegate {
    
    func didSelectDebug() {
        let vc = WriteImageController()
        vc.modalPresentationStyle = .custom
        vc.inputImages = inputImages
        vc.outputImages = outputImages
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didSelectSegItem(item: SegItem?) {
        if item?.isVideo == true {
            palyerView.isHidden = false
            bgImageView.image = nil
            if selectVideoURL == item?.videoUrl {
                return
            }
            if let vUrl = item?.videoUrl {
                selectVideoURL = vUrl
                playVideo(vUrl)
            }
        } else {
            cancelPlay()
            bgImageView.image = item?.image
        }
        backgroundImage = item?.image
        if backgroundImage == nil {
            return
        }
        segmentator?.setBackBufferWithOriginalImg(backgroundImage!, mixBufferW: self.backgroundImage!.size.width, mixBufferH: self.backgroundImage!.size.height, rotation: getPhoneRotation(), isFront: true);
    }
    
    func playVideo(_ url: URL) {
        let item = AVPlayerItem(url: url)
        let avplayer = AVPlayer(playerItem: item)
        player = avplayer;
        let playLayer = AVPlayerLayer(player: player)
        self.playerLayer = playLayer
        playLayer.videoGravity = .resizeAspectFill
        playLayer.frame = bgImageView.bounds
        palyerView.layer.addSublayer(playLayer)
        player?.play()
        
        // AVPlayerItemDidPlayToEndTimeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(repeatPlay), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func cancelPlay() {
        // remove observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        palyerView.isHidden = true
        player?.pause()
        selectVideoURL = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    @objc func repeatPlay() {
        guard let url = selectVideoURL else { return }
        playVideo(url)
    }
}

