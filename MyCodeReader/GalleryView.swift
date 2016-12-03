//
//  GalleryView.swift
//  MyCodeReader
//
//  Created by Akshay Bharath on 12/3/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit

protocol GalleryViewDelegate {
    func dissmissGalleryView()
}

class GalleryView: UIView {
    
    var gallery: UICollectionView!
    var galleryImages: [UIImage]!
    var delegate: GalleryViewDelegate!
    
    init(frame: CGRect, delegate: GalleryViewDelegate, images: [UIImage]) {
        super.init(frame: frame)
        
        self.delegate = delegate
        galleryImages = images

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: 100, height: 100)
        gallery = UICollectionView(frame: frame, collectionViewLayout: layout)
        gallery.dataSource = self
        gallery.delegate = self
        gallery.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        gallery.backgroundColor = UIColor.asbestos()
        addSubview(gallery)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GalleryView.handleTap(gestureRecognizer:)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        delegate.dissmissGalleryView()
    }
}

extension GalleryView: UICollectionViewDelegate {
}

extension GalleryView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundView = UIImageView(image: galleryImages[indexPath.row])
        return cell
    }
}
