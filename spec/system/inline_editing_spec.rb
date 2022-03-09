# frozen_string_literal: true

RSpec.describe 'Inline editing', type: :system do
  let(:author) { Author.create!(email: 'some_email@example.com', name: 'John Doe', age: 30) }
  let(:post) { Post.create!(title: 'Test', author: author, description: '') }

  before do
    post
  end

  after do
    post.destroy
    author.destroy
  end

  context 'with a column set for inline editing' do
    let(:editing_widget) { '.index_content .status_tag[data-field="published"][data-field-type="boolean"]' }

    it 'includes the editing widget', :aggregate_failures do
      visit "/admin/posts"

      expect(post.reload.published).to be_falsey
      expect(page).to have_css(editing_widget, text: 'NO')
      find(editing_widget).click
      expect(page).to have_css(editing_widget, text: 'YES')
      expect(post.reload.published).to be_truthy
    end
  end
end
