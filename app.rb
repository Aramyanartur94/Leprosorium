#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'Leprosorium.db'
	@db.results_as_hash = true
	return @db
end

# before вызывается каждый раз при перезагрузке любой страницы
before do
	# инициализация БД
	init_db
end

configure do
	# инициализация БД
	@db = init_db
	
	# создает таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS
	"Posts"
	(
		"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date"	DATE,
		"content"	TEXT
	)'

	# создает таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS
	"Comments"
	(
		"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date"	DATE,
		"content"	TEXT,
		"post_id"	INTEGER
	)'
end

get '/' do
	# выбрать список пастов из БЗ
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index			
end

# обработчик get-запроса /new
# (браузер получает страницу с сервера)
get '/new' do
	erb :new
end

# вывод информации о посте
get '/details/:post_id' do
	# получаем переменную из url'а 
	post_id = params[:post_id]
	# получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	# выбираем этот один пост в переменную @row
	@row = results[0]
	# возвращаем представление details.erb 
	erb :details
end

# обработчик post-запроса /new
# (браузер отправляет данные на сервер)
post '/new' do
	# получаем переменную из post-запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Введите текст поста'
		return erb :new
	end

	# сохранение данных в БД
	@db.execute 'Insert into Posts (content, created_date) values (?, datetime())', [content]
	# перенаправление на главную страницу
	redirect to '/'
end

# обработчик post-запроса /details/...
# (браузер отправляет данные на сервер, мы их принемаем)
post '/details/:post_id' do
	# получаем переменную из url'а 
	post_id = params[:post_id]

	# получаем переменную из post-запроса
	content = params[:content]

	@db.execute 'Insert into Comments (content, created_date, post_id) values (?, datetime(), ?)', [content, post_id]
	
	# перенаправляем на страницу поста
	redirect to ('/details/' + post_id)
end