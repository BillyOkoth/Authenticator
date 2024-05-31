//
//  View+Extensions.swift
//  Authenticator
//
//  Created by Billy Okoth on 28/05/2024.
//

import SwiftUI

extension View {
    //custom spacers

@ViewBuilder
func hSpacing(_ alignment :Alignment) -> some View {
    self.frame( maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  alignment: alignment)
}

@ViewBuilder
func vSpacing(_ alignment :Alignment) -> some View {
    self.frame( maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  alignment: alignment)
}
    
}
