/// Contains the data necessary to instantiate an item in the virtual forest.
public struct ForestItem: Identifiable {
    /// Unique identifier of this item.
    public var id: String
    /// The x position within the virtual forest.
    public var x: Float
    /// The y position within the virtual forest.
    public var y: Float
    /// The z position within the virtual forest.
    public var z: Float
    /// The name of the item, which should correspond to a resource file to be loaded.
    public var internalName: String
}

/// Represents an item which can be bought with points.
public struct ShopItem {
    /// Item name to be shown to the user.
    public let displayedName: String
    /// Name used to identify the resource corresponding to this item.
    public let internalName: String
    /// Amount of points required for this item.
    public let cost: Double
}
