require 'pokedex_scraper/pokemon'

class GGMon < Pokemon


  def initialize(pokemon)
    @dex_number = pokemon['href']#.split('/').last
    @form
    @number_with_form
    @how_to_acquire = pokemon['.views-field-field-how-shiny-is-acquired']
  end
end
