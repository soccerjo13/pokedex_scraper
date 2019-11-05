require 'pokedex_scraper'
require 'pry'

scraper = PokedexScraper::PokedexScraper.new

puts scraper.find_pokemon_by_name('bulb')
