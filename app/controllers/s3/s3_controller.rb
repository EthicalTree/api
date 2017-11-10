module S3
  class S3Controller < APIController
    before_action :authenticate_user

    def sign
      options = {path_style: true}
      headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}

      slug = params[:slug]
      menu_id = params[:menu_id]

      name = "#{SecureRandom.uuid}-#{params[:objectName]}"

      if slug && menu_id
        key = "listings/#{slug}/images/#{name}"
      else
        key = "listings/#{slug}/menu/#{menu_id}/#{name}"
      end

      url = $fog.put_object_url($s3_bucket, key, 15.minutes.from_now.to_time.to_i, headers, options)

      render json: { key: key, signedUrl: url}
    end
  end
end


