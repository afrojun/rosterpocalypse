require 'rails_helper'
require 'requests/shared_restricted_index_page_request_spec'

RSpec.describe 'Games', type: :request do
  it_should_behave_like 'a restricted index page request', :games_path
end
