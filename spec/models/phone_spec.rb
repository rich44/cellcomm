require 'rails_helper'

RSpec.describe Phone, type: :model do

  before(:context){load("db/seeds.rb")}

  after(:context){ Phone.destroy_all}

  describe "Search box algorithm (search_algorithm)"  do
    context "Search query is 2 characters or less" do
      it "does not return any search results if the search query is 2 characters or less" do
        @search_results = Phone.search_algorithm("bl")
        expect(@search_results.nil?).to eq(true)
      end
    end

    context "search query is 1 word (more than 2 characters)" do
      it "returns the appropriate search results when the query has a brand in it" do
        @search_results = Phone.search_algorithm("Blackberry")
        expect(@search_results.all?{|phone| phone.brand_name == "Blackberry"}).to eq(true)
      end
    end

    context "search query is 2 words (combined more than 2 characters)" do
      it "returns the appropriate search results when the query has two brands in it" do
        @search_results = Phone.search_algorithm("Blackberry Google")
        expect(@search_results.all?{|phone| phone.brand_name == "Blackberry" || phone.brand_name == "Google"}).
        to eq(true)
      end

      it "returns the appropriate search results when the query has both a phone and a brand in it" do
        @search_results = Phone.search_algorithm("Google DTEK50")
        expect(@search_results.all?{|phone| phone.brand_name == "Google" || phone.phone_name == "DTEK50"}).
        to eq(true)
      end # it
    end # context
  end # describe

  describe "Checkbox search algorithm (checkbox_search)" do
    context "One checkbox category checked" do
      it "expects all search reuslts to have a brand name of Samsung" do
        params_hash = {"brand_name" => "Samsung"}
        @search_results = Phone.checkbox_search(params_hash)
        expect(@search_results.all?{|phone| phone.brand_name == "Samsung"}).to eq(true)
      end
    end

    context "Two checkbox categories checked" do
      before(:example) do
        params_hash = {"brand_name" => "Samsung", "os" => "Android"}
        @search_results = Phone.checkbox_search(params_hash)
      end

      it "expects all search results to have a brand name of Samsung" do
        expect(@search_results.all?{|phone| phone.brand_name == "Samsung"}).to eq(true)
      end

      it "expects all search results to have an OS of Android" do
        expect(@search_results.all?{|phone| phone.os == "Android"}).to eq(true)
      end
    end

    context "Three checkbox categories checked" do
      before(:example) do
        params_hash = {"brand_name" => "Samsung", "os" => "Android", "price_category" => "2"}
        @search_results = Phone.checkbox_search(params_hash)
      end

      it "expects all search results to have a brand name of Samsung" do
        expect(@search_results.all?{|phone| phone.brand_name == "Samsung"}).to eq(true)
      end # it

      it "expects all search results to have an OS of Android" do
        expect(@search_results.all?{|phone| phone.os == "Android"}).to eq(true)
      end # it

      it "expects all search results to have a price category between $501 and $750" do
        expect(@search_results.all?{|phone| phone.price_category == "2"}).to eq(true)
      end # it
    end # context
  end # describe
end # Rspec.describe
