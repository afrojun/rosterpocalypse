require 'rails_helper'
require 'requests/shared_restricted_index_page_request_spec'

RSpec.describe "Tournaments", type: :request do
  it_should_behave_like "a restricted index page request", :tournaments_path
end
