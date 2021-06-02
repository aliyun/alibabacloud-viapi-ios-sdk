//
//  DamoPageView.swift
//  DaMoLab
//
//  Created by 薛林 on 2020/10/10.
//  Copyright © 2020 AlibabaGroup. All rights reserved.
//

import UIKit

protocol DamoPageViewDelegate: AnyObject {
    func didSelectSegItem(item: SegItem?)
    func didSelectDebug()
}
// 底部图片小组件
class SegItem: NSObject {
    var isVideo = false
    var image: UIImage?
    var videoUrl: URL?
}


class DamoPageView: UIVisualEffectView {

    private var collectionView: UICollectionView!
    var selectIndexPath: IndexPath?
    public var segItems: [SegItem]?
    public var videoUrls: [URL]?
    
    weak var delegate: DamoPageViewDelegate?
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setupTitleView()
//        setupPageView()
        setupCollectionView()
        
        // prepare data
        var imgs = [SegItem]()
        // 默认图
        let item = SegItem()
        item.image = UIImage()
        imgs.append(item)
        
        for i in (2 ..< 12) {
            guard let image = UIImage(named: String(i))  else { return }
            let t = SegItem()
            t.image = image
            imgs.append(t)
        }
        // 获取视频文件的封面图
        DispatchQueue.global().async {
            let videoNames = ["a", "b", "c", "d"]
            var mVideos = [URL]()
            for name in videoNames {
                if let url = Bundle.main.url(forResource: name, withExtension: "mp4") {
                    mVideos.append(url)
                    guard let coverImg = VideoFrameGenerator.videoFirstFrame(url: url) else {
                        continue
                    }
                    let t = SegItem()
                    t.isVideo = true
                    t.image = coverImg
                    t.videoUrl = url
                    imgs.append(t)
                }
            }
            self.videoUrls = mVideos
            DispatchQueue.main.async {
                self.segItems = imgs
                self.collectionView.reloadData()
            }
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitleView() {
        let sep = UIButton(frame: CGRect(x: 5, y: 8, width: 50, height: 30))
        sep.setTitle("分割", for: .normal)
        sep.setTitleColor(.white, for: .normal)
        sep.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        sep.addTarget(self, action: #selector(debugAction), for: .touchUpInside)
        sep.setTitleColor(.orange, for: .highlighted)
        sep.backgroundColor = .systemBlue
        sep.layer.cornerRadius = 5
        sep.layer.masksToBounds = true
        contentView.addSubview(sep)
        
//        let other = UIButton(frame: CGRect(x: sep.frame.maxX + 5, y: 8, width: 50, height: 30))
//        other.setTitle("分割", for: .normal)
//        other.setTitleColor(.lightGray, for: .normal)
//        other.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//        other.addTarget(self, action: #selector(speAction), for: .touchUpInside)
//        contentView.addSubview(other)
    }
    
//    private func setupPageView() {
//        let scrollview = UIScrollView(frame: CGRect(x: 0, y: 8 + 30, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 38))
//        scrollview.tag = 10
//        scrollview.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 38)
//        scrollview.isPagingEnabled = true
//        contentView.addSubview(scrollview)
//
//        for var i in 0...1 {
//            let v = UIView(frame: CGRect(x: CGFloat(i) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//            scrollview.addSubview(v)
//            i += 1
//        }
//    }
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect(x: 15, y: 8 + 30, width: self.frame.width, height: 80)
    }
    @objc private func speAction() {
       
    }
    @objc private func debugAction() {
        if delegate != nil {
            delegate?.didSelectDebug()
        }
    }
    
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        
        let colleView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        colleView.delegate = self
        colleView.dataSource = self
        colleView.showsHorizontalScrollIndicator = false
        colleView.contentInset = UIEdgeInsets(top: 0, left: 32 / 375 * UIScreen.main.bounds.width, bottom: 0, right: 32 / 375 * UIScreen.main.bounds.width)
        colleView.register(SpeCell.self, forCellWithReuseIdentifier: SpeCell.reuseId)
        colleView.backgroundColor = .clear
        collectionView = colleView
        contentView.addSubview(collectionView)
    }
}


extension DamoPageView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let count = self.segItems?.count else {
            return 0
        }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpeCell.reuseId, for: indexPath)
        guard let gcell = cell as? SpeCell else { return cell }
        gcell.layer.cornerRadius = 4.0
        
        if indexPath.row == 0 && selectIndexPath == nil {
            selectIndexPath = indexPath
        }
        
        gcell.transform = .identity
        gcell.layer.borderWidth = 0.0
        gcell.layer.borderColor = UIColor.clear.cgColor
        
        if indexPath.row == 0 && selectIndexPath?.row != 0 {
            gcell.layer.borderWidth = 4.0
            gcell.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        if selectIndexPath == indexPath {
            gcell.transform = CGAffineTransform(scaleX: 1.14, y: 1.14)
            gcell.layer.borderWidth = 4.0
            gcell.layer.borderColor = UIColor.white.cgColor
        }
        
        guard let imgs = self.segItems else { return gcell }
        let item = imgs[indexPath.row]
        gcell.playView.isHidden = item.isVideo == false
        gcell.imageView.image = item.image
        gcell.tipLabel.isHidden = indexPath.row != 0
        return gcell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        if selectIndexPath == indexPath {
            return
        }
        guard let imgs = self.segItems else {
            return
        }
        let item = imgs[indexPath.row]
        print("video url : \(String(describing: item.videoUrl?.path))")
        updateState(atIndex: indexPath, item: item)
    }
    /// 更新状态
    /// - Parameter indexPath: 当前选中的IndexPath
    private func updateState(atIndex indexPath: IndexPath, item: SegItem) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.25) {
            cell?.transform = CGAffineTransform(scaleX: 1.14, y: 1.14)
        }
        cell?.layer.borderWidth = 4.0
        cell?.layer.borderColor = UIColor.white.cgColor
        selectIndexPath = indexPath
        collectionView.reloadData()
        
        if delegate != nil {
            if selectIndexPath?.row == 0 {
                item.image = nil
            }
            delegate?.didSelectSegItem(item: item)
        }
    }
}


class SpeCell: UICollectionViewCell {
    class var reuseId: String {
        return "SpeCell"
    }
    
    var imageView: UIImageView = UIImageView()
    var tipLabel: UILabel = UILabel()
    var playView: UIImageView = UIImageView(image: UIImage(named: "damo_play"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.white
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4.0
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        tipLabel.font = .systemFont(ofSize: 10)
        tipLabel.textColor = UIColor.lightGray
        imageView.addSubview(tipLabel)
        tipLabel.isHidden = true
        tipLabel.text = "无背景"
        tipLabel.alpha = 0.7
        tipLabel.sizeToFit()
        tipLabel.center = self.contentView.center
        playView.sizeToFit()
        playView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        playView.center = contentView.center
        playView.isHidden = true
        contentView.addSubview(playView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
