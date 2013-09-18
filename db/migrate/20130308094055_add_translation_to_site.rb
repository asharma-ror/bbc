class AddTranslationToSite < ActiveRecord::Migration
  def change
    add_column :sites, :locale, :string
  end
end
