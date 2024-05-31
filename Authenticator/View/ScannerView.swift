//
//  ScannerView.swift
//  Authenticator
//
//  Created by Billy Okoth on 28/05/2024.
//

import SwiftUI
import AVKit
import SwiftOTP

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    //QR CODE scanner properties
    @State private var isScanning:Bool = false
    @State private var session:AVCaptureSession = .init()
    @State private var cameraPermission:Permissions = .idle
    //CAMERA OUTPUT
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    
    //Scanned Code
    @State private var scannedCode:String = ""
    
    //error properties
    @State private var errorMessage:String = ""
    @State private var showError:Bool = false
    @Environment (\.openURL) private var openURL
    
    //QR CODE OUTPUT DELEGATE
    @StateObject private var qrDelegate = QRScannerDelegate()
    
    
    var body: some View {
        VStack(spacing:8) {
            Button(action: {
                dismiss()
            } , label: {
               Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            ).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/ , alignment: .leading)
            Text("Place the Qr Code inside the area")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top ,20)
            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            Spacer(minLength: 0)
            ///Qr code scannes
            
            GeometryReader {
                let size = $0.size
                
                ZStack {
                    CameraView(frameSize: CGSize(width: size.width, height: size.width), session: $session)
                        .scaleEffect(0.97)
                    ForEach(0...4 ,id: \.self) { index in
                        let rotation = Double(index) * 90
                        RoundedRectangle(cornerRadius: 2 , style: .circular)
                          //trim to get the edges
                            .trim(from: 0.61 , to: 0.65)
                            .stroke(.blue ,style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .rotationEffect(.degrees(rotation))
                        
                        
                    }
                }
                //square shape
                .frame(width: size.width, height: size.width)
                //Scanner Animation
                .overlay(alignment:.top , content:  {
                    Rectangle()
                        .fill(.blue)
                        .frame(height:2.5)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.8), radius: 8, x: 0, y: isScanning ? 15 : -15)
                        .offset(y: isScanning ? size.width : 0)
                })
                
                //make it center
                .frame(maxWidth: .infinity , maxHeight: .infinity)
            }
            .padding(.horizontal ,45)
            
            Button {
                if !session.isRunning && cameraPermission == .approved {
                    reactivateCamera()
                    activateScannneraActivation()
                }
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            Spacer(minLength: 45)
        }
        .padding(15)
        ///Check for camera permissions when the view is visibl
        .onAppear(perform:checkCameraPermission)
        .alert(errorMessage ,isPresented: $showError) {
            //show the settings button if the permission is denied
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingString = UIApplication.openSettingsURLString
                    if let settingsUrl = URL(string: settingString) {
                       openURL(settingsUrl)
                    }
                }
                
                //Along with cancel button
                Button("Cancel", role: .cancel){}
            }
        }
        .onChange(of: qrDelegate.scannedCode){ _ ,newValue in
            if let code = newValue {
                scannedCode = code
                //ONCE THE CODE IS FOUND WE PUSH IT TO SWIFTDATA AND DISPLAY IT ON A LIST
                //When the first code is available stop scanning
                session.stopRunning()
                //stop the animation
                deActivateScannneraActivation()
                
                
                //Clearing the data on Delegarte
                qrDelegate.scannedCode = nil
            }
        }
        
    }
    
    //Setting up the camera
    func setupCamera(){
        do {
            // Find the back camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first else {
               // TEST THE CAMERA QRCODE ON A REAL DEVEICE !!!
                presentError("UNKNOWN DEVICE ERROR !")
                return
            }
            
            //Camera Input
            let input = try AVCaptureDeviceInput(device: device)
            ///For extra safety
            ///Checking whether the input and output can be added to the session
            guard session.canAddInput(input) ,session.canAddOutput(qrOutput) else {
                presentError("UNKNOWN INPUT /OUTPUT ERROR")
                return
            }
            
            //Adding input & output to Camera Sessino
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            //Setting Output config to read QR CODE
            qrOutput.metadataObjectTypes = [.qr]
            
            // add delegate to retrieve the fetched QR CODE from the camera
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            //Note session must be started on the background thread
            DispatchQueue.global(qos: .background).async{
                session.startRunning()
            }
            activateScannneraActivation()
            
        }
        catch {
            presentError(error.localizedDescription)
        }
    }
    
    //Reactivate scanner
    func reactivateCamera(){
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    //acativating the scanner method
    func activateScannneraActivation() {
            withAnimation(.easeInOut(duration: 0.85).delay(0.2).repeatForever(autoreverses: true)) {
                isScanning = true
            }
    }
    func deActivateScannneraActivation() {
            withAnimation(.easeInOut(duration: 0.85)) {
                isScanning = false
            }
    }
    func testOtp (){
        let startDate : Date = Date()
        guard let data = base32DecodeToData("6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ") else { return }
        if let totp = TOTP(secret:data , digits: 6, timeInterval: 30, algorithm: .sha1) {
            let otpString = totp.generate(time: startDate)!
            print(otpString)
        }
    }
    //check for the camera permission
    func checkCameraPermission(){
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty {
                    //new setup
                    setupCamera()
                } else {
                    //Already exsisting one
                    session.startRunning()
                }
                
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    //permission granted
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    cameraPermission = .denied
                    // presenting the error message
                    presentError("Please provide Access to Camera for Scanning codes")
                    
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please provide Access to Camera for Scanning codes")
            default:break
            }
        }
    }
    func presentError( _ message:String) {
        errorMessage = message
        showError.toggle()
    }
}

#Preview {
    ScannerView()
}

//RoundedRectangle(cornerRadius: 2 , style: .circular)
//  //trim to get the edges
//    .trim(from: 0.61 , to: 0.65)
//    .stroke(.blue ,style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
//
//RoundedRectangle(cornerRadius: 2 , style: .circular)
//  //trim to get the edges
//    .trim(from: 0.61 , to: 0.65)
//    .stroke(.blue ,style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
//    .rotationEffect(.init(degrees: 90))
//RoundedRectangle(cornerRadius: 2 , style: .circular)
//  //trim to get the edges
//    .trim(from: 0.61 , to: 0.65)
//    .stroke(.blue ,style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
//    .rotationEffect(.init(degrees: 180))
//RoundedRectangle(cornerRadius: 2 , style: .circular)
//  //trim to get the edges
//    .trim(from: 0.61 , to: 0.65)
//    .stroke(.blue ,style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
//    .rotationEffect(.init(degrees: 270))
