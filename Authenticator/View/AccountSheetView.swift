//
//  AccountSheetView.swift
//  Authenticator
//
//  Created by Billy Okoth on 28/05/2024.
//

import SwiftUI


struct AccountSheetView: View {
    //VIEW PROPERTIES
    @Environment(\.dismiss) private var dismiss
    @State private var displayScanner:Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .tint(.gray)
            })
            .hSpacing(.leading)
            Spacer(minLength: 0)
            Button(action: {
                displayScanner.toggle()
                print("toggle camera")
            }, label: {
                HStack(spacing: 20) {
                    Text("Scan Qr Code")
                     Image(systemName: "qrcode")
                }.font(.title3)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical ,12)
                    .background(.gray.opacity(0.15) , in: .rect(cornerRadius: 10))
                    
            })
            Button(action: {}, label: {
                HStack (spacing:20 ) {
                    Text("Add Code")
                    Image(systemName: "plus")
                }.font(.title3)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical ,12)
                    .background(.gray.opacity(0.15) , in: .rect(cornerRadius: 10))
                    
            })
            
        })
        .sheet(isPresented: $displayScanner,onDismiss: onDissMiss, content: {
            ScannerView().background(.thinMaterial)
        } )
        .padding(15)
        
        
    }
    
    func onDissMiss () {
      
    }
}

#Preview {
    AccountSheetView()
}
