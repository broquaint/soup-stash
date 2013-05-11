require 'reindeer'

class Collate < Reindeer
  has :result_set  # is_a: ActiveSomething?

  def filter_and_sort(args)
    params = args[:params]
    order  = args[:order] || 'desc'
    sort   = sort_on(params, args[:sort_default])
    query_with(params).__send__(order.to_sym, sort)
  end

  def discern_attributes_from_params(params)
    valid_params = params.keys.select{|k| params[k].length > 0}
    # XXX Also handle compound params e.g skills.fighting
    opts = valid_params.reduce({}) do |opts, k|
      result_set.attribute_method?(k) ? opts.merge(k => params[k]) : opts
    end
    opts.delete 'id'
    return opts
  end

  def query_with(params)
    opts = discern_attributes_from_params(params)
    where_opts = opts.select {|_, v| v.is_a? String }
    in_opts    = opts.select {|_, v| v.is_a? Array }
    return result_set.where(where_opts).in(in_opts)
  end

  def sort_on(params, default = nil)
    sort = params[:sort] ? params[:sort].is_a?(Array) ? params[:sort] : [params[:sort]] : nil
    if sort and sort.all?{|c| result_set.attribute_method?(c)}
      params[:sort]
    else
      default
    end
  end
end
