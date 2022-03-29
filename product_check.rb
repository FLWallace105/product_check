require 'dotenv'
require 'httparty'
require 'shopify_api'
require 'active_record'
require 'sinatra/activerecord'

Dotenv.load
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

module ProductMixMatch
  class ShopifyGetter
    include ShopifyThrottle

    attr_reader :shopname, :api_key, :password, :shop_url

    DEFAULT_COLLECTION_TITLE = 'Mix and Match 5 Items One Time Purchase'
    SHOPIFY_API_VERSION = '2020-04'

    def initialize
      @shopname = ENV['SHOPIFY_SHOP_NAME']
      @api_key = ENV['SHOPIFY_API_KEY']
      @password = ENV['SHOPIFY_API_PASSWORD']
    end

    def list_mix_match_products(collection_title = DEFAULT_COLLECTION_TITLE)
      shopify_connection_config
      products_collection = shopify_products(collection_title)

      products = products_collection.map { |product| product_hash(product) }

      while products_collection.next_page?
        products_next_page = my_products.fetch_next_page
        products += products_next_page.map { |product| product_hash(product) }
      end

      products
    end

    def get_mix_match_collection_products
      puts "Starting ..."

      puts "Starting all shopify resources download"
      puts shop_url

      shopify_connection_config

      product_count = ShopifyAPI::Product.count()

      puts "We have #{product_count} products for Ellie"

      collection_title = 'Mix and Match 5 Items One Time Purchase'

      my_products = shopify_products(collection_title)

      File.delete('product_check.csv') if File.exist?('product_check.csv')

      column_header = ["product_title", "product_id", "product_type", "status", "published_scope", "published_at"]
      CSV.open('product_check.csv','a+', :write_headers=> true, :headers => column_header) do |hdr|
        column_header = nil

        my_products.each do |myprod|
          puts "-----"
          puts myprod.attributes['title']
          csv_data_out = [ myprod.attributes['title'], myprod.attributes['id'], myprod.attributes['product_type'],myprod.attributes['status'],  myprod.attributes['published_scope'], myprod.attributes['published_at'] ]
          hdr << csv_data_out
          puts "-----"
        end

        while my_products.next_page?
          my_products = my_products.fetch_next_page
          my_products.each do |myprod|
            puts "-----"
            puts myprod.attributes['title']
            csv_data_out = [ myprod.attributes['title'], myprod.attributes['id'], myprod.attributes['product_type'],myprod.attributes['status'],  myprod.attributes['published_scope'], myprod.attributes['published_at'] ]
            hdr << csv_data_out
            puts "-----"
          end


        end

      end

      puts "All done with products for #{collection_title}"
    end

    private

    def product_hash(product)
      {
        id: myprod.attributes['id'],
        title: myprod.attributes['title'],
        product_type: myprod.attributes['product_type'],
        status: myprod.attributes['status'],
        published_scope: myprod.attributes['published_scope'],
        published_at: myprod.attributes['published_at']
      }
    end

    def shop_url
      @shop_url ||= "https://#{@api_key}:#{@password}@#{@shopname}.myshopify.com/admin"
    end

    def shopify_connection_config
      ShopifyAPI::Base.site = shop_url
      ShopifyAPI::Base.api_version = SHOPIFY_API_VERSION
      ShopifyAPI::Base.timeout = 180
    end

    def shopify_products(collection_title)
      ShopifyAPI::CustomCollection.where(title: collection_title).first.products
    end
 end
end
