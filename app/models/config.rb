class Config
  def self.protocol
    Rails.application.secrets[:protocol]
  end

  def self.webhost
    "#{Config.protocol}://#{Rails.application.secrets[:webhost]}"
  end

  def self.cdn
    "#{Config.protocol}://cdn.#{Rails.application.secrets[:webhost]}"
  end
end
