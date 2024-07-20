import Foundation
import SwiftUI

class CameraViewController: UIViewController {
    var onViewDidLoad: (UIView) -> Void = { _ in return }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad(self.view)
    }
    
    func onViewDidLoad(perform: @escaping (UIView) -> Void) -> Self {
        onViewDidLoad = perform
        return self
    }
}
