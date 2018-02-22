# This code has been written as a collaborative effort by Artur Jaakman and Nazmus Sakib

# Run program by typing command "ruby wiki.rb" in console.
# To seeprogram in browser use "localhost:4567/" as address.
# Ctrl+c to terminate the process in Wiondows cmd.

require 'sinatra'
require 'sinatra/activerecord'
require 'pp' # Using this Ruby class as a debugging tool to log information in the console.
set :logging, :true

ActiveRecord::Base.establish_connection( # ActiveRecord Database, set up and expanded by Artur Jaakman

  :adapter => 'sqlite3',
  :database => 'wiki.db'

) 

class User < ActiveRecord::Base

  validates :username, presence: true, uniqueness: true  
  validates :password, presence: true
  validates :points, presence: true
end

class Article < ActiveRecord::Base # Created an aditional database class for storing and managing articles. Artur Jaakman.

  validates :heading, presence: true  
  validates :content, presence: true
  validates :author, presence: true
end


helpers do # Helpers used to validate user access level, 4 levels of access: visitor, user, moderator, admin. Set up by Artur Jaakman, with Nazmus Sakib providing debugging support.
 
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


def logDbChanges(event) # Method called with the event as parameter for Database Log. Written by Nazmus Sakib.

  file = File.open("log.txt")  # Read the log text file and get current content.
  currentText="";
  file.each do |line|	
      currentText= currentText + line			
  end
    
  timeStamp=Time.now.strftime("%d %m %Y at %I:%M%p") # Get current time stamp and format the time as string.
  
  user="Unknow"
  
  if $credentials!=nil       # If the user is not logged in, keep the user as unknow otherwise get the user id.
    user=$credentials[0]    
  end
 
	newText=timeStamp+"\t"+user+"\t"+event    # Concateate existing text and new text to be logged.
	logText=currentText+"\n"+newText
	
	file = File.open("log.txt", "w")  # Write to file.
	file.puts logText
 file.close	
end


get '/' do 			
  erb :home 	
end


get '/about' do	
  erb :about	
end

get '/create' do	
   registered! # Function checks user access level.   
   erb :create	
end


get '/editarticle/:id' do # Edit article page. Creates a new create page and loads parameters from old article. Made my Nazmus Sakib. 
  registered!
  
  @article = Article.where(:id => params[:id]).to_a.first
  erb :editarticle,  :locals => { :myheading =>  @article.heading, :mycontent=> @article.content} 
end

post '/archivetext' do # Admin feature for archiving articles in a .txt file. Made by Nazmus Sakib.
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
  
  a = Array.new # Creating and array and loading all article headings to check for duplicates. Made by Artur Jaakman.
  Article.all.each do |article|
   a.push article.heading
  end
     if !a.include?(params[:heading]) # Preventing the creation of articles with duplicate names.
         Article.create(heading: params[:heading], content: params[:content], author: $credentials[0], approved: false, approver: "", lasteditor: "")
     end
     event="New article created with heading "+params[:heading] # Event logging, part of logging function made by Nazmus Sakib.
     logDbChanges(event)
 redirect "/"
end


post '/edit' do

  registered!
   
    pp params #debuggin
     Article.create!(heading: params[:heading], content: params[:content], author: $credentials[0], approved: false, approver: "", lasteditor: "")
  
     event="Article edited with heading "+params[:heading]
     logDbChanges(event)
   
  redirect "/"
end


post '/reset' do # Admin control for resetting database. Made by Artur Jaakman.
 
  restricted!
 
  $credentials = ['','']
  Article.delete_all
  User.delete_all
  User.create(username: "Admin", password: "admin", moderator: true, points: 9999) # Creating an Admin account.
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
   @list4 = User.all.sort_by { |u| [-u.points] } # Sorting list of users by points. Made by Artur Jaakman and Nazmus Sakib.
   erb :rankings
end


get '/approve' do # Approve section only accessable by moderators.
  protected!
  erb :approve
end


get '/approveConfirmation/:id' do # Called when Approve link is clicked. Made by Nazmus Sakib and Artur Jaakman.
  protected!
    
  article = Article.where(:id => params[:id]).to_a.first  # Find that article using id.
  article.approved=true
  article.approver=$credentials[0]
  
  @Users = User.where(:username => article.author).to_a.first # Give +1 point to article author.
  @Users.points += 10
  @Users.save
  
  article.save
  
  event="Article approved with id: "+params[:id]
  logDbChanges(event)
  redirect "/approve" 
end


post '/login' do # Login feature, set up by Artur Jaakman.
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


post '/createaccount' do # Create Account. Set up by Artur Jaakman
   n = User.new    
   n.username = params[:username] 
   n.password = params[:password]   
   n.moderator = false   
   n.points = 0 
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


get '/articlelist' do # Creating article list made by Artur Jaakman, with debuggin aid provided by Nazmus Sakib.
   restricted! 
   @list3 = Article.all.sort_by { |u| [u.id] }
   erb :articlelist
end


get '/userlist' do # Creating user list made by Artur Jaakman.
   restricted!
   @list2 = User.all.sort_by { |u| [u.id] }   
   erb :userlist
end


put '/user/:uzer' do # Admin can promote Users to Moderator. Created by Artur Jaakman.
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
  redirect '/articlelist'
end


get '/user/delete/:uzer' do # Deleting user. Made by Artur Jaakman, debugging aid provided by Nazmus Sakib.
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


get '/article/delete/:artikle' do   # Deleting article and creating new list. Artur Jaakman.
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
