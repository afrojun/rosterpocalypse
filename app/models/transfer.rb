class Transfer < ApplicationRecord
  include Csvable

  belongs_to :gameweek_roster
  has_one :gameweek, through: :gameweek_roster
  has_one :roster, through: :gameweek_roster
  belongs_to :player_in, class_name: "Player"
  belongs_to :player_out, class_name: "Player"

  class << self
    def csv_collection
      all.includes(:player_in, :player_out, :gameweek, roster: [:manager])
    end

    def csv_attributes
      %w{id player_in.slug player_out.slug roster.manager.slug gameweek.start_date gameweek.end_date created_at}
    end

    def gameweek_transfers_in gameweek
      gameweek.transfers.
               select("player_in_id, count(player_in_id)").
               group(:player_in_id).
               size
    end

    def gameweek_transfers_out gameweek
      gameweek.transfers.
               select("player_out_id, count(player_out_id)").
               group(:player_out_id).
               size
    end

    def net_gameweek_transfers gameweek
      transfers_in = gameweek_transfers_in gameweek
      transfers_out = Hash[
        gameweek_transfers_out(gameweek).map do |player_id, num|
          [player_id, -num]
        end
      ]

      transfers_in.merge(transfers_out) do |key, in_count, out_count|
        in_count + out_count
      end
    end
  end
end
