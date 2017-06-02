//
//  ViewController.swift
//  ZInfiniteScrollingView
//
//  Created by ZackZheng on 06/02/2017.
//  Copyright (c) 2017 ZackZheng. All rights reserved.
//

import UIKit
import ZInfiniteScrollingView

class ViewController: UIViewController {

    @IBOutlet weak var testView: ZInfiniteScrollingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        testView.dataSource = self
        testView.delegate = self
//        testView.allowInfiniteScrolling = false
        
        testView.didScrollToIndex = {index in
            print("didScrollToIndex = \(index)")
        }
        
        testView.scrollEnabled = false

        testView.registerClass(TestCollectionViewCell.self, forCellWithReuseIdentifier: TestCollectionViewCell.reuseIdentifier)
//        testView.scrollDirection = .Vertical
        testView.pagingEnabled = true
    }

    @IBAction func clickButton(sender: AnyObject) {
        
//        if testView.scrollDirection == .Vertical {
//            testView.scrollDirection = .Horizontal
//        }else {
//            testView.scrollDirection = .Vertical
//        }
//        if testView.allowInfiniteScrolling == true {
//            testView.allowInfiniteScrolling = false
//        }else {
//            testView.allowInfiniteScrolling = true
//        }
        _ = testView.scrollToNextPage(true)
    }
}

extension ViewController: ZInfiniteScrollingViewDataSource {
    
    func numberOfItemsInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> Int {
        return 3
    }
    
    func infiniteScrollingView(_ view: ZInfiniteScrollingView, cellForItemAtIndex index: Int) -> UICollectionViewCell {
        
        let cell = view.dequeueReusableCellWithReuseIdentifier(TestCollectionViewCell.reuseIdentifier, forIndex: index) as! TestCollectionViewCell
        if index == 0 {
            cell.backgroundColor = UIColor.red
        }else if index == 1 {
            cell.backgroundColor = UIColor.green
        }else {
            cell.backgroundColor = UIColor.blue
        }
        return cell
    }
}

extension ViewController: ZInfiniteScrollingViewDelegate {

    func infiniteScrollingViewDidEndDragging(_ view: ZInfiniteScrollingView, contentOffset: CGPoint) {
        print("infiniteScrollingViewDidEndDragging: \(contentOffset)")
    }

    func infiniteScrollingView(_ view: ZInfiniteScrollingView, didSelectItemAtIndex: Int) {
        print("didSelectItemAtIndex: \(didSelectItemAtIndex)")
    }
    
    func itemLengthInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat {
        return 280
    }
    
    func itemSpacingInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat {
        return 20
    }
    
    func paddingInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat {
        return 10
    }
}
