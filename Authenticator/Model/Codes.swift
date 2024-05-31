//
//  Codes.swift
//  Authenticator
//
//  Created by Billy Okoth on 30/05/2024.
//

import Foundation

struct Code :Identifiable {
    let id:UUID = .init()
    var code:String
    var title:String
    var otp:String
}


var sampleCodes:[Code] = [
    .init(code: "6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ", title: "Github", otp: ""),
    .init(code: "6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ", title: "Azure", otp: ""),
    .init(code: "6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ", title: "Google",  otp: ""),
    .init(code: "6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ", title: "Deel",  otp: ""),
    .init(code: "6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ", title: "Microsoft" , otp: ""),
    .init(code: "6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ", title: "Yahoo" , otp: ""),
    .init(code: "6QFLXTTN5XWPWBKIAFBO6AUTK7PVNSRZ", title: "Apple" , otp: "")
]
