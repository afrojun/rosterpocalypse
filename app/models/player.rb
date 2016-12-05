class Player < ApplicationRecord
  has_many :player_game_details, dependent: :destroy
  has_many :games, through: :player_game_details
  has_many :heroes, through: :player_game_details
  has_many :alternate_names, class_name: "PlayerAlternateName", dependent: :destroy
  belongs_to :team
  has_many :rosters, through: :roster_players

  after_create :update_alternate_names
  after_update :update_alternate_names

  # This is the maximum and minimum costs that a player can have to
  # ensure that the best players don't become overly expensive and
  # all players have some value
  MIN_COST = 20
  MAX_COST = 250

  def update_alternate_names
    PlayerAlternateName.find_or_create_by(player: self, alternate_name: name)
  end

  def self.find_or_create_including_alternate_names player_name
    alternate_names = PlayerAlternateName.where alternate_name: player_name
    if alternate_names.any?
      alternate_names.first.player
    else
      Player.find_or_create_by name: player_name
    end
  end

end
