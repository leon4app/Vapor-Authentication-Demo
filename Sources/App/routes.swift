import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    let userController = UserController()
    
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
    let guardAuthMiddleware = User.guardAuthMiddleware()
    
    let basicProtected = router.grouped(basicAuthMiddleware, guardAuthMiddleware)
    
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let tokenProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    // 对 users 接口不加密以方便调试
    router.get("users", use: userController.index)
    router.post("login", use: userController.login)
    
    basicProtected.post("addUser", use: userController.create)
    
//    tokenProtected.get("users", use: userController.index)
    tokenProtected.get("profile", use: userController.profile)
    tokenProtected.delete("user", User.parameter, use: userController.delete)
    
    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
