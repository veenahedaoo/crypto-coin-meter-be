namespace :coins do
  desc "TODO"
  task seed: :environment do
    puts "Fetching Coins from the coingecko..."
    CoinGeckoService.new.init_coins_list
    puts "Coins list loaded."
  end

end
