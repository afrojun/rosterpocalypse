class AddStripeDetailsAndEmailPrefsToManagers < ActiveRecord::Migration[5.0]
  def change
    add_column :managers, :customer_type,        :integer, null: false, default: 0
    add_column :managers, :stripe_customer_id,   :string
    add_column :managers, :subscription_status,  :integer, null: false, default: 0
    add_column :managers, :email_scores_updated, :boolean, null: false, default: false
    add_column :managers, :email_new_feature,    :boolean, null: false, default: false
    add_column :managers, :email_join_league,    :boolean, null: false, default: false

    add_index :managers, :stripe_customer_id, unique: true
  end
end
