require 'rails_helper'
require 'requests/shared_restricted_index_page_request_spec'

RSpec.describe 'Maps', type: :request do
  it_should_behave_like 'a restricted index page request', :maps_path
end
