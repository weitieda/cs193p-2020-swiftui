//
//  Array+Identifiable.swift
//  Memorize
//
//  Created by Tieda Wei on 2020-05-31.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}
