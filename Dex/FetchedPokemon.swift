//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Amila Wijayarathna on 2025-05-06.
//

import Foundation

struct FetchedPokemon : Decodable {
    var id: Int16
    var name: String
    var types: [String]
    var hp: Int16
    var attack: Int16
    var defense: Int16
    var specialAttack: Int16
    var specialDefence: Int16
    var speed: Int16
    var shinyURL: URL
    var spriteURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys:CodingKey{
            case type
            
            enum TypeKeys : CodingKey{
                case name
            }
        }
        
        enum StatDictionaryKeys:CodingKey{
            case baseStat
        }
        
        enum SpriteKeys:String,CodingKey{
            case spriteURL = "frontDefault"
            case shinyURL = "frontShiny"
            
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        var decodeTypes : [String] = []
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        
        while !typesContainer.isAtEnd{
            
            var typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            var typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self,forKey: .type)
            
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodeTypes.append(type)
            
        }
        
        if decodeTypes.count == 2 && decodeTypes[0] == "normal"{
//            decodeTypes[0] = decodeTypes[1]
//            decodeTypes[1] = "normal"
            decodeTypes.swapAt(1, 0)
        }
        
        self.types = decodeTypes
        
        var decodedStats : [Int16] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        
        while !statsContainer.isAtEnd{
            
            var statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatDictionaryKeys.self)
 
            let stat = try statsDictionaryContainer.decode(Int16.self, forKey: .baseStat)
            decodedStats.append(stat)
            
        }
        
        self.hp = decodedStats[0]
        self.attack = decodedStats[1]
        self.defense = decodedStats[2]
        self.specialAttack = decodedStats[3]
        self.specialDefence = decodedStats[4]
        self.speed = decodedStats[5]
        
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        
        self.shinyURL = try spriteContainer.decode(URL.self, forKey: .shinyURL)
        self.spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
    }
}
