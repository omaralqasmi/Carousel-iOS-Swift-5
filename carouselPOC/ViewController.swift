//
//  ViewController.swift
//  carouselPOC
//
//  Created by Omar AlQasmi on 5/13/20.
//  Copyright © 2020 testting.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UICollectionViewDelegate {

    @IBOutlet weak var carousel: UICollectionView!
    //UIcollectionView Declare datasource and design/flow
    let collectionDataSource = CollectionDataSource()
    let flowLayout = ZoomAndSnapFlowLayout()
    
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        carousel.delegate = self
        carousel.allowsMultipleSelection = true
        carousel.dataSource = collectionDataSource
        carousel.collectionViewLayout = flowLayout
        carousel.contentInsetAdjustmentBehavior = .always
        //Select the third cell by default
        carousel.performBatchUpdates(nil) { (isLoded) in
            if isLoded{
                self.carousel.scrollToItem(at:IndexPath(item: 2, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    // MARK:- Get selected cell index
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        carousel.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        workWithSelectedCell(indexPath.row)
    }
    // MARK:- Get cell index on scroll
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = carousel.contentOffset
        visibleRect.size = carousel.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = carousel.indexPathForItem(at: visiblePoint) else { return }
        
        workWithSelectedCell(indexPath.row)
    }
    // MARK:- Work with selected cell
    func workWithSelectedCell (_ index : Int){
        print("Selected = \(index)")
        print(collectionDataSource.items[index])
    }
}

// MARK:- Collection Design and flow Class
class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {

    let activeDistance: CGFloat = 130
    let zoomFactor: CGFloat = 0.7

    override init() {
        super.init()

        scrollDirection = .horizontal
        minimumLineSpacing = 15
        itemSize = CGSize(width: 60, height: 60)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)

        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

        // Make the cells be zoomed when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance

            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}
//MARK:- Data Source Class
class CollectionDataSource: NSObject, UICollectionViewDataSource {
    var items = ["zero","one","two","three","four","five","six","seven","8","9","10","11","12","13","14","15","16","17","18"]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carCell", for: indexPath) as! MyCollectionViewCell
        cell.lblTitle.text = items[indexPath.row]
        return cell
    }

}
