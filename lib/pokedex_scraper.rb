require 'httparty'
require 'nokogiri'
require 'pokedex_scraper/silph_mon.rb'
require 'pokedex_scraper/gg_mon.rb'
require 'pokedex_scraper/pokemon.rb'

module PokedexScraper
    class PokedexScraper

        attr_accessor :pokedex_page
        attr_accessor :silph_dex

        def initialize
            silph_doc ||= HTTParty.get('https://thesilphroad.com/catalog#')
            @pokedex_page ||= Nokogiri::HTML(silph_doc)

            @silph_dex ||= @pokedex_page.css('div#content').css('.tab-pane').css('.pokemonOption').map do |pokemon|
                SilphMon.new(pokemon)
            end

            gamepress_doc ||= HTTParty.get('https://gamepress.gg/pokemongo/pokemon-go-shinies-list')
            @shiny_page ||= Nokogiri::HTML(gamepress_doc)

            @gg_dex = @shiny_page.css('tbody').css('tr').map do |pokemon|
                GGMon.new(pokemon)
            end
        end

        def find_pokemon_by_name(name)
            sanitized_name = name.gsub(/[^a-zA-Z]+/, '-').downcase
            poke_array = @silph_dex.find_all do |pokemon|
                pokemon.name.include?(sanitized_name)
            end
            poke_hash = poke_array.map do |silph_poke|
                [silph_poke, @gg_dex.find { |gg_poke| gg_poke.number_with_form == silph_poke.number_with_form }]
            end
            poke_hash.count > 0 ? poke_hash : nil
        end

        def find_pokemon_by_number(number)
            int_num = number.to_i
            poke_array = @silph_dex.find_all do |pokemon|
                pokemon.dex_number == int_num
            end
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
            @silph_dex.each do |pokemon|
                if pokemon.nests? == value
                    results << pokemon
                end
            end
            list_pokemon_names(results)
        end

        def list_pokemon_names(list = @silph_dex)
            list.map do |pokemon|
                pokemon.name.capitalize
            end.join('\n')
        end
    end
end
