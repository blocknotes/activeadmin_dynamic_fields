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

  def apply_action(action, inverse: false)
    case action[0]
    when :click
      find(action[1]).click
    when :fill
      fill_in(action[1], with: inverse ? '' : action[2])
      find('#post_author_id').click # blur focus
    when :select
      select(inverse ? '' : action[2], from: action[1])
    end
  end

  def spec_message(string)
    RSpec.configuration.reporter.message(string)
  end

  def test_set_css(target, options = {})
    spec_message("test set#{options[:one_way] ? '' : '/unset'} CSS on #{target} ...")

    expect(page).not_to have_css(target)
    block_given? ? yield : apply_action(options[:action])
    expect(page).to have_css(target)
    return if options[:one_way]

    block_given? ? yield : apply_action(options[:action], inverse: true)
    expect(page).not_to have_css(target)
  end

  def test_unset_css(target, options = {})
    spec_message("test unset#{options[:one_way] ? '' : '/set'} CSS on #{target} ...")

    expect(page).to have_css(target)
    block_given? ? yield : apply_action(options[:action])
    expect(page).not_to have_css(target)
    return if options[:one_way]

    block_given? ? yield : apply_action(options[:action], inverse: true)
    expect(page).to have_css(target)
  end

  def test_change_css(target, options = {})
    spec_message("test change CSS on #{target} ...")

    expect(page).to have_css(target, **options[:attrs1])
    block_given? ? yield : apply_action(options[:action])
    expect(page).to have_css(target, **options[:attrs2])
    return if options[:one_way]

    block_given? ? yield : apply_action(options[:action], inverse: true)
    expect(page).to have_css(target, **options[:attrs1])
  end

  context 'with some dynamic fields' do
    it 'checks the conditions and actions', retry: 3 do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      visit "/admin/posts/#{post.id}/edit"

      expect(page).to have_css('#post_data_field_111[data-if="checked"][data-then="addClass"][data-args="red"][data-target="#post_data_field_111_input label"]')

      # --- if
      spec_message('check data-if condition')
      test_set_css('#post_data_field_111_input label.red', action: [:click, '#post_data_field_111'])
      test_unset_css('#post_data_field_112_input label.red', action: [:click, '#post_data_field_112'])
      test_unset_css('#post_data_field_121_input label.red', action: [:click, '#post_data_field_121'])
      test_unset_css('#post_data_field_131_input label.red', action: [:fill, 'post_data_field_131', 'something'])
      test_unset_css('#post_data_field_132_input label.red', action: [:fill, 'post_data_field_132', 'something'])
      test_set_css('#post_data_field_141_input label.red', action: [:fill, 'post_data_field_141', 'something'])
      test_set_css('#post_data_field_142_input label.red', action: [:fill, 'post_data_field_142', 'something'])
      test_set_css('#post_data_field_151_input label.red', one_way: true, action: [:click, '#post_data_field_151'])
      action = [:fill, 'post_data_field_152', 'something']
      test_set_css('#post_data_field_152_input label.red', one_way: true, action: action)
      action = [:fill, 'post_data_field_153', 'something']
      test_set_css('#post_data_field_153_input label.red', one_way: true, action: action)

      # --- eq
      spec_message('check data-eq condition')
      test_set_css('#post_data_field_161_input label.red', action: [:fill, 'post_data_field_161', '161'])
      test_set_css('#post_data_field_162_input label.red', action: [:select, 'post_data_field_162', '162'])
      test_set_css('#post_data_field_163_input label.red', action: [:fill, 'post_data_field_163', '163'])
      test_unset_css('#post_data_field_164_input label.red', action: [:fill, 'post_data_field_164', '164'])

      # --- not
      spec_message('check data-not condition')
      test_unset_css('#post_data_field_171_input label.red', action: [:fill, 'post_data_field_171', '171'])
      test_unset_css('#post_data_field_172_input label.red', action: [:select, 'post_data_field_172', '172'])
      test_unset_css('#post_data_field_173_input label.red', action: [:fill, 'post_data_field_173', '173'])

      # --- match
      spec_message('check data-match condition')
      test_set_css('#post_data_field_181_input label.red', action: [:fill, 'post_data_field_181', ' Something new ...'])

      # --- mismatch
      spec_message('check data-mismatch condition')
      test_unset_css('#post_data_field_191_input label.red', action: [:fill, 'post_data_field_191', '1234'])

      # --- function
      spec_message('check data-function condition')
      test_set_css('#post_data_field_201_input label.red', action: [:fill, 'post_data_field_201', 'test'])
      expect(page).to have_css('#post_data_field_202[data-df-errors="custom function not found"]')
      test_unset_css('#post_data_field_203.red', action: [:click, '#post_data_field_203'])

      # --- addClass
      spec_message('check data-then="addClass ..." action')
      test_set_css('#post_data_field_211_input label.red', action: [:click, '#post_data_field_211'])

      # --- callback
      spec_message('check data-then="callback ..." action')
      test_set_css('body.test_callback_arg', one_way: true, action: [:click, '#post_data_field_221'])
      find('#post_data_field_222').click
      expect(page).to have_css('#post_data_field_222[data-df-errors="callback function not found"]')

      # --- setValue
      spec_message('check data-then="setValue ..." action')
      expect(find('#post_data_test').value).to be_empty
      find('#post_data_field_231').click
      expect(find('#post_data_test').value).to eq 'data test'

      # --- hide
      spec_message('check data-then="hide" action')
      target = '#post_data_field_241_input .inline-hints'
      test_change_css(target, { attrs1: { visible: :visible }, attrs2: { visible: :hidden }, action: [:click, '#post_data_field_241'] })

      # --- fade
      spec_message('check data-then="fade" action')
      target = '#post_data_field_251_input .inline-hints'
      test_change_css(target, { attrs1: { visible: :visible }, attrs2: { visible: :hidden }, action: [:click, '#post_data_field_251'] })

      # --- slide
      spec_message('check data-then="slide" action')
      target = '#post_data_field_261_input .inline-hints'
      test_change_css(target, { attrs1: { visible: :visible }, attrs2: { visible: :hidden }, action: [:click, '#post_data_field_261'] })

      # --- setText
      spec_message('check data-then="setText ..." action')
      expect(find('#post_data_field_271_input .inline-hints').text).not_to eq 'data test'
      find('#post_data_field_271').click
      expect(page).to have_css('#post_data_field_271_input .inline-hints', text: 'data test')

      # --- addStyle
      spec_message('check data-then="addStyle ..." action')
      style1 = { style: { 'margin-right': '20px' } }
      style2 = { style: 'margin-right: 20px; font-size: 10px; padding: 3px' }
      test_change_css('#post_data_field_281', { attrs1: style1, attrs2: style2, action: [:click, '#post_data_field_281'] })

      # --- gtarget
      spec_message('check data-gtarget="..."')
      test_set_css('body.active_admin.red', action: [:click, '#post_data_field_301'])
      find('#post_data_field_302').click # checks that using simply "target" will not work
      expect(page).not_to have_css('body.active_admin.red')

      # --- else
      spec_message('check data-else="..."')
      expect(page).not_to have_css('#post_data_field_321_input label.red')
      expect(page).to have_css('#post_data_field_321_input label.green')
      find('#post_data_field_321').click
      expect(page).to have_css('#post_data_field_321_input label.red')
      expect(page).not_to have_css('#post_data_field_321_input label.green')
    end
  end

  context 'with some dynamic fields on a nested resource' do
    it 'checks the conditions and actions', :aggregate_failures do
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
