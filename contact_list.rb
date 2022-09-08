require "sinatra"
require "tilt/erubis"

require_relative "database_persistence"
set :environment, :production
before do
  @storage = DatabasePersistence.new(logger)
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

get "/" do
  redirect "/contacts"
end

get "/contacts" do
  @contacts = @storage.list_all_contacts
  erb :contacts
end

get "/contacts/add" do
  erb :add_contact
end

get "/contacts/:id" do
  contact_id = params[:id].to_i
  @contact_info = @storage.list_contact_info(contact_id)
  
  erb :contact_info
end

get "/contacts/:id/edit" do
  contact_id = params[:id].to_i
  @contact_info = @storage.list_contact_info(contact_id)
  erb :edit
end

post "/contacts/:id/edit" do
  @storage.update_contact_info(params)
  params.inspect
  redirect "/contacts/#{params['id']}"
end

post "/contacts/:id/delete" do
  @storage.delete_contact(params[:id])
  redirect "/contacts"
end

post "/contacts/add" do
  @storage.add_contact_info(params)
  redirect "/contacts"
end

post "/contacts/category" do
  category_id = params[:category].to_i 
  redirect "/contacts/category/#{category_id}"
end

get "/contacts/category/:category_id" do
  category_id = params[:category_id].to_i
  @contacts = @storage.list_contacts_by_category(category_id)
  @category = @contacts.first[:category].capitalize
  erb :contacts_by_category
end

after do
  @storage.disconnect
end
