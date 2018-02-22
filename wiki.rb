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

def logDbChanges(event) #method called with the event as parameter


	file = File.open("log.txt")  #read the log text file and get current content
	currentText="";
    file.each do |line|	
	    currentText= currentText + line			
	end
	
	
	timeStamp=Time.now.strftime("%d %m %Y at %I:%M%p") #get current time stamp and format the time as string
	
	user="Unknow"
	
	if $credentials!=nil       #if the user is not logged in, keep the user as unknow otherwise get the user id
   user=$credentials[0]
 end
 
	
	newText=timeStamp+"\t"+user+"\t"+event    #concateate existing text and new text to be logged
	logText=currentText+"\n"+newText
	
	file = File.open("log.txt", "w")  #write to file
	file.puts logText
 file.close
	
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


post '/archivetext' do
   a= Array.new
	  archiveText=""
   
   Article.order(updated_at: :desc).each do |article|
     if article.approved == true && !a.include?(article.heading) 
    
        articleDetails= "Heading: "+ article.heading
        articleDetails=articleDetails+"\nContent: "+article.content
        if article.author==nil
          author="N/A"
        else
          author=article.author
        end
        articleDetails=articleDetails+ "\nAuthor: "+author
        articleDetails=articleDetails+ "\nApproved On: "+ article.updated_at.strftime("%d %m %Y at %I:%M%p")
        archiveText=archiveText+"\n\n\n"+articleDetails
     end 
     a.push article.heading 
		
   end
   
  file = File.open("archive.txt", "w")  #write to file
  file.puts archiveText
  file.close
  redirect "/admincontrols"
end


post '/create' do
 
 registered!
 
 a = Array.new
 Article.all.each do |article|
  a.push article.heading
end
    if !a.include?(params[:heading]) #Preventing the creation of articles with duplicate names.
        Article.create(heading: params[:heading], content: params[:content], approved: false)
    end
    event="New article created with heading "+params[:heading]
    logDbChanges(event)
redirect "/"

end


post '/edit' do

protected!
 
  pp params
   Article.create!(heading: params[:heading], content: params[:content], approved: false)

   event="Article edited with heading "+params[:heading]
   logDbChanges(event)
 
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
 
event="Datebase Reset" 
logDbChanges(event) 
 
end

get '/login' do

   erb :login 

end



get '/archive' do

   erb :archive

end


get '/rankings' do

   @list4 = User.all.sort_by { |u| [-u.points] }

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
    article.approver=$credentials[0]
    
    @Users = User.where(:username => article.author).to_a.first
    @Users.points += 1
    @Users.save
    
    
    article.save
    
    event="Article approved with id: "+params[:id]
    logDbChanges(event)
    erb :approvedConf
end

post '/login' do

   $credentials = [params[:username],params[:password]]

   @Users = User.where(:username => $credentials[0]).to_a.first

   if @Users

      if @Users.password == $credentials[1]
          event="User Logged in with user id: "+ params[:username]
          logDbChanges(event);  
          redirect '/'
  
      else
  
          $credentials = ['','']
          event="Logging attempt failed: "+ params[:username]
          logDbChanges(event);
          redirect '/wrongaccount'

    end

    else

        $credentials = ['','']
        event="Logging attempt failed: "+ params[:username]
        logDbChanges(event);
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
   event="New user signed up with user id "+params[:username]
   logDbChanges(event)
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
   
   event="User promoted as moderator with user id: "+params[:uzer]
   logDbChanges(event)
  
   redirect '/userlist'

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
      
    
      redirect '/userlist'

  end
  
  event="User deleted "+params[:uzer]
      logDbChanges(event)
  
   redirect '/userlist'

end


get '/article/delete/:artikle' do  
 
restricted!

      n = Article.where(:id => params[:artikle]).to_a.first

      n.destroy    
      
      
     @list3 = Article.all.sort_by { |a| [a.id] }
     
     event="Article deleted with id "+params[:artikle]
     logDbChanges(event)

   redirect '/articlelist'

end


get '/noaccount' do

   erb :noaccount

end


get '/denied' do
  
   erb :denied 

end

get '/user/:uzer' do 

    erb :profile

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
