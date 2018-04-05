class ProxyController < APIController
  def index
    protocol = Rails.application.secrets[:protocol]
    webhost = Rails.application.secrets[:webhost]
    path = request.path.gsub('/proxy/', '')
    response = HTTParty.get("#{protocol}://#{webhost}")
    body = response.body.gsub('<link rel="opengraph" href="">', Opengraph.get_meta_tags("#{protocol}://#{webhost}/#{path}"))
    render html: body.html_safe
  end
end
