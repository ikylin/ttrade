class AddMarketToQuotation < ActiveRecord::Migration
  def change
    add_column :quotations, :tag, :string
    add_column :quotations, :country, :string
    add_column :quotations, :exchange, :string
    add_column :quotations, :market, :string
    add_column :quotations, :currency, :string

    add_column :marketdates, :tag, :string
    add_column :marketdates, :country, :string
    add_column :marketdates, :exchange, :string
    add_column :marketdates, :market, :string
    add_column :marketdates, :currency, :string

    add_column :portfolios, :tag, :string
    add_column :portfolios, :country, :string
    add_column :portfolios, :exchange, :string
    add_column :portfolios, :market, :string
    add_column :portfolios, :currency, :string

    add_column :quotationdatafiles, :tag, :string
    add_column :quotationdatafiles, :country, :string
    add_column :quotationdatafiles, :exchange, :string
    add_column :quotationdatafiles, :market, :string
    add_column :quotationdatafiles, :currency, :string

    add_column :reserves, :tag, :string
    add_column :reserves, :country, :string
    add_column :reserves, :exchange, :string
    add_column :reserves, :market, :string
    add_column :reserves, :currency, :string

    add_column :sysconfigs, :tag, :string
    add_column :sysconfigs, :country, :string
    add_column :sysconfigs, :exchange, :string
    add_column :sysconfigs, :market, :string
    add_column :sysconfigs, :currency, :string

    add_column :odsreserves, :tag, :string
    add_column :odsreserves, :country, :string
    add_column :odsreserves, :exchange, :string
    add_column :odsreserves, :market, :string
    add_column :odsreserves, :currency, :string
  end
end

