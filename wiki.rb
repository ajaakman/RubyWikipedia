# Run program by typing command "ruby wiki.rb" in console.
# To seeprogram in browser use "localhost:4567/" as address.
# Ctrl+c to terminate the process in Wiondows cmd.

require 'sinatra'
require 'sinatra/activerecord'
require 'pp'
set :logging, :true

ActiveRecord::Base.establish_connection(

  :adapter => 'sqlite3',

  :database => 'wiki.db'

) 


class User < ActiveRecord::Base

  validates :username, presence: true, uniqueness: true
  
  validates :password, presence: true

end

class Article < ActiveRecord::Base

  validates :heading, presence: true
  
  validates :content, presence: true

end


#$myinfo = "Artur Jaakman" # $ indicates global variable.



#def readFile(filename)
#
#	info = ""
#	
#	file = File.open(filename)
#	
#	file.each do |line|
#	
#			info = info + line
#			
#	end
#	
#	file.close
#	
#	$myinfo = info
#	
#end
	

get '/' do # Root directory of web server.
	
	#info = "Hello There! "
	#
	#len = info.length
	#
	#len1 = len
	#
	#readFile("wiki.txt")
	#
	#@info = info + "" + $myinfo
	#
	#len = @info.length
	#
	#len2 = len - 1
	#
	#len3 = len2 - len1
	#
	#@words = len3.to_s
	#
	#@info = article.content # @ indicates instance variable.
	
	
	erb :home # Calls home view.
	
end


get '/about' do
	
	erb :about
	
end


get '/create' do
	
	erb :create
	
end


get '/edit' do # Edit page. Receives input and saves it into wiki.txt file.
	
	#info = ""	
	#
	#file = File.open("wiki.txt")
	#
	#file.each do |line|	
	#
	#		info = info + line			
	#
	#end
	#
	#file.close	
	#
	#@info = info	
	#
	erb :edit

end

get '/editarticle/:id' do
    @article = Article.where(:id => params[:id]).to_a.first
    erb :editarticle,  :locals => { :myheading =>  @article.heading, :mycontent=> @article.content} 
end

#put '/edit' do
#	
#	info = "#{params[:message]}"
#	
#	@info = info
#	
#	file = File.open("wiki.txt", "w")
#	
#	file.puts @info
#	
#	file.close
#	
#	redirect '/'
#
#end

post '/create' do
 
 a = Array.new
 Article.all.each do |article|
  a.push article.heading
end
    if !a.include?(params[:heading]) #Preventing the creation of articles with duplicate names.
        Article.create(heading: params[:heading], content: params[:content], approved: false)
    end
redirect "/"

end


post '/edit' do
 
  pp params
   Article.create!(heading: params[:heading], content: params[:content], approved: false)
 
redirect "/"

end


get '/login' do

   erb :login 

end


get '/archive' do

   erb :archive

end


get '/rankings' do

   erb :rankings

end


get '/approve' do

   erb :approve

end

#called when Approve link is clicked
get '/approveConfirmation/:id' do
    
    article = Article.where(:id => params[:id]).to_a.first  #find that article using id
    article.approved=true
    article.save
    erb :approvedConf
end

post '/login' do

   $credentials = [params[:username],params[:password]]

   @Users = User.where(:username => $credentials[0]).to_a.first

   if @Users

      if @Users.password == $credentials[1]
  
          redirect '/'
  
      else
  
          $credentials = ['','']
      
          redirect '/wrongaccount'

    end

    else

        $credentials = ['','']
      
        redirect '/wrongaccount'

   end

end


get '/createaccount' do

   erb :createaccount

end


post '/createaccount' do
 
   n = User.new   
 
   n.username = params[:username]
 
   n.password = params[:password]    
 
   if n.username == "Admin" and n.password == "Password"
	
        n.moderator = true 

    end

   n.save    

   redirect "/"

end


get '/logout' do

   $credentials = ['','']

   redirect '/'

end


get '/wrongaccount' do

   erb :wrongaccount

end


get '/admincontrols' do

   protected!

   @list2 = User.all.sort_by { |u| [u.id] }

   erb :admincontrols

end


put '/user/:uzer' do
 
  n = User.where(:username => params[:uzer]).to_a.first

   n.moderator = params[:moderator] ? 1 : 0
  
   n.save 
  
   redirect '/'

end


get '/user/delete/:uzer' do  
 
# protected!

n = User.where(:username => params[:uzer]).to_a.first

  if n.username == "Admin"

      erb :denied 

  else

      n.destroy    
      
      @list2 = User.all.sort_by { |u| [u.id] }
      
      erb :admincontrols

  end

end


helpers do

    def protected!

    if authorized?

    return

    end

    redirect '/denied'

end


def authorized?

  if $credentials != nil

    @Userz = User.where(:username => $credentials[0]).to_a.first
      
      if @Userz
          
          if @Userz.moderator == true
          
              return true
          
          else
              
              return false
         
          end
          
      else
          
          return false
      
      end
      
     end
   
  end

end


get '/noaccount' do

   erb :noaccount

end


get '/denied' do
  
   erb :denied 

end


get '/notfound' do

   erb :notfound 

end


not_found do # Redirect if directory does not exist.

	status 404
	
	redirect '/notfound'

end
