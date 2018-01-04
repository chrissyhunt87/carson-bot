class ItemController < ApplicationController

  get '/items' do
    if !logged_in?
      redirect to '/users/login'
    end

    @user = current_user
    @user_items = current_user.items.sort_by {|item| item.name}
    erb :'items/index'
  end

  get '/items/new' do
    if !logged_in?
      redirect to '/users/login'
    end

    @user = current_user
    @locations = Location.all.select {|location| location.admin_lock || @user.locations.include?(location)}
    @categories = Category.all.select {|category| category.admin_lock || @user.categories.include?(category)}
    erb :'items/create'
  end

  post '/items/new' do
    if params[:item][:name].blank?
      redirect to '/items/new'
    end

    if params[:item_location].blank? && params[:item][:location_id].blank?
      redirect to '/items/new'
    end

    if params[:item_category].blank? && params[:item][:category_id].blank?
      redirect to '/items/new'
    end

    item = Item.create(params[:item])
    if params[:item_location] != ""
      new_location = Location.create(name: params[:item_location], admin_lock: false)
      item.location_id = new_location.id
    end

    if params[:item_category] != ""
      new_category = Category.create(name: params[:item_category], admin_lock: false)
      new_category.name = new_category.name.pluralize.singularize
      item.category_id = new_category.id
    end

    item.info_complete = true
    item.save
    item.attributes.each do |attr|
      if attr.blank?
        item.info_complete = false
      end
    end

    item.save
    redirect to '/items'
  end

  get '/items/:id' do
    if !logged_in?
      redirect to '/users/login'
    end

    @user = current_user
    @item = Item.find_by(id: params[:id])
    erb :'items/show'
  end

  get '/items/:id/edit' do
    if !logged_in?
      redirect to '/users/login'
    end

    @user = current_user
    @locations = Location.all.select {|location| location.admin_lock || @user.locations.include?(location)}
    @categories = Category.all.select {|category| category.admin_lock || @user.categories.include?(category)}
    @item = Item.find_by(id: params[:id])

    if @item.user_id == current_user.id
      erb :'items/edit'
    else
      redirect to '/items'
    end
  end

  post '/items/:id/edit' do
    item = Item.find_by(id: params[:id])

    if params[:item][:name].blank?
      redirect to "/items/#{item.id}/edit"
    end

    if params[:item_location].blank? && params[:item][:location_id].blank?
      redirect to "/items/#{item.id}/edit"
    end

    if params[:item_category].blank? && params[:item][:category_id].blank?
      redirect to "/items/#{item.id}/edit"
    end

    item.update(params[:item])
    if params[:item_location] != ""
      new_location = Location.create(name: params[:item_location], admin_lock: false)
      item.location_id = new_location.id
    end

    if params[:item_category] != ""
      new_category = Category.create(name: params[:item_category], admin_lock: false)
      item.category_id = new_category.id
    end

    item.info_complete = true
    item.save
    item.attributes.each do |k, v|
      if item[k] == nil || item[k] == "" || item[k] == " "
        item.info_complete = false
      end
    end

    item.save
    redirect to "/items/#{item.id}"
  end
end
