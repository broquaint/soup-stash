object @game
if params[:field]
  attributes params[:field]
else
  attributes *@game.attributes.keys
end

