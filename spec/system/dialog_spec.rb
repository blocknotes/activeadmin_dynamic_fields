# frozen_string_literal: true

RSpec.describe 'Dialog', type: :system do
  let(:author) { Author.create!(email: 'some_email@example.com', name: 'John Doe', age: 30) }
  let(:post) { Post.create!(title: 'Test', author: author, description: '') }

  before do
    post
  end

  after do
    post.destroy
    author.destroy
  end

  context 'with a dialog' do
    subject(:author_link) { '.attributes_table .row-author a[data-df-dialog]' }

    it 'opens the dialog', :aggregate_failures do
      visit "/admin/posts/#{post.id}"

      expect(page).to have_css(author_link)
      expect(page).not_to have_css('.ui-dialog')
      find(author_link).click
      expect(page).to have_css('.ui-dialog', visible: :visible)
      expect(page).to have_css('#df-dialog dd', text: author.name)
      expect(page).to have_css('#df-dialog dd', text: author.age)
    end
  end
end
