require 'collate'

class Collate::Game < Collate
  def discern_attributes_from_params(params)
    opts = super(params)
    if opts.has_key? 'race'
      opts['race'] = ['Draconian'] if opts['race'] == 'Draconian'
      if opts['race'].is_a?(Array) and opts['race'].include?('Draconian')
        opts['race'] += DCSS::DRAC_COLOURS.collect{|c| "#{c} Draconian"}
      end
    end
    return opts
  end
end
