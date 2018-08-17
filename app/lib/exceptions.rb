module Exceptions
  class Unauthorized < StandardError; end
  class NotFound < StandardError; end
  class PaymentRequired < StandardError; end
  class Forbidden < StandardError; end
  class BadRequest < StandardError; end
  class Conflict < StandardError; end
end
