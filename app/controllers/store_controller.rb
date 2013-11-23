class StoreController < ApplicationController
  def index
    current_visit_count
    @products = Product.order(:title)
    @cart = current_cart
  end
end
