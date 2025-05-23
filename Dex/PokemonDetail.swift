//
//  PokemonDetail.swift
//  Dex
//
//  Created by Amila Wijayarathna on 2025-05-24.
//

import SwiftUI

struct PokemonDetail: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var pokemon: Pokemon
    
    @State private var showShiny: Bool = false
    
    var body: some View {
        ScrollView{
            ZStack{
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color : .black ,radius: 6)
                
                AsyncImage(url: pokemon.sprite){ image in
                    
                    image
                        .interpolation(.none)
                       .resizable()
                       .scaledToFit()
                       .padding(.top, 50)
                       .shadow(color : .black ,radius: 6)
                    
                }placeholder:{
                    ProgressView()
                }
            }
            HStack{
                ForEach(pokemon.types!, id: \.self) { type in
                    
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color : .white ,radius: 1)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 7)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                        
                }
                Spacer()
                
                Button{
                    pokemon.favourite.toggle()
                    
                    do {
                        try viewContext.save()
                        
                    }catch {
                        print(error)
                    }
                }label: {
                    Image(systemName: pokemon.favourite ? "star.fill" : "star")
                        .font(.title2)
                        .tint(.yellow)
                }
            }
            .padding()
            
        }
        .navigationTitle(pokemon.name!.capitalized)
    }
}

#Preview {
    NavigationStack{
        PokemonDetail()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
