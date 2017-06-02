//
//  ViewController.swift
//  ZInfiniteScrollingView
//
//  Created by ZackZheng on 06/02/2017.
//  Copyright (c) 2017 ZackZheng. All rights reserved.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {
    
    static var reuseIdentifier: String { return String(describing: TestCollectionViewCell.self) }

    static var nib: UINib {
        return UINib(nibName: String(describing: TestCollectionViewCell.self), bundle: nil)
    }
}
