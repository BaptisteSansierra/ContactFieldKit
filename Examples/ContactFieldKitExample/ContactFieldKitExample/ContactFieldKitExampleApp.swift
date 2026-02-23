//
//  ContactFieldKitExampleApp.swift
//  ContactFieldKitExample
//
//  Created by baptiste sansierra on 17/2/26.
//

import SwiftUI
import ContactFieldKit

@main
struct ContactFieldKitExampleApp: App {
    
    @State private var users: [User]
    
    init() {
        // Create a bunch of users
        users = [
            User(
                name: "Alice Johnson",
                phones: [
                    ContactItem(
                        value: "+12125550112",
                        label: ContactLabel(kind: .phone, label: .home)
                    ),
                    ContactItem(
                        value: "+13105557834",
                        label: ContactLabel(kind: .phone, label: .mobile)
                    ),
                    ContactItem(
                        value: "+14155559021",
                        label: ContactLabel(kind: .phone, label: .work)
                    ),
                    ContactItem(
                        value: "+16175551276",
                        label: ContactLabel(kind: .phone, label: .custom("assistant"))
                    )
                ],
                emails: [
                    ContactItem(
                        value: "alice.johnson@email.com",
                        label: ContactLabel(kind: .email, label: .email)
                    ),
                    ContactItem(
                        value: "alice.home@example.com",
                        label: ContactLabel(kind: .email, label: .home)
                    ),
                    ContactItem(
                        value: "alice.work@company.com",
                        label: ContactLabel(kind: .email, label: .work)
                    )
                ],
                urls: [
                    ContactItem(
                        value: "alicejohnson.com",
                        label: ContactLabel(kind: .url, label: .homepage)
                    ),
                    ContactItem(
                        value: "intranet.company.com/alice",
                        label: ContactLabel(kind: .url, label: .work)
                    )
                ]
            ),

            User(
                name: "Michael Brown",
                phones: [
                    ContactItem(
                        value: "+16465553421",
                        label: ContactLabel(kind: .phone, label: .phone)
                    ),
                    ContactItem(
                        value: "+12025556789",
                        label: ContactLabel(kind: .phone, label: .other)
                    ),
                    ContactItem(
                        value: "+17185559876",
                        label: ContactLabel(kind: .phone, label: .school)
                    )
                ],
                emails: [
                    ContactItem(
                        value: "michael.brown@personal.org",
                        label: ContactLabel(kind: .email, label: .personal)
                    ),
                    ContactItem(
                        value: "mbrown@school.edu",
                        label: ContactLabel(kind: .email, label: .school)
                    ),
                    ContactItem(
                        value: "mike.other@mail.net",
                        label: ContactLabel(kind: .email, label: .other)
                    )
                ],
                urls: [
                    ContactItem(
                        value: "michaelbrown.blog",
                        label: ContactLabel(kind: .url, label: .url)
                    ),
                    ContactItem(
                        value: "schoolportal.edu/mbrown",
                        label: ContactLabel(kind: .url, label: .school)
                    )
                ]
            ),

            User(
                name: "Sophie Martin",
                phones: [
                    ContactItem(
                        value: "+33142223344",
                        label: ContactLabel(kind: .phone, label: .mobile)
                    )/*,
                    ContactItem(
                        value: "+33153334455",
                        label: ContactLabel(kind: .phone, label: .work)
                    ),
                    ContactItem(
                        value: "+33164445566",
                        label: ContactLabel(kind: .phone, label: .custom("studio"))
                    )*/
                ],
                emails: [
                    ContactItem(
                        value: "sophie.martin@email.fr",
                        label: ContactLabel(kind: .email, label: .email)
                    )/*,
                    ContactItem(
                        value: "sophie@home.fr",
                        label: ContactLabel(kind: .email, label: .home)
                    ),
                    ContactItem(
                        value: "contact@sophiemartin.art",
                        label: ContactLabel(kind: .email, label: .custom("gallery"))
                    )*/
                ],
                urls: [/*
                    ContactItem(
                        value: "sophiemartin.art",
                        label: ContactLabel(kind: .url, label: .home)
                    ),
                    ContactItem(
                        value: "portfolio.sophiemartin.art",
                        label: ContactLabel(kind: .url, label: .custom("portfolio"))
                    )*/
                ]
            ),

            User(
                name: "David Chen",
                phones: [
                    ContactItem(
                        value: "+8613812345678",
                        label: ContactLabel(kind: .phone, label: .home)
                    ),
                    ContactItem(
                        value: "+8613911122233",
                        label: ContactLabel(kind: .phone, label: .other)
                    ),
                    ContactItem(
                        value: "+8613719988776",
                        label: ContactLabel(kind: .phone, label: .school)
                    )
                ],
                emails: [
                    ContactItem(
                        value: "david.chen@email.cn",
                        label: ContactLabel(kind: .email, label: .email)
                    ),
                    ContactItem(
                        value: "dchen@work.cn",
                        label: ContactLabel(kind: .email, label: .work)
                    ),
                    ContactItem(
                        value: "david.school@university.cn",
                        label: ContactLabel(kind: .email, label: .school)
                    )
                ],
                urls: [
                    ContactItem(
                        value: "davidchen.cn",
                        label: ContactLabel(kind: .url, label: .homepage)
                    ),
                    ContactItem(
                        value: "lab.university.cn/dchen",
                        label: ContactLabel(kind: .url, label: .school)
                    ),
                    ContactItem(
                        value: "profile.davidchen.cn",
                        label: ContactLabel(kind: .url, label: .other)
                    )
                ]
            ),

            User(
                name: "Emma Williams",
                phones: [
                    ContactItem(
                        value: "+447700900123",
                        label: ContactLabel(kind: .phone, label: .mobile)
                    ),
                    ContactItem(
                        value: "+442079460321",
                        label: ContactLabel(kind: .phone, label: .phone)
                    ),
                    ContactItem(
                        value: "+447700900999",
                        label: ContactLabel(kind: .phone, label: .work)
                    )
                ],
                emails: [
                    ContactItem(
                        value: "emma.williams@email.co.uk",
                        label: ContactLabel(kind: .email, label: .email)
                    ),
                    ContactItem(
                        value: "emma@personal.co.uk",
                        label: ContactLabel(kind: .email, label: .personal)
                    ),
                    ContactItem(
                        value: "emma.custom@domain.co.uk",
                        label: ContactLabel(kind: .email, label: .custom("events"))
                    )
                ],
                urls: [
                    ContactItem(
                        value: "emmawilliams.co.uk",
                        label: ContactLabel(kind: .url, label: .url)
                    ),
                    ContactItem(
                        value: "emma-home.co.uk",
                        label: ContactLabel(kind: .url, label: .home)
                    ),
                    ContactItem(
                        value: "emmawork.co.uk",
                        label: ContactLabel(kind: .url, label: .work)
                    )
                ]
            )
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(users: $users)
        }
    }
    
    
//    var body: some Scene {
//        WindowGroup {
//            MockLabelPickerView()
//        }
//    }
    
}
