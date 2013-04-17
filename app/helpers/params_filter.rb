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
    params[:sort].to_s if params[:sort] and model.attribute_method?(params[:sort])
  end
end
