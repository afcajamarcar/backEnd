class Product < ApplicationRecord
#relationships
    has_many :offeredProducts
	has_many :distributors, :through => :offeredProducts
    validates :name, :category, :weight, :photo, presence: true
    validates :weight , numericality: true

  #  default_scope {order('products.name ASC')}

    def self.load_products(page=1 , per_page=10)
        includes(distributors:[:offeredProducts, :products, :routes])
        .paginate(:page => page, :per_page => per_page)        
    end
#hace los mismo que el metodo load_products quitarlo. 
    def self.load_products_all()
        includes(distributors:[:offeredProducts, :products, :routes])
    end

    def self.product_by_id(id)
        includes(distributors:[:offeredProducts, :products, :routes])
        .where(products:{
            id: id
        }
        )
    end
    def self.products_by_ids(ids, page=1, per_page=10)
        load_products(page, per_page)
        .where(products:{
            id: ids    
        }).paginate(:page => page, :per_page => per_page)       
    end

    def self.products_by_categories(categories, page=1, per_page=10)
        includes(distributors:{routes: :coordinates})
        .where(products:{
            category: categories    
        }).paginate(:page => page, :per_page => per_page)       
    end

    #load distributor's products

    def self.products_by_distributor(distributor, page=1 , per_page=10)
        includes(:offeredProducts)
        .where(offered_products:{
            distributor_id: distributor 
        }).paginate(:page => page, :per_page => per_page)       
    end
   
   
    def self.categories_by_retailer(retailer_id, page=1, per_page=10)
       includes(offeredProducts: {orders: :retailer})
        .where(retailers:{
           id: retailer_id
        })
       .distinct.pluck(:category)
       
    end

    def self.categories_by_distributor(distributor_id,  page=1, per_page=10)
        joins(:offeredProducts)
            .where(offered_products:{
                distributor_id: distributor_id
            }).distinct.pluck(:category)
    end

    

end
