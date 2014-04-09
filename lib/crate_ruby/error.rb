module CrateRuby
  # Base Error class
  class CrateError < StandardError; end
  class BlobExistsError < CrateError; end

end