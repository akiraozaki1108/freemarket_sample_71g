class ItemsController < ApplicationController
before_action :set_item, only: [:show, :edit, :update, :done]
  def set_item
    @item = Item.find(params[:id])
  end


  def index
    @items = Item.all.includes(:images).order("created_at DESC")
  end

  def show
  end

  def new
    @item = Item.new
    5.times { @item.images.build }
    @category_parent_array = ["---"]
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    # @category_parent_array = Category.where(ancestry: nil).pluck(:name) 
    end
  end

  def get_category_children
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
  end

  def get_category_grandchildren
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  
  def create
    @item = Item.new(item_params)
    category_id_params
    if @item.save
      redirect_to root_path
    else
      redirect_to new_item_path
    end
  end

  def edit
    @item = Item.find(params[:id])
    5.times { @item.images.build }
  end

  def update
    if @item.update(item_params)
      redirect_to root_path
    else 
      render :edit
    end
  end

  def destroy
    @item = Item.find(params[:id]) 
    if @item.destroy
      redirect_to root_path
    else 
      redirect_to :destroy
    end
  end

  def done
    @item_purchaser= Item.find(params[:id])
  end

  def pay
    @item = Item.find(params[:id])
    Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
    charge = Payjp::Charge.create(
    amount: @item.price,
    card: params['payjp-token'],
    currency: 'jpy'
    )
  end

  def item_params
    params.require(:item).permit(
      :name, 
      :explaination, 
      :price, 
      :brand,
      :prefecture_id, 
      :condition_id, 
      :shipment_id, 
      :responsibility_id, 
      images_attributes: [:src, :_destroy, :id]
    ).merge(
      user_id: current_user.id ,seller_id: current_user.id
    )
  end


  def category_id_params
    category = params.permit(:category_id)
    @item[:category_id] = category[:category_id]
  end
end