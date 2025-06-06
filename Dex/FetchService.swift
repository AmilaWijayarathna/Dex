//
//  FetchService.swift
//  Dex
//
//  Created by Amila Wijayarathna on 2025-05-07.
//

import Foundation

@MainActor
struct FetchService{
    
    
    enum fetchError : Error {
        case badResponse
        
    }
    
    private let baseUrl = URL(string: "https://pokeapi.co/api/v2/pokemon")
    
    func fetchPokemon(_ id: Int) async throws -> Pokemon {
        
        let fetchUrl = baseUrl?.appending(path : String(id))
        
        let(data, response) = try await URLSession.shared.data(from: fetchUrl!)
        
        guard let response = response as? HTTPURLResponse , response.statusCode == 200 else {
            throw fetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        
        print("fetched Pokemon \(pokemon.id) : \(pokemon.name.capitalized)")
        return pokemon
        
    }
}
