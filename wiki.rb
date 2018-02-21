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


helpers do
 
    def restricted! # Only admins.
       if authorizedadmin?
          return
       end
    redirect '/denied'
    end

    def authorizedadmin?
         if $credentials != nil
          @Userz = User.where(:username => $credentials[0]).to_a.first      
            if @Userz          
                if @Userz.username == "Admin"          
                    return true          
                else              
                    return false         
                end          
            else          
                return false      
            end       
          end   
    end
    
    def protected! # Only Moderators.
       if authorizedmoderator?
          return
       end
    redirect '/onlymods'
    end

    def authorizedmoderator?
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

   def registered! # Only Logged In users.
       if authorizeduser?
          return
       end
    redirect '/pleaselogin'
    end

    def authorizeduser?
         if $credentials != nil
          @Userz = User.where(:username => $credentials[0]).to_a.first      
            if @Userz          
                if @Userz.username != ""          
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
	
	registered!
	
	erb :create
	
end


get '/edit' do # Edit page. Receives input and saves it into wiki.txt file.
	
	registered!
	
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
 
 registered!
 
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
 
 protected!
 
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

protected!
 
  pp params
   Article.create!(heading: params[:heading], content: params[:content], approved: false)
 
redirect "/"

end

post '/reset' do
 
 restricted!
 
$credentials = ['','']
Article.delete_all
User.delete_all
User.create(username: "Admin", password: "admin", moderator: true, points: 9999) # Creating an Admin account.
User.create(username: "Moderator", password: "moderator", moderator: true, points: 100)
User.create(username: "User", password: "user", moderator: false, points: 10)
Article.create(heading: "testheading", content: "testcontent testcontent testcontent testcontent testcontent testcontent testcontent", author: "Admin", approved: false, approver: "Admin")
Article.create(heading: "test2", content: "testcontent2 text texttexttext texttext texttestcontent testcontent testcontent testcontent testcontent", author: "Admin", approved: false, approver: "Admin")
redirect "/"
 
end

get '/login' do

   erb :login 

end


get '/archive' do

   erb :archive

end


get '/rankings' do

   @list4 = User.all.sort_by { |u| [u.points] }

   erb :rankings

end


get '/approve' do

protected!

   erb :approve

end


#called when Approve link is clicked
get '/approveConfirmation/:id' do

protected!
    
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

   restricted!

   erb :admincontrols

end

get '/articlelist' do

   restricted!
 
   @list3 = Article.all.sort_by { |u| [u.id] }

   erb :articlelist

end

get '/userlist' do

restricted!

   @list2 = User.all.sort_by { |u| [u.id] }
   
   erb :userlist

end

put '/user/:uzer' do

restricted!
 
  n = User.where(:username => params[:uzer]).to_a.first

   n.moderator = params[:moderator] ? 1 : 0
  
   n.save 
  
   redirect '/'

end

put '/user/:artikle' do

restricted!
 
  n = Article.where(:id => params[:artikle]).to_a.first

   n.save 
  
   redirect '/'

end


get '/user/delete/:uzer' do  
 
restricted!

n = User.where(:username => params[:uzer]).to_a.first

  if n.username == "Admin"

      erb :denied 

  else

      n.destroy    
      
     @list2 = User.all.sort_by { |u| [u.id] }
      
    
      erb :admincontrols

  end
  
   redirect '/'

end

get '/article/delete/:artikle' do  
 
restricted!

      n = Article.where(:id => params[:artikle]).to_a.first

      n.destroy    
      
      
     @list3 = Article.all.sort_by { |a| [a.id] }
     
      erb :admincontrols

   redirect '/'

end


get '/noaccount' do

   erb :noaccount

end


get '/denied' do
  
   erb :denied 

end

get '/pleaselogin' do
  
   erb :pleaselogin

end

get '/onlymods' do
  
   erb :onlymods

end

get '/notfound' do

   erb :notfound 

end


not_found do # Redirect if directory does not exist.

	status 404
	
	redirect '/notfound'

end
