class ProxyController < APIController
  def index
    protocol = Rails.application.secrets[:protocol]
    proxyhost = Rails.application.secrets[:proxyhost]
    path = params[:url]
    response = HTTParty.get("#{protocol}://#{proxyhost}")

    body = response.body.gsub(
      '<link rel="opengraph" href="">',
      Opengraph.get_meta_tags("#{protocol}://#{proxyhost}/#{path}")
    )

    render html: body.html_safe
  end
end
