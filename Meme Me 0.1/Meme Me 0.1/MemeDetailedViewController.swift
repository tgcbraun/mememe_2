//
//  MemeDetailedViewController.swift
//  Meme Me 0.1
//
//  Created by Thiago Graça Couto Braun on 3/23/15.
//  Copyright (c) 2015 GCBraun. All rights reserved.
//

import UIKit

class MemeDetailedViewController: UIViewController {

    @IBOutlet weak var memeDetailImage: UIImageView!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.memeDetailImage!.image = meme.memedImage
    }

}
