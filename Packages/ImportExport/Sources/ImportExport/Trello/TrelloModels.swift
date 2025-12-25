// ImportExport/Sources/ImportExport/Trello/TrelloModels.swift
// Models for decoding Trello JSON exports

import Foundation

/// Root structure of a Trello JSON export
public struct TrelloExport: Codable {
    public let id: String
    public let name: String
    public let desc: String?
    public let closed: Bool?
    public let lists: [TrelloList]
    public let cards: [TrelloCard]
    public let labels: [TrelloLabel]?

    enum CodingKeys: String, CodingKey {
        case id, name, desc, closed, lists, cards, labels
    }
}

/// A Trello list (maps to Column in our domain)
public struct TrelloList: Codable {
    public let id: String
    public let name: String
    public let closed: Bool?
    public let pos: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, closed, pos
    }
}

/// A Trello card
public struct TrelloCard: Codable {
    public let id: String
    public let name: String
    public let desc: String?
    public let idList: String
    public let due: String?
    public let dueComplete: Bool?
    public let labels: [TrelloLabel]?
    public let checklists: [TrelloChecklist]?
    public let pos: Double?
    public let closed: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, desc, idList, due, dueComplete, labels, checklists, pos, closed
    }
}

/// A Trello label
public struct TrelloLabel: Codable {
    public let id: String?
    public let name: String?
    public let color: String?

    enum CodingKeys: String, CodingKey {
        case id, name, color
    }
}

/// A Trello checklist
public struct TrelloChecklist: Codable {
    public let id: String
    public let name: String?
    public let checkItems: [TrelloCheckItem]

    enum CodingKeys: String, CodingKey {
        case id, name, checkItems
    }
}

/// A Trello checklist item
public struct TrelloCheckItem: Codable {
    public let id: String
    public let name: String
    public let state: String
    public let pos: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, state, pos
    }
}
