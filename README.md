# SignedParams

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'signed_params'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install signed_params

## Usage

```ruby

signer = SignedParams::Signer.new("SOME_SECRET_IS_LONG:123123123123")

# sign the value "1" to be allowed for viewing from "user:1"

signed_value = signer.sign("1", "user:1") # => "1:1:BASE64_ENDODED_SIGNATURE"

value, viewer, status = signer.verify(signed_value) # => "1", "user:1", :success
# last param is an verification error message if appropriate:  :format_error, :invalid_signature

# helper method for verifying all params
signer.verify_params({
  :id => signed_value,
  :user_id => "234" # unsigned values will verify with an error of "not_signed"
})

# => [
#   ["id", "1", "user:1", :success],
#   ["user_id", nil, nil, :not_signed]
# ]


```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
