
import Foundation

public final class ListTypeManager<E> : TypeManager<PersistentVector<E>> where E: Hashable, E: CustomStringConvertible
{
    public typealias T = PersistentVector<E>
    
    private let elementTypeManager: TypeManager<E>
    
    public init(_ elementTypeManager: TypeManager<E>)
    {
        self.elementTypeManager = elementTypeManager
        
        super.init(TypeId.List)
    }
    
    public override func hashValue(value: T) -> Int
    {
        return value.hashValue
    }
    
    public override func equal(lhs: T, rhs: T) -> Bool
    {
        return lhs == rhs
    }
    
    public override func writeToStream(value: T, outputStream: OutputStream) throws
    {
        try Serializer.writeTypeId(value: TypeId.List, outputStream: outputStream)
        
        try Serializer.writeTypeId(value: elementTypeManager.typeId, outputStream: outputStream)
        
        try Serializer.writeSize(size: value.count, outputStream: outputStream)
        
        for element in value
        {
            try elementTypeManager.writeToStream(value: element, outputStream: outputStream)
        }
    }
    
    public override func createFromStream(inputStream: InputStream) throws -> T
    {
        try Serializer.checkTypeId(expectedTypeId: TypeId.List, inputStream: inputStream)
        
        try Serializer.checkTypeId(expectedTypeId: elementTypeManager.typeId, inputStream: inputStream)
        
        let size = try Serializer.readSize(inputStream: inputStream)
        
        var buffer = [E]()
        buffer.reserveCapacity(Int(size))
        
        for _ in 0 ..< size
        {
            buffer.append(try elementTypeManager.createFromStream(inputStream: inputStream))
        }
        
        return PersistentVector<E>(seq: buffer)
    }
}
