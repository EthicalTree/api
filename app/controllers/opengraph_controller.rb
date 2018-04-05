class OpengraphController < APIController

  def index
    opengraph = Opengraph.new(params[:url])
    render json: opengraph.get_meta_tags, status: 200
  end

end
