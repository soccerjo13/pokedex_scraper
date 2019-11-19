require 'httparty'
require 'nokogiri'
require 'pokedex_scraper/silph_mon.rb'
require 'pokedex_scraper/gg_mon.rb'
require 'pokedex_scraper/pokemon.rb'

# Scrapes various sources for current Pokemon Go pokedex information and provides
# various methods for returning and formatting inforamtion on various pokemon or
# lists of pokemon by property.

module PokedexScraper

  # Scraper class that will contain all scraped pokedexes. Can re-initialize pokedexes
  # to pick up updated information using each init function.

    class PokedexScraper

        attr_accessor :pokedex_page
        attr_accessor :silph_dex

        def initialize
            init_silph_dex

            init_gg_dex
        end

        # re-initialize pokedex from thesilphroad.com
        def init_silph_dex
          silph_doc = HTTParty.get('https://thesilphroad.com/catalog#')
          @pokedex_page = Nokogiri::HTML(silph_doc)

          @silph_dex = @pokedex_page.css('div#content').css('.tab-pane').css('.pokemonOption').map do |pokemon|
            poke = SilphMon.new(pokemon)
            [poke.number_with_form, poke]
          end.to_h
        end

        # re-initialize pokedex from gamepress.gg/pokemongo
        def init_gg_dex
          gamepress_doc = HTTParty.get('https://gamepress.gg/pokemongo/pokemon-go-shinies-list')
          @shiny_page = Nokogiri::HTML(gamepress_doc)

          @gg_dex = @shiny_page.css('tbody').css('tr').map do |pokemon|
            poke = GGMon.new(pokemon)
            [poke.number_with_form, poke]
          end.to_h
        end

        # Searches for pokemon whose names contain the provided string.
        #
        # @param [String] name All pokemon whose names contain this string will be returned
        #
        # @return [Hash] silph_pokemon => gg_pokemon
        def find_pokemon_by_name(name)
            sanitized_name = name.gsub(/[^a-zA-Z]+/, '-').downcase
            poke_array = @silph_dex.values.find_all do |pokemon|
                pokemon.name.include?(sanitized_name)
            end
            poke_hash = poke_array.map do |silph_poke|
                [silph_poke, @gg_dex[silph_poke.number_with_form]]
            end
            poke_hash.count > 0 ? poke_hash : nil
        end

        # Searches for pokemon with the provided pokedex number
        #
        # @param [String] number Pokedex number of desired pokemon
        #
        # @return [Hash] silph_pokemon => gg_pokemon
        def find_pokemon_by_number(number)
            int_num = number.to_i
            silph_hash = @silph_dex.select do |num_and_form, pokemon|
                pokemon.dex_number == int_num
            end
            results = silph_hash.values.map do |silph_poke|
                [silph_poke, @gg_dex[silph_poke.number_with_form]]
            end
            results.count > 0 ? results : nil
        end

        # Formats pokemon objects into strings listing many of the properties of each pokemon
        #
        # @param [Hash] poke_hash silph_pokemon => gg_pokemon
        # @param [Bool] with_image Includes URL to image of pokemon when true
        #
        # @return [String] Each pokemon and its properties in a nicely formatted string
        def display_pokemon_info(poke_hash, with_image)
            unless poke_hash.nil?
                poke_hash.map do |silph, gg|
                    if silph.released?
                        "#{display_name(silph.name)} #{silph.dex_number}
Currently Available: #{silph.available?}
#{display_shiny_info(silph, gg)}
Currently available as shadow: #{silph.shadow_available?}
Can nest: #{silph.nests?}" + (with_image ? "\n#{silph.image}" : '')
                    else
                        "#{silph.name.capitalize} #{silph.dex_number}" +
                          "Has not been released in Pokemon Go" +
                          (with_image ? "\n#{silph.image}" : '')
                    end
                end
            else
                ['No pokemon found']
            end
        end

        # Formats name for display by capitalizing the first word and using space instead of '-'
        #
        # @param [String] name Name value as stored in Pokemon objects
        #
        # @return [String] An attempt at a formatted pokemon name
        def display_name(name)
            name.gsub('-', ' ').capitalize
        end

        # Formats the ways a shiny version of a pokemon can be obtained into a nice string
        #
        # @param [silph_mon] silph_poke silph_mon object
        # @param [gg_mon] gg_poke gg_mon object
        #
        # @return [String] String listing how a shiny version of the pokemon can be obtained, if possible
        def display_shiny_info(silph_poke, gg_poke)
            if silph_poke.shiny_released?
                if silph_poke.shiny_available?
                    "Shiny #{display_name(silph_poke.name)} currently available via #{gg_poke.ways_to_acquire.join(', ')}"
                else
                    "Shiny #{display_name(silph_poke.name)} not currently available"
                end
            else
                "#{display_name(silph_poke.name)} not available in shiny form"
            end
        end

        # Searches for pokemon whose name contains the provided name and formats results for display
        #
        # @param [String] name Name or part of name of desired pokemon
        # @param [Bool] with_image Specifies whether the image URL should be included in the response, default false
        #
        # @return [String] Formatted string listing properties of pokemon whose names contain the provided param
        def find_and_display_pokemon(name, with_image = false)
            poke_array = find_pokemon_by_name(name)
            display_pokemon_info(poke_array, with_image)
        end

        # Returns a list of all pokemon for whom a certain property is true or false
        #
        # @param [String] property Property to check
        # @param [Bool] value Specify if we are looking for the property to be true or false, default true
        #
        # @return [String] String with one pokemon name on each line
        def list_pokemon_by_current_property(property, value = true)
            results = case property
                      when 'nest', 'nests'
                        nesting_pokemon(value)
                      when 'shiny'
                        shiny_pokemon(value)
                      when 'shadow'
                        shadow_pokemon(value)
                      when 'released', 'available'
                        available_pokemon(value)
                      when 'raid', 'raid boss', 'raids'
                        raid_pokemon(value)
                      end
            list_pokemon_names(results)
        end

        # Returns a list of pokemon who have ever had the attribute in question.
        # If 'shiny' and true are provided, the list will contain every pokemon that
        # has ever been available in shiny form even if it is not currently available.
        # If the value param is false, this means the pokemon has never had that
        # attribute available.
        #
        # @param [String] property The attribute to check
        # @param [Bool] value The value we're looking for
        #
        # @return [String] list of names of pokemon
        def list_pokemon_by_historic_property(property, value=true)
          results = case property
                    when 'shiny'
                      ever_shiny_pokemon(value)
                    when 'released', 'available'
                      ever_available_pokemon(value)
                    when 'shadow'
                      ever_shadow_pokemon(value)
                    end
          list_pokemon_names(results)
        end

        def nesting_pokemon(value = true)
            results = []
            @silph_dex.each do |_, pokemon|
                if pokemon.nests? == value
                    results << pokemon
                end
            end
            results
        end

        def shiny_pokemon(value = true)
            results = []
            @silph_dex.each do |_, pokemon|
                if pokemon.shiny_available? == value
                    results << pokemon
                end
            end
            results
        end

        def ever_shiny_pokemon(value = true)
          results = []
          @silph_dex.each do |_, pokemon|
            if pokemon.shiny_released? == value
              results << pokemon
            end
          end
          results
        end

        def shadow_pokemon(value = true)
          results = []
          @silph_dex.each do |_, pokemon|
            if pokemon.shadow_available? == value
              results << pokemon
            end
          end
          results
        end

        def ever_shadow_pokemon(value = true)
          results = []
          @silph_dex.each do |_, pokemon|
            if pokemon.shadow_released? == value
              results << pokemon
            end
          end
          results
        end

        def available_pokemon(value = true)
          results = []
          @silph_dex.each do |_, pokemon|
            if pokemon.available? == value
              results << pokemon
            end
          end
          results
        end

        def ever_available_pokemon(value = true)
          results = []
          @silph_dex.each do |_, pokemon|
            if pokemon.released? == value
              results << pokemon
            end
          end
          results
        end

        def raid_pokemon(value = true)
          results = []
          @silph_dex.each do |_, pokemon|
            if pokemon.raid_boss? == value
              results << pokemon
            end
          end
          results
        end

        # Returns a list of formatted names when given pokemon objects
        #
        # @param [] list Pokemon objects?
        #
        # @return [String] Multi-line string with one pokemon name on each line
        def list_pokemon_names(list = @silph_dex)
            list.map do |pokemon|
                display_name(pokemon.name)
            end.join('\n')
        end

        def list_all_pokemon
            pokemon_array = []
            pokemon_array << "#{SilphMon::ATTRIBUTE_HEADERS.join(',')},#{GGMon::ATTRIBUTE_HEADERS.join(',')}"
            @silph_dex.each do |id, silph_mon|
                gg_mon = @gg_dex[id] ? @gg_dex[id] : nil
                pokemon_array << "#{silph_mon.list_attributes.join(',')}#{gg_mon ? ",#{gg_mon.list_attributes.join(',')}" : nil}"
            end
            pokemon_array
        end

        def in_gg_not_silph
            orphans = []
            orphans << GGMon::ATTRIBUTE_HEADERS.join(',')
            @gg_dex.each do |id, mon|
                if @silph_dex[id].nil?
                    orphans << mon.list_attributes.join(',')
                end
            end
            orphans
        end
    end
end
