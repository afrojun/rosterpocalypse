class Hero < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :game_details
  has_many :players, through: :game_details
  has_many :games, through: :game_details

  HERO_CLASSIFICATIONS = %w[Warrior Support Specialist Assassin Multiclass].freeze

  validates :name, presence: true, uniqueness: true
  validates :internal_name, presence: true, uniqueness: true
  validates :classification, inclusion: { in: HERO_CLASSIFICATIONS + ['', nil] }

  before_destroy :validate_destroy

  def validate_destroy
    game_count = game_details.size
    return unless game_count.positive?
    errors.add(:base, "Unable to delete #{name} since it has #{game_count} associated #{'game'.pluralize(game_count)}.")
    throw :abort
  end

  def stat_percentile(stat, percentile)
    game_details.extend(DescriptiveStatistics).percentile(percentile) { |detail| detail.send stat.to_sym }
  end

  HEROES = {
    # Specialist
    'Abathur' => { name: 'Abathur', classification: 'Specialist' },
    'Azmodan' => { name: 'Azmodan', classification: 'Specialist' },
    'Tinker' => { name: 'Gazlowe', classification: 'Specialist' },
    'Medivh' => { name: 'Medivh', classification: 'Specialist' },
    'Murky' => { name: 'Murky', classification: 'Specialist' },
    'WitchDoctor' => { name: 'Nazeebo', classification: 'Specialist' },
    'Necromancer' => { name: 'Xul', classification: 'Specialist' },
    'SgtHammer' => { name: 'Sgt. Hammer', classification: 'Specialist' },
    'Sylvanas' => { name: 'Sylvanas', classification: 'Specialist' },
    'LostVikings' => { name: 'The Lost Vikings', classification: 'Specialist' },
    'Zagara' => { name: 'Zagara', classification: 'Specialist' },

    # Assassin
    'Alarak' => { name: 'Alarak', classification: 'Assassin' },
    'Chromie' => { name: 'Chromie', classification: 'Assassin' },
    'DemonHunter' => { name: 'Valla', classification: 'Assassin' },
    'Falstad' => { name: 'Falstad', classification: 'Assassin' },
    'Gall' => { name: 'Gall', classification: 'Assassin' },
    'Greymane' => { name: 'Greymane', classification: 'Assassin' },
    'Guldan' => { name: "Gul'dan", classification: 'Assassin' },
    'Illidan' => { name: 'Illidan', classification: 'Assassin' },
    'Jaina' => { name: 'Jaina', classification: 'Assassin' },
    'Kaelthas' => { name: "Kael'thas", classification: 'Assassin' },
    'Kerrigan' => { name: 'Kerrigan', classification: 'Assassin' },
    'Dryad' => { name: 'Lunara', classification: 'Assassin' },
    'Nova' => { name: 'Nova', classification: 'Assassin' },
    'Ragnaros' => { name: 'Ragnaros', classification: 'Assassin' },
    'Raynor' => { name: 'Raynor', classification: 'Assassin' },
    'Samuro' => { name: 'Samuro', classification: 'Assassin' },
    'Butcher' => { name: 'The Butcher', classification: 'Assassin' },
    'Thrall' => { name: 'Thrall', classification: 'Assassin' },
    'Tracer' => { name: 'Tracer', classification: 'Assassin' },
    'Tychus' => { name: 'Tychus', classification: 'Assassin' },
    'Wizard' => { name: 'Li-Ming', classification: 'Assassin' },
    'Zeratul' => { name: 'Zeratul', classification: 'Assassin' },
    'Zuljin' => { name: "Zul'jin", classification: 'Assassin' },

    # Support
    'Auriel' => { name: 'Auriel', classification: 'Support' },
    'FaerieDragon' => { name: 'Brightwing', classification: 'Support' },
    'Monk' => { name: 'Kharazim', classification: 'Support' },
    'LiLi' => { name: 'Li Li', classification: 'Support' },
    'Malfurion' => { name: 'Malfurion', classification: 'Support' },
    'Medic' => { name: 'Lt. Morales', classification: 'Support' },
    'Rehgar' => { name: 'Rehgar', classification: 'Support' },
    'Tassadar' => { name: 'Tassadar', classification: 'Support' },
    'Tyrande' => { name: 'Tyrande', classification: 'Support' },
    'Uther' => { name: 'Uther', classification: 'Support' },

    # Warrior
    'Anubarak' => { name: "Anub'arak", classification: 'Warrior' },
    'Artanis' => { name: 'Artanis', classification: 'Warrior' },
    'Arthas' => { name: 'Arthas', classification: 'Warrior' },
    'Barbarian' => { name: 'Sonya', classification: 'Warrior' },
    'Chen' => { name: 'Chen', classification: 'Warrior' },
    'Cho' => { name: 'Cho', classification: 'Warrior' },
    'Crusader' => { name: 'Johanna', classification: 'Warrior' },
    'Dehaka' => { name: 'Dehaka', classification: 'Warrior' },
    'Diablo' => { name: 'Diablo', classification: 'Warrior' },
    'L90ETC' => { name: 'E.T.C.', classification: 'Warrior' },
    'Leoric' => { name: 'Leoric', classification: 'Warrior' },
    'Muradin' => { name: 'Muradin', classification: 'Warrior' },
    'Rexxar' => { name: 'Rexxar', classification: 'Warrior' },
    'Stitches' => { name: 'Stitches', classification: 'Warrior' },
    'Tyrael' => { name: 'Tyrael', classification: 'Warrior' },
    'Zarya' => { name: 'Zarya', classification: 'Warrior' },

    # Multiclass
    'Varian' => { name: 'Varian', classification: 'Multiclass' }
  }.freeze
end
