require 'pokedex_scraper'
require 'pry'

scraper = PokedexScraper::PokedexScraper.new

binding.pry

puts scraper.find_pokemon_by_name('bulb')
