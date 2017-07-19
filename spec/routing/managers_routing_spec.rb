require 'rails_helper'

RSpec.describe ManagersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/managers').to route_to('managers#index')
    end

    it 'routes to #show' do
      expect(get: '/managers/1').to route_to('managers#show', id: '1')
    end
  end
end
