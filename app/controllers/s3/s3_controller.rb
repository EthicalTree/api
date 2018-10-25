module S3
  class S3Controller < APIController
    before_action :authenticate_user

    def sign
      options = {path_style: true}
      headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}

      type = params[:type]
      slug = params[:slug]

      name = "#{SecureRandom.uuid}-#{params[:objectName]}"

      if type == 'listing'
        authorize! :update, Listing
        key = "listings/#{slug}/images/#{name}"
      elsif type == 'menu'
        authorize! :update, Listing
        menu_id = params[:menuId]
        key = "listings/#{slug}/menu/#{menu_id}/#{name}"
      elsif type == 'collection'
        authorize! :update, Collection
        key = "collections/#{slug}/images/#{name}"
      else
        return render json: {}, status: :not_found
      end

      url = $fog.put_object_url(
        $s3_ethicaltree_bucket,
        key,
        15.minutes.from_now.to_time.to_i,
        headers,
        options
      )

      render json: { key: key, signedUrl: url}
    end
  end

end


