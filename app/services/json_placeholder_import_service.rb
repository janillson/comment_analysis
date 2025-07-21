class JsonPlaceholderImportService
  BASE_URL = 'https://jsonplaceholder.typicode.com'

  def initialize(username)
    @username = username
  end

  def call
    user_data = fetch_user_by_username

    return nil unless user_data

    user = import_user(user_data)
    import_posts(user)
    import_comments(user)

    user
  end

  private

  def fetch_user_by_username
    # Busca usuário na API externa
    response = HTTParty.get("#{BASE_URL}/users")
    users = JSON.parse(response.body)
    users.find { |u| u['username'] == @username }
  end

  def import_user(user_data)
    User.find_or_create_by(external_id: user_data['id']) do |user|
      user.username = user_data['username']
      user.name = user_data['name']
      user.email = user_data['email']
    end
  end

  def import_posts(user)
    response = HTTParty.get("#{BASE_URL}/posts?userId=#{user.external_id}")
    posts_data = JSON.parse(response.body)

    posts_data.each do |post_data|
      Post.find_or_create_by(external_id: post_data['id']) do |post|
        post.user = user
        post.title = post_data['title']
        post.body = post_data['body']
      end
    end
  end

  def import_comments(user)
    user.posts.each do |post|
      response = HTTParty.get("#{BASE_URL}/comments?postId=#{post.external_id}")
      comments_data = JSON.parse(response.body)

      comments_data.each do |comment_data|
        Comment.find_or_create_by(external_id: comment_data['id']) do |comment|
          comment.post = post
          comment.original_body = comment_data['body']
          comment.body = comment_data['body'] # TODO: Traduzir
        end
      end
    end
  end
end
