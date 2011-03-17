class ApiController < ApplicationController
=begin
GET /api/get_contents?cid=integer&type=integer

cidとtypeは省略不可能．Contentsテーブルのcid，typeが該当するものからjsonのurlを引いて，spamであった場合は削除，そうでない場合はtitle，description，image_urlをJSONに追加．

を返す．

{
  "pages": [
    {
      "count": 1234,
      "url": "http:// ... ",
      "title": "HTMLエスケープ済みのページタイトル"（Pagesから引いてきたデータ）,
      "description": "HTMLエスケープ済みのページのスニペット"（Pagesから引いてきたデータ）,
      "image_url": "http:// ... " OR 存在しない場合は空文字列（Pagesから引いてきたデータ）,
    }
  ],
  "type": integer,
  "category_name": "home",
}

最後に言及された時間は現行バージョンでは格納しない．
=end
  def get_contents
    cid = params[:cid]
    type = params[:type].to_i
    cat = Category.find_by_id(cid.to_i)
    content = Content.find(:first, :conditions => {:content_type => type, :category_id => cid})
    (render(:json => ["resource not found"], :status => :not_found ) and return) unless cat && type && content
    ret = {:pages => [], :type => type, :category_name => cat.name}

    pagesjson = JSON.parse(content.json)
    pagesjson.each do |p|
      page = Page.find_by_url(p[1])
      if page && !page.spam
        tmp = {
          :count => p[0],
          :url => p[1],
          :title => page.title || "",
          :description => page.description || "",
          :image_url => page.image_url || "",
        }
        ret[:pages].push(tmp)
      end
    end

    render :json => ret, :callback => params[:callback]
  end
end