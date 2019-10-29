require 'httparty'
require 'nokogiri'
require 'pokedex_scraper/pokemon.rb'

class PokedexScraper

attr_accessor :pokedex_page
attr_accessor :pokedex

    def initialize
        doc ||= HTTParty.get('https://thesilphroad.com/catalog#')
        @pokedex_page ||= Nokogiri::HTML(doc)

        @pokedex ||= @pokedex_page.css('div#content').css('.tab-pane').css('.pokemonOption').map do |pokemon|
            Pokemon.new(pokemon)
        end
    end

    def find_pokemon_by_name(name)
        sanitized_name = name.gsub(/[^a-zA-Z]+/, '-').downcase
        poke_array = @pokedex.find_all do |pokemon|
            pokemon.name.include?(sanitized_name)
        end
        poke_array.count > 0 ? poke_array : nil
    end

    def display_pokemon_info(poke_array, with_image)
        unless poke_array.nil?
            poke_array.map do |pokemon|
                if pokemon.released?
                "#{pokemon.name.gsub('-', ' ').capitalize} #{pokemon.dex_number}
Currently Available: #{pokemon.available?}
Can be shiny: #{pokemon.shiny_available?}
Currently available as shadow: #{pokemon.shadow_available?}
Can nest: #{pokemon.nests?}" + (with_image ? "\n#{pokemon.image}" : '')
                else
                    "#{pokemon.name.capitalize} #{pokemon.dex_number}" +
                    "Has not been released in Pokemon Go" +
                    (with_image ? "\n#{pokemon.image}" : '')
                end
            end
        else
            ['No pokemon found']
        end
    end

    def find_and_display_pokemon(name, with_image = false)
        poke_array = find_pokemon_by_name(name)
        display_pokemon_info(poke_array, with_image)
    end

    def list_of_nesting(value = true)
        results = []
        @pokedex.each do |pokemon|
            if pokemon.nests? == value
                results << pokemon
            end
        end
        list_pokemon_names(results)
    end

    def list_pokemon_names(list = @pokedex)
        list.map do |pokemon|
            pokemon.name.capitalize
        end.join('\n')
    end
end
