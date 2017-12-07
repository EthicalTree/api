module Response
  def json_response(object, status=:ok)
    render json: object, status: status
  end

  def secured_json_response(object, method, options={}, status=:ok)
    response = object.public_send(method, options).merge({
      permissions: object.permissions(current_user)
    })

    json_response(response, status)
  end
end
