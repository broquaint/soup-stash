# TODO Rename, make it a mixin for models.
# TODO Combine params_for + sort_by_for e.g Game.from_params
module ParamsFilter
  def params_for(model, params)
    valid_params = params.keys.select{|k| params[k].length > 0}
    # XXX Also handle compound params e.g skills.fighting
    opts = valid_params.reduce({}) do |opts, k|
      model.attribute_method?(k) ? opts.merge(k => params[k]) : opts
    end
    opts.delete 'id'

    where_opts = opts.select {|_, v| v.is_a? String }
    in_opts    = opts.select {|_, v| v.is_a? Array }
    return model.where(where_opts).in(in_opts)
  end

  def sort_by_for(model, params)
    sort = params[:sort] ? params[:sort].is_a?(Array) ? params[:sort] : [params[:sort]] : nil
    if sort and sort.all?{|c| model.attribute_method?(c)}
      params[:sort]
    end
  end
end
