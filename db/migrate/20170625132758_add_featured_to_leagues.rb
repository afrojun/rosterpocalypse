class AddFeaturedToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :featured, :boolean, null: false, default: false
    add_index :leagues, :featured

    PublicLeague.where(slug: 'heroes-powerhour-s2-league').first.try :toggle!, :featured
    PublicLeague.where(slug: 'lords-of-the-storm-league').first.try :toggle!, :featured
    PublicLeague.where(id: 263).first.try :toggle!, :featured
    PublicLeague.where(id: 264).first.try :toggle!, :featured
  end
end
