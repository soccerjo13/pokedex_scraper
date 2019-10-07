class Pokemon

    attr_accessor :number
    alias :dex_number :number
    alias :pokedex_number :number

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
        @dex_number = pokemon.children.text
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
    end

    def to_bool(value)
        if value == '1'
            true
        else
            false
        end
    end

end