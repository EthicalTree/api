module S3
  class S3Controller < APIController
    before_action :authenticate_user

    def sign
      options = {path_style: true}
      headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}

      slug = params[:slug]
      name = "#{SecureRandom.uuid}-#{params[:objectName]}"

      url = $fog.put_object_url($s3_bucket, "listings/#{slug}/images/#{name}", 15.minutes.from_now.to_time.to_i, headers, options)

      render json: {signedUrl: url}
    end
  end
end


