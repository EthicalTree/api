module S3
  class S3Controller < APIController
    before_action :authenticate_user

    def sign
      options = {path_style: true}
      headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}

      slug = params[:slug]
      menu_id = params[:menuId]

      name = "#{SecureRandom.uuid}-#{params[:objectName]}"

      if slug && menu_id
        key = "listings/#{slug}/menu/#{menu_id}/#{name}"
      else
        key = "listings/#{slug}/images/#{name}"
      end

      url = $fog.put_object_url(
        $s3_images_bucket,
        key,
        15.minutes.from_now.to_time.to_i,
        headers,
        options
      )

      render json: { key: key, signedUrl: url}
    end
  end
end


