require 'pokedex_scraper/pokemon'

class GGMon < Pokemon

  attr_accessor :dex_number
  alias :number :dex_number

  attr_accessor :number_with_form

  attr_accessor :name

  attr_accessor :ways_to_acquire
  alias :how_to_get :ways_to_acquire

  @gg_forms = {
    'alolan' => 'alola',
    'altered' => 'altered',
    'snowy' => '',
    'rainy' => '',
    'sunny' => ''
  }

  def initialize(pokemon)
    #binding.pry
    @dex_number, @form = parse_number_and_form(pokemon)
    @number_with_form = "#{@dex_number}-#{standardize_form(@form)}"
    @name = pokemon.children.children
    @ways_to_acquire = pokemon.children.find do |child|
      child.name == 'td' && child.attributes['headers'].value == 'view-field-how-shiny-is-acquired-table-column'
    end.children.text.split(',').map{ |way| way.strip.nil? || way }
    @name = pokemon.attributes['class'].value.slice(/-row name-(.*)/, 1)
  end

  def parse_number_and_form(pokemon)
    num_and_form = pokemon.children.children.find do |child|
      child.name == "a"
    end.attributes['href'].value.slice(/\/pokemon\/(.*)/, 1)

    num_form_arr = num_and_form.split('-')
    num = num_form_arr[0]
    form = num_form_arr.count > 1 ? num_form_arr[1] : ''
    [num, form]
  end

  def standardize_form(form)
    #unless form.nil?
    #  @gg_forms[form]
    #end
  end
end
