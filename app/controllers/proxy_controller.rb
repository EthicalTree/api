class ProxyController < APIController
  def index
    protocol = Rails.application.secrets[:protocol]
    proxyhost = Rails.application.secrets[:proxyhost]
    webhost = Rails.application.secrets[:webhost]

    path = params[:url]

    if path.present? && path.first != '/'
      path = "/#{path}"
    end

    response = HTTParty.get("#{protocol}://#{proxyhost}")

    body = response.body.gsub(
      '<meta name="et:opengraph">',
      Meta.get_meta_tags(protocol, webhost, path)
    )

    render html: body.html_safe
  end
end
