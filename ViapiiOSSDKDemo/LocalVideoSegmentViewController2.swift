//
//  LocalVideoSegmentViewController.swift
//  ViapiiOSSDKDemo
//
//  Created by wclin on 2021/5/19.
//

import Foundation
import VideoToolbox
import AVKit
import MetalKit
import CoreVideo
import Photos
class LocalVideoSegmentViewController2: UIViewController {
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.setupLayout()
    }
    
    //MARK: - Func
    func setupLayout(){
        view.backgroundColor = UIColor.white
        videoView.layoutIfNeeded()
    }
    func setUpUI() {
        closeBtn.mas_makeConstraints { make in
            make?.top.mas_equalTo()(44);
            make?.left.mas_equalTo()(15);
            make?.width.mas_equalTo()(60);
            make?.height.mas_equalTo()(30);
        }
        videoView.mas_makeConstraints { make in
            make?.top.equalTo()(closeBtn.mas_bottom)?.offset()(10);
            make?.left.right().mas_equalTo()(self.view)
            make?.bottom.mas_equalTo()(-self.view.frame.size.height/2)
        }
        
        
    }
    
    //MARK:- handle
    @objc func closeBtnHandle(sender:UIButton){
        dismiss(animated: true) {
            
        }
    }
    @objc func tapClickHandle(tap:UITapGestureRecognizer){
        let imagePickerVc:TZImagePickerController = TZImagePickerController()
        imagePickerVc.allowPickingImage = false
        imagePickerVc.allowPickingVideo = true
        imagePickerVc.allowTakeVideo = false
        imagePickerVc.videoMaximumDuration = 60
        imagePickerVc.modalPresentationStyle = .fullScreen
        self.present(imagePickerVc, animated: true, completion: nil)
        imagePickerVc.didFinishPickingVideoHandle = {(coverImage:UIImage?,asset:PHAsset?)->() in
            guard asset?.mediaType == PHAssetMediaType.video else {
                return
            }
            PHCachingImageManager().requestAVAsset(forVideo: asset!, options: nil) { downAsset, audioMix, info in
                print("63:\(String(describing: downAsset))")
                if downAsset == nil{
                    return
                }
                let realAsset = downAsset as! AVURLAsset
                DispatchQueue.main.async {
                    let player = AVPlayer(url: realAsset.url)
                    let playLayer = AVPlayerLayer(player: player)
                    self.playerLayer = playLayer
                    playLayer.videoGravity = .resizeAspect
                    playLayer.frame = self.videoView.bounds
                    self.videoView.layer.addSublayer(playLayer)
                    player.play()
                }
            }
        }
        
    }
    
    //MARK: - 懒加载
    
    private lazy var videoView:UIView = {
        let videoView = UIView.init()
        videoView.backgroundColor = .cyan
        let tap  = UITapGestureRecognizer.init(target: self, action: #selector(tapClickHandle(tap:)))
        videoView.addGestureRecognizer(tap)
        view.addSubview(videoView)
        return videoView
    }()
    
    private lazy var closeBtn:UIButton = {
        let closeBtn = UIButton.init()
        closeBtn.setTitle("返回", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.backgroundColor = .orange
        closeBtn.clipsToBounds = true;
        closeBtn.layer.cornerRadius = 5;
        closeBtn.addTarget(self, action: #selector(closeBtnHandle), for: .touchUpInside)
        view.addSubview(closeBtn)
        return closeBtn
    }()
}
