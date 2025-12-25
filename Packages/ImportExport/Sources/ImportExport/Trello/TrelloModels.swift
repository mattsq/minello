// ImportExport/Sources/ImportExport/Trello/TrelloModels.swift
// Models for decoding Trello JSON exports

import Foundation

/// Root structure of a Trello JSON export
public struct TrelloExport: Codable {
    let id: String
    let name: String
    let desc: String?
    let closed: Bool?
    let lists: [TrelloList]
    let cards: [TrelloCard]
    let labels: [TrelloLabel]?

    enum CodingKeys: String, CodingKey {
        case id, name, desc, closed, lists, cards, labels
    }
}

/// A Trello list (maps to Column in our domain)
public struct TrelloList: Codable {
    let id: String
    let name: String
    let closed: Bool?
    let pos: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, closed, pos
    }
}

/// A Trello card
public struct TrelloCard: Codable {
    let id: String
    let name: String
    let desc: String?
    let idList: String
    let due: String?
    let dueComplete: Bool?
    let labels: [TrelloLabel]?
    let checklists: [TrelloChecklist]?
    let pos: Double?
    let closed: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, desc, idList, due, dueComplete, labels, checklists, pos, closed
    }
}

/// A Trello label
public struct TrelloLabel: Codable {
    let id: String?
    let name: String?
    let color: String?

    enum CodingKeys: String, CodingKey {
        case id, name, color
    }
}

/// A Trello checklist
public struct TrelloChecklist: Codable {
    let id: String
    let name: String?
    let checkItems: [TrelloCheckItem]

    enum CodingKeys: String, CodingKey {
        case id, name, checkItems
    }
}

/// A Trello checklist item
public struct TrelloCheckItem: Codable {
    let id: String
    let name: String
    let state: String
    let pos: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, state, pos
    }
}
