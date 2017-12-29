class ItemController < ApplicationController

  get '/items' do
    if logged_in?
      @user = current_user
      @items = current_user.items
      erb :'items/index'
    else
      redirect to '/users/login'
    end
  end

  get '/items/new' do
    if logged_in?
      @user = current_user
      @locations = Location.all
      @categories = Category.all
      erb :'items/create'
    else
      redirect to '/users/login'
    end
  end

  post '/items/new' do
    binding.pry
    item = Item.create(params[:item])
    if params[:location_name] != ""
      new_location = Location.create(name: params[:location_name])
      item.location_id = new_location.id
    end

    if params[:item_category] != ""
      new_category = Category.create(name: params[:item_type])
      item.category_id = new_category.id
    end

    item.save
    redirect to '/items'
  end

  get '/items/:id' do
    if logged_in?
      @user = current_user
      @item = Item.find_by(id: params[:id])
      erb :'items/show'
    else
      redirect to '/users/login'
    end
  end

  get '/items/:id/edit' do
    @item = Item.find_by(id: params[:id])
    if logged_in? && @item.user_id == current_user.id
      erb :'items/edit'
    else
      redirect to '/users/login'
    end
  end

end
