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
    it 'checks the conditions and actions' do
      visit "/admin/posts/#{post.id}/edit"

      expect(page).to have_css('#post_data_field_111[data-if="checked"][data-then="addClass red"][data-target="#post_data_field_111_input label"]') # rubocop:disable Layout/LineLength

      # --- if
      expect(page).not_to have_css('#post_data_field_111_input label.red')
      find('#post_data_field_111').click
      expect(page).to have_css('#post_data_field_111_input label.red')

      expect(page).to have_css('#post_data_field_121_input label.red')
      find('#post_data_field_121').click
      expect(page).not_to have_css('#post_data_field_121_input label.red')

      expect(page).to have_css('#post_data_field_132_input label.red')
      fill_in('post_data_field_132', with: 'something')
      find('body').click
      expect(page).not_to have_css('#post_data_field_132_input label.red')

      expect(page).not_to have_css('#post_data_field_141_input label.red')
      fill_in('post_data_field_141', with: 'something')
      find('body').click
      expect(page).to have_css('#post_data_field_141_input label.red')

      expect(page).not_to have_css('#post_data_field_142_input label.red')
      fill_in('post_data_field_142', with: 'something')
      find('body').click
      expect(page).to have_css('#post_data_field_142_input label.red')

      expect(page).not_to have_css('#post_data_field_151_input label.red')
      find('#post_data_field_151').click
      expect(page).to have_css('#post_data_field_151_input label.red')

      expect(page).not_to have_css('#post_data_field_152_input label.red')
      fill_in('post_data_field_152', with: 'something')
      find('body').click
      expect(page).to have_css('#post_data_field_152_input label.red')

      expect(page).not_to have_css('#post_data_field_153_input label.red')
      fill_in('post_data_field_153', with: 'something')
      find('body').click
      expect(page).to have_css('#post_data_field_153_input label.red')

      # --- eq
      expect(page).not_to have_css('#post_data_field_161_input label.red')
      fill_in('post_data_field_161', with: '161')
      find('body').click
      expect(page).to have_css('#post_data_field_161_input label.red')

      expect(page).not_to have_css('#post_data_field_162_input label.red')
      select('162', from: 'post_data_field_162')
      expect(page).to have_css('#post_data_field_162_input label.red')

      expect(page).not_to have_css('#post_data_field_163_input label.red')
      fill_in('post_data_field_163', with: '163')
      find('body').click
      expect(page).to have_css('#post_data_field_163_input label.red')

      # --- not
      expect(page).to have_css('#post_data_field_181_input label.red')
      fill_in('post_data_field_181', with: '181')
      find('body').click
      expect(page).not_to have_css('#post_data_field_181_input label.red')

      expect(page).to have_css('#post_data_field_182_input label.red')
      select('182', from: 'post_data_field_182')
      expect(page).not_to have_css('#post_data_field_182_input label.red')

      expect(page).to have_css('#post_data_field_183_input label.red')
      fill_in('post_data_field_183', with: '183')
      find('body').click
      expect(page).not_to have_css('#post_data_field_183_input label.red')

      # --- function
      expect(page).not_to have_css('#post_data_field_201_input label.red')
      fill_in('post_data_field_201', with: 'test')
      find('body').click
      expect(page).to have_css('#post_data_field_201_input label.red')

      expect(page).to have_css('#post_data_field_202[data-df-errors="custom function not found"]')

      expect(page).to have_css('#post_data_field_203.red')
      find('#post_data_field_203').click
      expect(page).not_to have_css('#post_data_field_203.red')

      # --- addClass
      expect(page).not_to have_css('#post_data_field_211_input label.red')
      find('#post_data_field_211').click
      expect(page).to have_css('#post_data_field_211_input label.red')
      find('#post_data_field_211').click
      expect(page).not_to have_css('#post_data_field_211_input label.red')

      # --- callback
      expect(page).not_to have_css('body.test_callback_arg')
      find('#post_data_field_221').click
      expect(page).to have_css('body.test_callback_arg')

      find('#post_data_field_222').click
      expect(page).to have_css('#post_data_field_222[data-df-errors="callback function not found"]')

      # --- setValue
      expect(find('#post_data_test').value).to be_empty
      find('#post_data_field_231').click
      expect(find('#post_data_test').value).to eq 'data test'

      # --- hide
      expect(page).to have_css('#post_data_field_241_input .inline-hints', visible: :visible)
      find('#post_data_field_241').click
      expect(page).to have_css('#post_data_field_241_input .inline-hints', visible: :hidden)

      # --- fade
      expect(page).to have_css('#post_data_field_251_input .inline-hints', visible: :visible)
      find('#post_data_field_251').click
      expect(page).to have_css('#post_data_field_251_input .inline-hints', visible: :hidden)

      # --- slide
      expect(page).to have_css('#post_data_field_261_input .inline-hints', visible: :visible)
      find('#post_data_field_261').click
      expect(page).to have_css('#post_data_field_261_input .inline-hints', visible: :hidden)

      # --- gtarget
      expect(page).not_to have_css('body.active_admin.red')
      find('#post_data_field_301').click
      expect(page).to have_css('body.active_admin.red')
      find('#post_data_field_301').click
      expect(page).not_to have_css('body.active_admin.red')

      find('#post_data_field_302').click # checks that using simply "target" will not work
      expect(page).not_to have_css('body.active_admin.red')
    end
  end

  context 'with some dynamic fields on a nested resource' do
    it 'checks the conditions and actions' do
      visit '/admin/authors/new'

      expect(page).not_to have_css('body.active_admin.red')
      find('body.active_admin .profile.has_many_container .button.has_many_add').click
      fill_in('author_profile_attributes_description', with: 'Some content')
      find('body').click
      expect(page).to have_css('body.active_admin.red')
      fill_in('author_profile_attributes_description', with: '   ')
      find('body').click
      expect(page).not_to have_css('body.active_admin.red')
    end
  end
end
