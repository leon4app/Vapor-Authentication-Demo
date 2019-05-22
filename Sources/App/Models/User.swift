//
//  User.swift
//  App
//
//  Created by Leon Tse on 2019/5/14.
//

import FluentSQLite
import Vapor
/// A single entry of a User.
final class User: SQLiteModel {
    /// The unique identifier for this `User`.
    var id: Int?
    
    var username: String
    
    var password: String
    
    /// Creates a new `User`.
    init(id: Int? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}

/// Allows `User` to be used as a dynamic migration.
extension User: Migration { }

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
