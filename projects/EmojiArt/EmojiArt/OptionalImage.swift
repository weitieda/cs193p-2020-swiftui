//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Tieda Wei on 2020-06-24.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
