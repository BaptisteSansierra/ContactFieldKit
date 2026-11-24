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
                    ContactItem.phone("+12125550112", label: .home),
                    ContactItem.phone("+13105557834", label: .mobile),
                    ContactItem.phone("+14155559021", label: .work),
                    ContactItem.phone("+16175551276", label: .custom("assistant"))
                ],
                emails: [
                    ContactItem.email("alice.johnson@email.com", label: .email),
                    ContactItem.email("alice.home@example.com", label: .home),
                    ContactItem.email("alice.work@company.com", label: .work)
                ],
                urls: [
                    ContactItem.url("alicejohnson.com", label: .homepage),
                    ContactItem.url("intranet.company.com/alice", label: .work)
                ]
            ),

            User(
                name: "Michael Brown",
                phones: [
                    ContactItem.phone("+16465553421", label: .phone),
                    ContactItem.phone("+12025556789", label: .other),
                    ContactItem.phone("+17185559876", label: .school)
                ],
                emails: [
                    ContactItem.email("michael.brown@personal.org", label: .personal),
                    ContactItem.email("mbrown@school.edu", label: .school),
                    ContactItem.email("mike.other@mail.net", label: .other)
                ],
                urls: [
                    ContactItem.url("michaelbrown.blog", label: .url),
                    ContactItem.url("schoolportal.edu/mbrown", label: .school)
                ]
            ),

            User(
                name: "Sophie Martin",
                phones: [
                    ContactItem.phone("+33142223344", label: .mobile)
                ],
                emails: [
                    ContactItem.email("sophie.martin@email.fr", label: .email)
                ],
                urls: [
                ]
            ),

            User(
                name: "David Chen",
                phones: [
                    ContactItem.phone("+8613812345678", label: .home),
                    ContactItem.phone("+8613911122233", label: .other),
                    ContactItem.phone("+8613719988776", label: .school),
                ],
                emails: [
                    ContactItem.email("david.chen@email.cn", label: .email),
                    ContactItem.email("dchen@work.cn", label: .work),
                    ContactItem.email("david.school@university.cn", label: .school)
                ],
                urls: [
                    ContactItem.url("davidchen.cn", label: .homepage),
                    ContactItem.url("lab.university.cn/dchen", label: .school),
                    ContactItem.url("profile.davidchen.cn", label: .other)
                ]
            ),

            User(
                name: "Emma Williams",
                phones: [
                    ContactItem.phone("+447700900123", label: .mobile),
                    ContactItem.phone("+442079460321", label: .phone),
                    ContactItem.phone("+447700900999", label: .work)
                ],
                emails: [
                    ContactItem.email("emma.williams@email.co.uk", label: .email),
                    ContactItem.email("emma@personal.co.uk", label: .personal),
                    ContactItem.email("emma.custom@domain.co.uk", label: .custom("events"))
                ],
                urls: [
                    ContactItem.url("emmawilliams.co.uk", label: .url),
                    ContactItem.url("emma-home.co.uk", label: .home),
                    ContactItem.url("emmawork.co.uk", label: .work)
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
