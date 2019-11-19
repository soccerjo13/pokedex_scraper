require 'pokedex_scraper/pokemon'

class GGMon < Pokemon

  attr_accessor :ways_to_acquire
  alias :how_to_get :ways_to_acquire

  GG_FORMS = {
    'alolan' => 'alola',
    'altered' => 'altered',
    'snowy' => 'snow', #not in silph yet
    'rainy' => 'rain', #not in silph yet
    'sunny' => 'sun' #not in silph yet
  }

  ATTRIBUTE_HEADERS = [
    'dex_number',
    'form',
    'number_with_form',
    'name',
    'ways_to_acquire'
  ]

  def initialize(pokemon)
    @dex_number, @form = parse_number_and_form(pokemon)
    @number_with_form = "#{@dex_number}#{@form ? "-#{standardize_form(@form)}" : nil}"
    @ways_to_acquire = pokemon.children.find do |child|
      child.name == 'td' && child.attributes['headers'].value == 'view-field-how-shiny-is-acquired-table-column'
    end.children.text.split(',').map{ |way| way.strip.nil? || way }
    @name = pokemon.attributes['class'].value.slice(/-row name-(.*)/, 1)
  end

  def list_attributes
    [@dex_number,
     @form,
     @number_with_form,
     @name,
     @ways_to_acquire]
  end

  def parse_number_and_form(pokemon)
    num_and_form = pokemon.children.children.find do |child|
      child.name == "a"
    end.attributes['href'].value.slice(/\/pokemon\/(.*)/, 1)

    num_form_arr = num_and_form.split('-')
    num = num_form_arr[0]
    form = num_form_arr.count > 1 ? num_form_arr[1] : nil
    [num, form]
  end

  def standardize_form(form)
    unless form.nil?
      GG_FORMS[form]
    end
  end
end
