//
//  UserController.swift
//  App
//
//  Created by Leon Tse on 2019/5/14.
//
import Crypto
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
    
    func verify(_ req: Request) throws -> Future<String> {
        return try req.content.decode(User.self).flatMap { us in
            us.password = try BCrypt.hash(us.password)
            return User.query(on: req).filter(\.username, .equal, us.username).all().flatMap { (users) -> EventLoopFuture<String> in
                let result = req.eventLoop.newPromise(String.self)
                if users.isEmpty {
                    result.succeed(result: "用户不存在")
                    return result.futureResult
                } else {
                    let user = users.first!
                    if user.password == us.password {
                        result.succeed(result: "登陆成功")
                    } else {
                        result.succeed(result: "账号或密码错误")
                    }
                    return result.futureResult
                }
            }
        }
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            return user.delete(on: req)
            }.transform(to: .ok)
    }
}
