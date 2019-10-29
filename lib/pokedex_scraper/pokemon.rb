class Pokemon

    attr_accessor :dex_number
    alias :number :dex_number
    alias :pokedex_number :dex_number

    # TODO: figure out unowns if they are ever shiny
    attr_accessor :form

    attr_accessor :number_with_form

    def to_bool(value)
        if value == '1'
            true
        else
            false
        end
    end

end
