//
//  AccountsList.swift
//  Authenticator
//
//  Created by Billy Okoth on 28/05/2024.
//

import SwiftUI
import AVKit
import SwiftOTP

struct AccountsList: View {
    @State private var timer:CGFloat = 30
    @State private var addAccount:Bool = false
    @State private var count:Int = 0
    @State private var codeInt:Int = 345679
    var body: some View {
      NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders] ,content: {
                    Section {
                        ListView()
                    } header: {
                        HeaderView()
                    }
                }
                )
                .padding(15)
            }
            .background(.gray.opacity(0.15))
            .scrollIndicators(.hidden)
        }
                .overlay(alignment: .bottomTrailing, content: {
                    Button(action: {
                        addAccount.toggle()
                    }, label: {
                       Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.white],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                            .frame(width: 55, height:55)
                            .background(.gray.opacity(0.85).shadow(.drop(color: .black.opacity(0.75), radius: 5, x: 10, y: 10)), in: .circle)
                    })
                    .padding(15)
                })
                .overlay(alignment: .bottomLeading, content: {
                    Button(action: {
                        addAccount.toggle()
                    },
                           label: {
                        
                       Image(systemName: "qrcode")
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.white],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                            .frame(width: 55, height:55)
                            .background(.gray.opacity(0.85).shadow(.drop(color: .black.opacity(0.75), radius: 5, x: 10, y: 10)), in: .circle)
                    })
                    .padding(15)
                })
                
                .sheet(isPresented: $addAccount, content: {
                            ScannerView()
                                .presentationDetents([.height(800)])
                                .interactiveDismissDisabled()
                                .presentationCornerRadius(30)
                                .presentationBackground(.white)
        
                        })
    }
    
    @ViewBuilder
    func ListView () -> some View {
        VStack {
            ForEach(sampleCodes , id:\.id) { code in
                HStack (spacing:0){
                    VStack {
                        Image(systemName: "sun.max.fill")
                            .frame(width: 45, height: 45)
                        Text(code.title)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                .linearGradient(
                                            colors: [.green, .red],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                
                            )
                            
                    }
                    .hSpacing(.leading)
                    .vSpacing(.bottom)
                        
                    Text(String(code.otp))
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                        .textCase(/*@START_MENU_TOKEN@*/.uppercase/*@END_MENU_TOKEN@*/)
                        .kerning(0)
                        .padding([.bottom] ,9)
                        .hSpacing(.leading)
                        .vSpacing(.bottom)
                        .foregroundColor( timer < 10 ? .red : .green)
                }
                .padding([.horizontal , .vertical] ,15)
                .background(.background.opacity(0.75) , in: .rect)
                .cornerRadius(25)
                
            }
        }
        .vSpacing(.center)
        .hSpacing(.center)
    }
    
    @ViewBuilder
    func TimerView (_ size: CGSize) -> some View {
        VStack {
            HStack(spacing:4) {
                FlickerClockView(value: .constant(count / 10), size: CGSize(width: size.width, height: size.height), fontSize: 70, cornerRadius: 10, foreground: .white, background: timer < 10 ? .red.opacity(0.85) : .green.opacity(0.85))
                FlickerClockView(
                    value: .constant(count % 10 ),
                    size: CGSize(width: size.width, height: size.height),
                    fontSize: 70,
                    cornerRadius: 10,
                    foreground: .white,
                    background: timer < 10 ? .red.opacity(0.85)  : .green.opacity(0.85)
                )
            }
            .onAppear(){
                generateNewCodes()
            }
            .onReceive(Timer.publish(every: 0.01, on: .current, in:.common).autoconnect(), perform: { _ in
               
                
                timer -= 0.01
                
                if timer <= 0 {
                    timer = 31
                    generateNewCodes()
                }
                count = Int(timer)
                
            })
           
        }
    }
    
    
    @ViewBuilder
    func HeaderView() -> some View {
        HStack(spacing:0) {
            VStack(alignment: .leading, spacing: 0, content: {
                Text("Accounts!").font(.title.bold())
            })
            Spacer(minLength: 10)
            TimerView(CGSize(width: 50, height:75))
        }
        
        .padding(.bottom ,5)
        .background {
            VStack(spacing:0) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Divider()
            }
                .padding(.horizontal ,-15)
                .padding(.top , -(safeArea.top + 15))
        }
    }
    func headerScale(_ size:CGSize ,proxy:GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        let scrollHeight =  size.height
        
        let progress = minY / scrollHeight
        let scale = (min(max(progress ,0),1)) * 0.3
        return 1 + scale
    }
    func generateNewCodes (){
        sampleCodes = sampleCodes.map { codeObj in
            var updatedCode = codeObj
            if let otp = testOtp(codeObj.code) {
                updatedCode.otp = otp
            }
            return updatedCode
        }
        
        sampleCodes.forEach { code in
            print("Title: \(code.title), OTP: \(code.otp)")
        }


        
    }
    
    func testOtp (_ code:String) -> String? {
        let startDate : Date = Date()
        guard let data = base32DecodeToData(code) else { return nil }
        if let totp = TOTP(secret:data , digits: 6, timeInterval: 30, algorithm: .sha1) {
            let otpString = totp.generate(time: startDate)!
            return otpString
        }
        return nil
    }
    
}

extension View {
    
    var safeArea:UIEdgeInsets {
        if let windowScene = (UIApplication.shared.connectedScenes.first as?   UIWindowScene ){
            return windowScene.keyWindow?.safeAreaInsets ?? .zero
        }
        return .zero
        
    }
}

#Preview {
    AccountsList()
}
