//
//
//  Copyright © 2017 Kenan Atmaca. All rights reserved.
//  kenanatmaca.com
//
//

import UIKit

@available(iOS 11.0, *)

class mainVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addInteraction(UIDropInteraction(delegate: self))
        view.addInteraction(UIDragInteraction(delegate: self))
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}//

@available(iOS 11.0 , *)
extension mainVC: UIDropInteractionDelegate{ // DROP
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (item, error) in
                
                if error != nil {
                    return
                }
                
                guard let img:UIImage = item as? UIImage else {
                    return
                }
                
                DispatchQueue.main.async {
                    let dragPoint = session.location(in: self.view)
                    let imgView = UIImageView()
                    imgView.isUserInteractionEnabled = true
                    imgView.image = img
                    imgView.frame.size = CGSize.init(width: img.size.width, height: img.size.height)
                    imgView.center = dragPoint
                    self.view.addSubview(imgView)
                }
            })
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
       return session.canLoadObjects(ofClass: UIImage.self)
    }
}
@available(iOS 11.0 , *)
extension mainVC: UIDragInteractionDelegate { // DRAG
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let touchPoint = session.location(in: self.view)
        
        if let touchImageView = self.view.hitTest(touchPoint, with: nil) as? UIImageView {
            let touchImage = touchImageView.image
            let itemProv = NSItemProvider(object: touchImage!)
            let dragItem = UIDragItem(itemProvider: itemProv)
            dragItem.localObject = touchImageView
            return [dragItem]
        }
        
        return []
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        return UITargetedDragPreview(view: (item.localObject as? UIView)!)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        
        session.items.forEach { (item) in
            if let tImageView = item.localObject as? UIView {
                tImageView.removeFromSuperview()
            }
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        self.view.addSubview(item.localObject as! UIView)
    }
}
