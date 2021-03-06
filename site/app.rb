class App < Sinatra::Base
  enable :sessions

  get '/' do
    @posts = Post.all
    erb :index
  end

  get '/about' do
    if session[:admin_id]
      erb :aboutadmin
    else
      erb :about
    end
  end

  get '/admin' do
    erb :login
  end

  get '/adminrights?=:query' do |query|
    if session[:admin_id]
      @posts = Post.all.select { |post| post.category.scan(/#{query}/i).length > 0 }
      erb :admin
    else
      redirect '/admin'
    end
  end

  get '/adminrights' do
    if session[:admin_id]
      @posts = Post.all
      erb :admin
    else
      redirect '/admin'
    end
  end

  get '/post' do
    if session[:admin_id]
      @posts = Post.all
      erb :post
    else
      redirect '/admin'
    end
  end

  get '/post/:id/edit' do |post_id|
    @post = Post.get(post_id)
    if @post && session[:admin_id]
      @posts = Post.all
      erb :postedit
    end
  end

  get '/comment/:id' do |post_id|
    @post = Post.get(post_id)
    if @post && session[:admin_id]
      @posts = Post.all
      @comments = Comment.all
      erb :commentadmin
    else
      @posts = Post.all
      @comments = Comment.all
      erb :comment
    end
  end

  get '/home' do
    if session[:admin_id]
      redirect '/adminrights'
    else
      redirect '/'
    end
  end

  post '/admin/login' do
    admin = Admin.first(username: params['username'])
    if admin && admin.password == params['password']
      session[:admin_id] = admin.id
      redirect '/adminrights'
    end

    redirect back

  end

  post '/admin/logout' do
    session[:admin_id] = nil
    redirect '/'
  end

  post '/post/post' do
    if session[:admin_id]
      redirect '/post'
    end
  end

  post '/post/:id/edit' do |post_id|
    @post = Post.get(post_id)
    if @post && session[:admin_id]
      @post.update(title: params['title'], category: params['category'], content: params['content'])
      redirect '/adminrights'
    end

  end


  post '/post/:id/delete' do |post_id|
    post = Post.get(post_id)
    if post && session[:admin_id]
      post.destroy
      redirect '/adminrights'
    else
      status 404
    end
  end

  post '/post/create' do
    if session[:admin_id]
      title = params['title']
      category = params['category']
      content = params['content']
      Post.create(title: title, category: category, content: content, admin_id: session[:admin_id])
      redirect '/adminrights'
    else
      redirect '/admin'
    end
  end

  post '/comment/:id/comment' do |post_id|
    @post = Post.get(post_id)
    if @post
      email = params['email']
      name = params['name']
      content = params['content']
      Comment.create(email: email, name: name, content: content, post: @post)
      redirect back
    else
      redirect '/'
    end
  end

end