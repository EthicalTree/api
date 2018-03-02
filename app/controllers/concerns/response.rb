module Response
  def json_response(object, status=:ok)
    render json: object, status: status
  end

  def json_with_permissions(object, method, status=:ok)
    response = object.public_send(method).merge({
      permissions: object.permissions(current_user)
    })

    json_response(response, status)
  end
end
