class Api::V1::Accounts::ArticlesController < Api::V1::Accounts::BaseController
  before_action :portal
  before_action :check_authorization
  before_action :fetch_article, except: [:index, :create]
  before_action :set_current_page, only: [:index]

  def index
    @portal_articles = @portal.articles
    @all_articles = @portal_articles.search(list_params)
    @articles_count = @all_articles.count
    @articles = @all_articles.order_by_updated_at.page(@current_page)
  end

  def create
    @article = @portal.articles.create!(article_params)
    @article.associate_root_article(article_params[:associated_article_id])
    @article.draft!
    render json: { error: @article.errors.messages }, status: :unprocessable_entity and return unless @article.valid?
  end

  def edit; end

  def show; end

  def update
    @article.update!(article_params)
  end

  def destroy
    @article.destroy!
    head :ok
  end

  private

  def fetch_article
    @article = @portal.articles.find(params[:id])
  end

  def portal
    @portal ||= Current.account.portals.find_by!(slug: params[:portal_id])
  end

  def article_params
    params.require(:article).permit(
      :title, :slug, :content, :description, :position, :category_id, :author_id, :associated_article_id, :status, meta: [:title, :description,
                                                                                                                          { tags: [] }]
    )
  end

  def list_params
    params.permit(:locale, :query, :page, :category_slug, :status, :author_id)
  end

  def set_current_page
    @current_page = params[:page] || 1
  end
end
