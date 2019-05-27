//
//  UserController.swift
//  App
//
//  Created by Leon Tse on 2019/5/14.
//
import Crypto
import Random
import Vapor
/// Controls basic CRUD operations on `User`s.
final class UserController {
    /// Returns a list of all `User`s.
    func index(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    /// Saves a decoded `User` to the database.
    func create(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req).toPublic()
        }
    }
    
    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.username, .equal, user.username).first().flatMap { fetchedUser in
                guard let existingUser = fetchedUser else {
                    throw Abort(HTTPStatus.notFound)
                }
                
                let hasher = try req.make(BCryptDigest.self)
                if try hasher.verify(user.password, created: existingUser.password) {
                    return try Token
                        .query(on: req)
                        .filter(\Token.userID, .equal, existingUser.requireID())
                        .delete()
                        .flatMap { _ in
                            let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                            let token = try Token(token: tokenString, userID: existingUser.requireID())
                            return token.save(on: req)
                    }
                } else {
                    throw Abort(HTTPStatus.unauthorized)
                }
            }
        }
    }
    
    /// Get user profile
    func profile(_ req: Request) throws -> Future<String> {
        let user = try req.requireAuthenticated(User.self)
        return req.future("Welcome \(user.username)")
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            return user.delete(on: req)
            }.transform(to: .ok)
    }
}
