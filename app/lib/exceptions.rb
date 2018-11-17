module Exceptions
  # HTTP Exceptions
  class Unauthorized < StandardError; end
  class NotFound < StandardError; end
  class PaymentRequired < StandardError; end
  class Forbidden < StandardError; end
  class BadRequest < StandardError; end
  class Conflict < StandardError; end

  # Import/Export Exceptions
  class EthicalTreeImportException < StandardError; end
  class EthicalTreeExportException < StandardError; end
end
