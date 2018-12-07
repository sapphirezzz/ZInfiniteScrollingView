//
//  ZInfiniteScrollingView.swift
//  Pods
//
//  Created by Zack･Zheng on 2017/6/2.
//
//

import UIKit

public protocol ZInfiniteScrollingViewDataSource: class {
    func numberOfItemsInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> Int
    func infiniteScrollingView(_ view: ZInfiniteScrollingView, cellForItemAtIndex index: Int) -> UICollectionViewCell
}

public protocol ZInfiniteScrollingViewDelegate: class {
    func infiniteScrollingView(_ view: ZInfiniteScrollingView, didSelectItemAtIndex index: Int)
    func itemLengthInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat
    func itemSpacingInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat
    func paddingInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat
    func infiniteScrollingViewDidEndDragging(_ view: ZInfiniteScrollingView, contentOffset: CGPoint)
}

public extension ZInfiniteScrollingViewDelegate {
    func infiniteScrollingView(_ view: ZInfiniteScrollingView, didSelectItemAtIndex index: Int) {}
    func infiniteScrollingViewDidEndDragging(_ view: ZInfiniteScrollingView, contentOffset: CGPoint) {}
    func itemLengthInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat {return -1}
    func itemSpacingInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat {return 0}
    func paddingInInfiniteScrollingView(_ view: ZInfiniteScrollingView) -> CGFloat {return 0}
}

open class ZInfiniteScrollingView: UIView {
    
    private static let DefaultScrollDirection = UICollectionView.ScrollDirection.horizontal
    private static let DefaultPagingEnabled = false
    
    open weak var dataSource: ZInfiniteScrollingViewDataSource?
    open weak var delegate: ZInfiniteScrollingViewDelegate?
    
    open var allowInfiniteScrolling: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    open var scrollDirection: UICollectionView.ScrollDirection = DefaultScrollDirection {
        didSet {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = scrollDirection
            collectionView.reloadData()
        }
    }
    
    open var pagingEnabled: Bool = DefaultPagingEnabled {
        didSet {
            collectionView.isPagingEnabled = pagingEnabled
        }
    }
    
    open var scrollEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = scrollEnabled
        }
    }
    
    open var didScrollToIndex: ((Int) -> Void)?
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = DefaultScrollDirection
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.scrollsToTop = false
        return view
    }()
    
    fileprivate var totalRows: Int = 0
    fileprivate var itemLength: CGFloat = 0.0
    fileprivate var itemSpacing: CGFloat = 0.0
    fileprivate var padding: CGFloat = 0.0
    
    fileprivate var unitLength: CGFloat = 0.0
    
    deinit {
        print("\(self) deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.frame = bounds
        resetContentOffsetIfNeeded()
    }
    
    open func addViewOnScrollingView(_ view: UIView) {
        collectionView.addSubview(view)
    }
}

public extension ZInfiniteScrollingView {
    
    func registerClass(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func registerNib(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableCellWithReuseIdentifier(_ identifier: String, forIndex index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: index, section: 0)
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    func scrollToNext(_ animated: Bool = true) {
        
        guard totalRows >= 2 else { return }
        
        var nextIndex: Int {
            if allowInfiniteScrolling {
                return currentIndex + 1
            }else {
                return (currentIndex + 1) % totalRows
            }
        }
        
        let y = CGFloat(nextIndex) * unitLength + itemSpacing + itemLength / 2 - boundLength / 2
        setOffset(y, animated: animated)
    }
    
    func scrollToNextPage(_ animated: Bool = true) {
        
        guard totalRows >= 2 else { return }
        
        var nextIndex: Int {
            if allowInfiniteScrolling {
                return currentPageIndex + 1
            }else {
                return (currentPageIndex + 1) % totalPages
            }
        }
        
        let y = CGFloat(nextIndex) * boundLength
        
        setOffset(y, animated: animated)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension ZInfiniteScrollingView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if totalRows == 1 {
            return 1
        }else {
            return multiple * totalRows
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let index = indexPath.row % totalRows
        return dataSource!.infiniteScrollingView(self, cellForItemAtIndex: index)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        initVars()
        return 1
    }
}

extension ZInfiniteScrollingView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return itemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = indexPath.row % totalRows
        delegate?.infiniteScrollingView(self, didSelectItemAtIndex: index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
}

extension ZInfiniteScrollingView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resetContentOffsetIfNeeded()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let didScrollToIndex = didScrollToIndex else {return}
        didScrollToIndex(currentIndex % totalRows)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        guard let didScrollToIndex = didScrollToIndex else {return}
        didScrollToIndex(currentIndex % totalRows)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            guard let didScrollToIndex = didScrollToIndex else {return}
            didScrollToIndex(currentIndex % totalRows)
        }
        
        delegate?.infiniteScrollingViewDidEndDragging(self, contentOffset: scrollView.contentOffset)
    }
}

private extension ZInfiniteScrollingView {
    
    var currentIndex: Int {
        return Int((offset + boundLength / 2 - itemLength / 2 - itemSpacing) / unitLength)
    }
    
    var currentPageIndex: Int {
        return Int(offset / boundLength)
    }
    
    var totalPages: Int {
        return Int(ceil(scrollLength / boundLength))
    }
}

private extension ZInfiniteScrollingView {
    
    func setup() {
        
        addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        if #available(iOS 9, *) {
            allowInfiniteScrolling = true
        }
    }
    
    func initVars() {
        
        if let rows = dataSource?.numberOfItemsInInfiniteScrollingView(self) {
            totalRows = rows
        }
        
        if let length = delegate?.itemLengthInInfiniteScrollingView(self) {
            itemLength = length
        }else {
            itemLength = collectionView.bounds.width
        }
        
        if let spacing = delegate?.itemSpacingInInfiniteScrollingView(self) {
            itemSpacing = spacing
        }
        
        if let aPadding = delegate?.paddingInInfiniteScrollingView(self), aPadding > 0 {
            padding = aPadding
        }
        
        unitLength = itemLength + itemSpacing
    }
    
    var multiple: Int {
        
        if allowInfiniteScrolling {
            let ratio = Int(ceil(boundLength/unitLength))
            return ratio * 3
        }else {
            return 1
        }
    }
    
    var itemSize: CGSize {
        
        if scrollDirection == .horizontal {
            let height = collectionView.bounds.height - 2 * padding
            return CGSize(width: itemLength, height: height)
        }else {
            let width = collectionView.bounds.width - 2 * padding
            return CGSize(width: width, height: itemLength)
        }
    }
    
    var insets: UIEdgeInsets {
        
        if scrollDirection == .horizontal {
            return UIEdgeInsets(top: padding, left: itemSpacing, bottom: padding, right: itemSpacing)
        }else {
            return UIEdgeInsets(top: itemSpacing, left: padding, bottom: itemSpacing, right: padding)
        }
    }
    
    
    var scrollLength: CGFloat {
        
        if scrollDirection == .horizontal {
            return collectionView.contentSize.width
        }else {
            return collectionView.contentSize.height
        }
    }
    
    var boundLength: CGFloat {
        
        if scrollDirection == .horizontal {
            return collectionView.bounds.size.width
        }else {
            return collectionView.bounds.size.height
        }
    }
    
    var offset: CGFloat {
        
        get {
            if scrollDirection == .horizontal {
                return collectionView.contentOffset.x
            } else {
                return collectionView.contentOffset.y
            }
        }
        set {
            if scrollDirection == .horizontal {
                collectionView.contentOffset.x = newValue
            } else {
                collectionView.contentOffset.y = newValue
            }
        }
    }
    
    func setOffset(_ offset: CGFloat, animated: Bool) {
        
        var contentOffset = collectionView.contentOffset
        if scrollDirection == .horizontal {
            contentOffset.x = offset
        } else {
            contentOffset.y = offset
        }
        collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    func resetContentOffsetIfNeeded() {
        
        guard allowInfiniteScrolling else {
            return
        }
        
        guard totalRows >= 2 else {
            return
        }
        
        let topThreshold: CGFloat = 0
        let bottomThreshold: CGFloat = scrollLength - boundLength
        
        guard bottomThreshold > topThreshold else {
            return
        }
        
        var y = offset

        if y < topThreshold {
            y += unitLength * CGFloat(totalRows) * CGFloat(multiple/2)
            offset = y
        }else if y > bottomThreshold {
            y -= unitLength * CGFloat(totalRows) * CGFloat(multiple/2)
            offset = y
        }
    }
}

extension String: Error {}
