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
    @State private var addAccount:Bool = false
    @State private var count:Int = 0
    @State private var codeInt:Int = 345679
    @State private var remainingTime = 30 // Countdown time in seconds
    @State private var timer: Timer? = nil
    
    

    
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
      .overlay(alignment: .bottomTrailing) {
          FloatingButton {
              FloatingAction(symbol: "qrcode") {
                  addAccount.toggle()
              }
          }label: { isExpanded in
              Image(systemName: "plus")
                  .font(.title3)
                  .fontWeight(.semibold)
                  .foregroundStyle(
                    .linearGradient(
                     colors: [.white],
                             startPoint: .top,
                             endPoint: .bottom
                         ))
                  .rotationEffect(.init(degrees: isExpanded ? 45: 0))
                  .scaleEffect(1.02)
                  .frame( maxWidth: .infinity, maxHeight:.infinity)
                  .background(.black, in: .circle)
                //scaling effect when it is expanded
                  .scaleEffect(isExpanded ? 0.9 : 1)
          }.padding()
      }
      .sheet(isPresented: $addAccount, content: {
                            ScannerView()
                                .presentationDetents([.height(800)])
                                .interactiveDismissDisabled()
                                .presentationCornerRadius(30)
                                .presentationBackground(.white)
        
                        })
        
       
    }
    func startTimer() {
         generateNewCodes()
            self.stopTimer() // Stop any existing timer
            self.remainingTime = 30 // Reset the countdown time
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.stopTimer()
                    generateNewCodes()
                    self.startTimer() // Restart the timer
                }
            }
      
        }

        func stopTimer() {
            self.timer?.invalidate()
            self.timer = nil
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
                        .foregroundColor( remainingTime < 10 ? .red : .green)
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
                FlickerClockView(value: .constant(remainingTime / 10), size: CGSize(width: size.width, height: size.height), fontSize: 70, cornerRadius: 10, foreground: .white, background: remainingTime < 10 ? .red.opacity(0.85) : .green.opacity(0.85))
                FlickerClockView(
                    value: .constant(remainingTime % 10 ),
                    size: CGSize(width: size.width, height: size.height),
                    fontSize: 70,
                    cornerRadius: 10,
                    foreground: .white,
                    background: remainingTime < 10 ? .red.opacity(0.85)  : .green.opacity(0.85)
                )
            }
            .onAppear(){
                self.startTimer()
            }
            .onDisappear {
                self.stopTimer()
            }

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
        DispatchQueue.global(qos: .utility).async {
                   let updatedCodes = sampleCodes.map { codeObj in
                       var updatedCode = codeObj
                       if let otp = testOtp(codeObj.code) {
                           updatedCode.otp = otp
                       }
                       return updatedCode
                   }
                   
                   DispatchQueue.main.async {
                       sampleCodes = updatedCodes
                   }
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
