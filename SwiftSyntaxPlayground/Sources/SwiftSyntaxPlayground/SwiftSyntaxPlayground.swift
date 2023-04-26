import SwiftSyntax

public struct SwiftSyntaxPlayground {
    let structKeyword = TokenSyntax.structKeyword(trailingTrivia: .spaces(3))
    let identifier = TokenSyntax.identifier("Example", trailingTrivia: .spaces(1))
    let leftBrace = TokenSyntax.leftBraceToken(trailingTrivia: .spaces(1))
    let rightBrace = TokenSyntax.rightBraceToken(leadingTrivia: .newlines(1))
    
    init() {
        let x = MemberDeclListSyntax([])
        var members = MemberDeclBlockSyntax(members: x)
            .withLeftBrace(leftBrace)
            .withRightBrace(rightBrace)

        let structureDeclaration = StructDeclSyntax(identifier: identifier, members: members)
        print(structureDeclaration)
    }
    func result() {
    }
}
