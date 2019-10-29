require 'pokedex_scraper/pokemon'

class SilphMon < Pokemon

  attr_accessor :nests
  alias :nests? :nests
  alias :nesting? :nests

  attr_accessor :raid_boss
  alias :raid_boss? :raid_boss

  attr_accessor :obtainable
  alias :available? :obtainable

  attr_accessor :released
  alias :ever_available? :released
  alias :released? :released

  attr_accessor :shiny_obtainable
  alias :shiny_available? :shiny_obtainable
  alias :shiny? :shiny_obtainable

  attr_accessor :shiny_released
  alias :shiny_ever_available? :shiny_released

  attr_accessor :shadow_available
  alias :shadow_available? :shadow_available
  alias :shadow? :shadow_available

  attr_accessor :shadow_released
  alias :shadow_ever_available? :shadow_released

  attr_accessor :pokemon_slug
  alias :name :pokemon_slug

  attr_accessor :image
  alias :picture :image

  def initialize(pokemon)
    attributes = pokemon.attributes
    @dex_number = pokemon.children.text.gsub('#', '').to_i
    @nests = to_bool(attributes['data-nests'].value)
    @raid_boss = to_bool(attributes['data-raid-boss'].value)
    @obtainable = to_bool(attributes['data-obtainable'].value)
    @released = to_bool(attributes['data-released'].value)
    @shiny_obtainable = to_bool(attributes['data-shiny-obtainable'].value)
    @shiny_released = to_bool(attributes['data-shiny-released'].value)
    @shadow_available = to_bool(attributes['data-shadow-available'].value)
    @shadow_released = to_bool(attributes['data-shadow-released'].value)
    @pokemon_slug = attributes['data-pokemon-slug'].value
    @image = pokemon['style'][/https.+png/]
    @form = parse_form(@pokemon_slug)
    @number_with_form = "#{@dex_number}-#{@form}"
  end

  def parse_form(slug)
    slug_arr = slug.split('-')
    if slug_arr.count() > 1
      puts "#{slug}: #{slug_arr.last}"
    else
      nil
    end
=begin
    burmy-plant: plant
    wormadam-plant: plant
    cherrim-overcast: overcast
    shellos-west-sea: sea
    gastrodon-west-sea: sea
    giratina-altered: altered
    shaymin-land: land
    arceus-normal: normal
    basculin-red: red
    deerling-spring: spring
    sawsbuck-spring: spring
    tornadus-incarnate: incarnate
    thundurus-incarnate: incarnate
    landorus-incarnate: incarnate
    meloetta-aria: aria
    rattata-alola: alola
    raticate-alola: alola
    raichu-alola: alola
    sandshrew-alola: alola
    sandslash-alola: alola
    vulpix-alola: alola
    ninetales-alola: alola
    diglett-alola: alola
    dugtrio-alola: alola
    meowth-alola: alola
    persian-alola: alola
    geodude-alola: alola
    graveler-alola: alola
    golem-alola: alola
    grimer-alola: alola
    muk-alola: alola
    exeggutor-alola: alola
    marowak-alola: alola
=end
  end
end
