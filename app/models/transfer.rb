class Transfer < ApplicationRecord
  include Csvable

  belongs_to :gameweek_roster
  has_one :gameweek, through: :gameweek_roster
  has_one :roster, through: :gameweek_roster
  belongs_to :player_in, class_name: "Player"
  belongs_to :player_out, class_name: "Player"

  def self.csv_collection
    all.includes(:player_in, :player_out, :gameweek, roster: [:manager])
  end

  def self.csv_attributes
    attributes = %w{id player_in.slug player_out.slug roster.manager.slug gameweek.start_date gameweek.end_date created_at}
  end

end
