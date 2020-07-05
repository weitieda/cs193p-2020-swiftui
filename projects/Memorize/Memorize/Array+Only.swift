//
//  Array+Only.swift
//  Memorize
//
//  Created by Tieda Wei on 2020-05-31.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
