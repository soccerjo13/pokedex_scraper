require 'spec_helper'

describe PokedexScraper do

  scraper = PokedexScraper.new

  it "finds and displays a single pokemon" do
    pokemon = scraper.find_and_display_pokemon('squirtle')
    expect(pokemon).to be_a(Array)
    expect(pokemon.length).to be 1
  end

  it "finds and displays a single pokemon with image" do
    pokemon = scraper.find_and_display_pokemon('squirtle', true)
    expect(pokemon).to be_a(Array)
    expect(pokemon.length).to be 1
  end

  it "doesn't find a pokemon" do
    fake_pokemon = 'baloney'
    pokemon = scraper.find_and_display_pokemon(fake_pokemon)
    expect(pokemon).to be_a(Array)
    expect(pokemon[0]).to eq("No pokemon found")
  end

  it "doesn't find a pokemon with image" do
    pokemon = scraper.find_and_display_pokemon('baloney', true)
    expect(pokemon).to be_a(Array)
    expect(pokemon[0]).to eq("No pokemon found")
  end

  it "finds a single unreleased pokemon" do
    pokemon = scraper.find_and_display_pokemon('audino')
    expect(pokemon).to be_a(Array)
    expect(pokemon.length).to be 1
  end

  it "finds a single unreleased pokemon with image" do
    pokemon = scraper.find_and_display_pokemon('audino', true)
    expect(pokemon).to be_a(Array)
    expect(pokemon.length).to be 1
  end
end
