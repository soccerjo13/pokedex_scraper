require 'spec_helper'

describe PokedexScraper do

  scraper = PokedexScraper.new

  it "finds and displays a pokemon" do
    pokemon = scraper.find_and_display_pokemon('squirtle')
    expect(pokemon).to be_a(Array)
    expect(pokemon.length).to be > 0
  end
end
