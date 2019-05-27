//
//  Token.swift
//  App
//
//  Created by Leon Tse on 2019/5/23.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

final class Token: SQLiteModel {
    var id: Int?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token: Migration {}
extension Token: Content {}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: Authentication.Token {
    typealias UserType = User
    
    static var userIDKey: UserIDKey{
        return \Token.userID
    }
    
    static var tokenKey: TokenKey {
        return \Token.token
    }
}
