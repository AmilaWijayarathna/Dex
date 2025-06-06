//
//  Pokemon.swift
//  Dex
//
//  Created by Amila Wijayarathna on 2025-05-25.
//
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Pokemon : Decodable{
    
    @Attribute(.unique) var id: Int
    var name: String
    var types: [String]
    var hp: Int
    var attack: Int
    var defence: Int
    var favourite: Bool = false
    var spriteURL: URL
    var shinyURL: URL
    var specialAttack: Int
    var specialDefence: Int
    var speed: Int
    var sprite: Data?
    var shiny: Data?
    
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

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
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
        
        var decodedStats : [Int] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        
        while !statsContainer.isAtEnd{
            
            var statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatDictionaryKeys.self)
 
            let stat = try statsDictionaryContainer.decode(Int.self, forKey: .baseStat)
            decodedStats.append(stat)
            
        }
        
        self.hp = decodedStats[0]
        self.attack = decodedStats[1]
        self.defence = decodedStats[2]
        self.specialAttack = decodedStats[3]
        self.specialDefence = decodedStats[4]
        self.speed = decodedStats[5]
        
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        
        self.shinyURL = try spriteContainer.decode(URL.self, forKey: .shinyURL)
        self.spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
    }
    
    var spriteImage : Image{
        if let data = sprite , let image = UIImage(data: data){
            Image(uiImage : image)
        }else{
            Image(.bulbasaur)
        }
    }
    
    var shinyImage : Image{
        if let data = shiny , let image = UIImage(data: data){
            Image(uiImage : image)
        }else{
            Image(.shinybulbasaur)
        }
    }
    
    var background : ImageResource {
        switch types[0]{
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "phychic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case  "ice":
                .ice
        case  "water":
                .water
            
        default:
                .normalgrasselectricpoisonfairy
        }
    }
    
    var typeColor : Color{
        Color(types[0].capitalized)
    }
    
    var stats : [Stat]{
        [
            Stat(id:  1, name: "HP" , value: hp ),
            Stat(id:  2, name: "Attack" , value: attack ),
            Stat(id:  3, name: "Defense" , value: defence ),
            Stat(id:  4, name: "Special Attack" , value: specialAttack  ),
            Stat(id:  5, name: "Special Defense" , value:  specialDefence),
            Stat(id:  6, name: "Speed", value: speed )
        ]
    }
    
    var highestStat :Stat{
        stats.max{$0.value < $1.value}!
    }
    
    struct Stat : Identifiable {
        
        let id : Int
        let name : String
        let value : Int
    }

    
}
