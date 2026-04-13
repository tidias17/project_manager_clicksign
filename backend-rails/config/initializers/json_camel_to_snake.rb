ActionDispatch::Request.parameter_parsers[:json] = lambda do |raw_post|
  data = ActiveSupport::JSON.decode(raw_post)
  data.deep_transform_keys { |key| key.to_s.underscore }
rescue ActiveSupport::JSON.parse_error
  {}
end
