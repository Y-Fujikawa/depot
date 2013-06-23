require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # テストデータの準備
  fixtures :products
  
  # 空のProductの場合エラーになるか検証
  test "Product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:image_url].any?
    assert product.errors[:price].any?
  end
  
  # 価格の検証
  test "product price must be positive" do
    product = Product.new(title: "My Book Title",
                          description: "1234567890",
                          image_url: "zzz.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01", product.errors[:price].join('; ')

    product.price = 0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01", product.errors[:price].join('; ')

    product.price = 1
    assert product.valid?
  end
  
  # 商品名の検証
  test "product description must be length <= 10" do
    product = Product.new(description: "1234567890",
                          price: 1,
                          image_url: "zzz.jpg")
    product.title = "123456789"
    assert product.invalid?
    assert_equal "商品名は10文字以上でなければなりません", product.errors[:title].join('; ')

    product.title = "1234567890"
    assert product.valid?

    product.title = "12345678901"
    assert product.valid?
  end
  
  # 画像URLの検証
  def new_product(image_url) 
    product = Product.new(title: "My Book Title",
                          description: "1234567890",
                          price: 1,
                          image_url: image_url)
  end
  
  test "image_url" do
    ok = %w{ fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
    ng = %w{ fred.doc fred.gif/more fred.gif.more }
    
    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end
    
    ng.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
    end
  end
  
  # 商品名が異なっていることの検証
  test "product is not valid without a unique title" do
    product = Product.new(title: products(:ruby).title,
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert !product.save
    assert_equal "has already been taken", product.errors[:title].join("; ")
  end
  
  # 国際化のための準備ができていないため、一旦コメントアウト
  # test "product is not valid without a unique title - i18n" do
    # product = Product.new(title: products(:ruby).title,
                          # description: "yyy",
                          # price: 1,
                          # image_url: "fred.gif")
    # assert !product.save
    # assert_equal I18n.translate('activerecord.errors.messages.taken'), product.errors[:title].join("; ")
  # end
end
