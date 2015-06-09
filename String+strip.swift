//
//  String+strip.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

extension String {
    func stripCharactersInSet(chars: [Character]) -> String {
        return String(filter(self) {find(chars, $0) == nil})
    }
}


