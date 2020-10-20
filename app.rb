#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sqlite3'

set :database, { adapter: 'sqlite3', database: 'leprosorium.db' }

class Post < ActiveRecord::Base
end

class Comment < ActiveRecord::Base
end

before do
	@posts = Post.all
end

get '/' do
	erb :index
end

get '/new' do
	erb :new
end

get '/posts/:id' do
	@post = Post.find(params[:id])
	erb :post
end


post '/new' do
	@p = Post.new params[:post]
	if @p.save
		erb 'Новый пост добавлен!'
	else
		@error = @p.errors.full_messages.first
		erb :new
	end	
end