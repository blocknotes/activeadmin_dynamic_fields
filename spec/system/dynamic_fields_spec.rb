# frozen_string_literal: true

RSpec.describe 'Dynamic fields', type: :system do
  let(:author) { Author.create!(email: 'some_email@example.com', name: 'John Doe', age: 30) }
  let(:post) { Post.create!(title: 'Test', author: author, description: '') }

  before do
    post
  end

  after do
    post.destroy
    author.destroy
  end

  context 'with some dynamic fields' do
    it 'toggles the .group1 elements when clicking on the checkbox' do
      visit "/admin/posts/#{post.id}/edit"

      expect(page).to have_css('#post_published[data-if="not_checked"][data-action="hide"][data-target=".group1"]')

      expect(find('#post_published')).not_to be_checked
      expect(page).to have_css('#post_dt_input', visible: :hidden)
      expect(page).to have_css('#post_position_input', visible: :hidden)

      find('#post_published').set(true)
      expect(page).to have_css('#post_dt_input', visible: :visible)
      expect(page).to have_css('#post_position_input', visible: :visible)

      find('#post_published').set(false)
      expect(page).to have_css('#post_dt_input', visible: :hidden)
      expect(page).to have_css('#post_position_input', visible: :hidden)
    end

    it 'changes the value of target when the source element is blank' do
      visit "/admin/posts/#{post.id}/edit"

      expect(page).to have_css('#post_description[data-if="blank"][data-action="setValue no title"][data-target="#post_category"]')
      expect(find('#post_category').value).to eq 'no title'
      find('#post_category').set('...')
      find('#post_description').set('...')
      expect(find('#post_category').value).to eq '...'
      find('#post_description').set('')
      expect(find('#post_category').value).to eq 'no title'
    end
  end
end
