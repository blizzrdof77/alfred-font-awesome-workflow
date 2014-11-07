# encoding: utf-8

require File.expand_path('spec_helper', File.dirname(__FILE__))

describe FontAwesome do
  FREEZE_TIME = Time.now

  it 'does not cause an error' do
    actual = require('bundle/bundler/setup')
    expect(actual).to be false
  end

  describe '.argv' do
    it "returns the OpenStruct object for ARGV" do
      ARGV = ['adjust|||f042']
      actual = described_class.argv(ARGV)
      expect(actual.icon_id).to eq('adjust')
      expect(actual.icon_unicode).to eq('f042')
    end
  end

  describe '.css_class_name' do
    it 'returns the CSS class name' do
      actual = described_class.css_class_name('adjust')
      expect(actual).to eq('fa-adjust')
    end
  end

  describe '.to_character_reference' do
    it 'returns the character reference' do
      actual = described_class.to_character_reference('f000')
      expect(actual).to eq('')

      actual = described_class.to_character_reference('f17b')
      expect(actual).to eq('')
    end

    it 'does not returns the character reference' do
      actual = described_class.to_character_reference('f001')
      expect(actual).not_to eq('')
    end
  end

  describe '.url' do
    it 'returns the Font Awesome URL' do
      actual = described_class.url('adjust')
      expect(actual).to eq('http://fontawesome.io/icon/adjust/')
    end
  end

  describe '#icons' do
    let(:icons) { described_class.new.icons }

    it 'returns 549' do
      expect(icons.size).to eq(549)
    end

    it 'returns "adjust"' do
      expect(icons.first.id).to eq('adjust')
    end

    it 'returns "youtube-square"' do
      expect(icons.last.id).to eq('youtube-square')
    end

    it 'includes these icons' do
      icon_ids = icons.map { |icon| icon.id }
      Fixtures.icon_ids.each { |icon| expect(icon_ids).to be_include(icon) }
    end

    it 'includes these icons (reverse)' do
      icons.each { |icon| expect(Fixtures.icon_ids).to be_include(icon.id) }
    end

    it 'does not include these icons' do
      expectation = %w(icon awesome)
      expectation.each { |icon| expect(icons).not_to be_include(icon) }
    end
  end

  describe '#select!' do
    context 'with "hdd"' do
      let(:icons) { described_class.new.select!(%w(hdd)) }

      it 'returns 1' do
        expect(icons.size).to eq(1)
      end

      it 'must equal icon name' do
        icon_ids = icons.map { |icon| icon.id }
        expect(icon_ids).to eq(%w(hdd-o))
      end
    end

    context 'with "left arr"' do
      let(:icons) { described_class.new.select!(%w(left arr)) }

      it 'returns 4' do
        expect(icons.size).to eq(4)
      end

      it 'must equal icon names' do
        icon_ids = icons.map { |icon| icon.id }
        expectation = %w(
          arrow-circle-left
          arrow-circle-o-left
          arrow-left long-arrow-left
        )
        expect(icon_ids).to eq(expectation)
      end
    end

    context 'with "arr left" (reverse)' do
      let(:icons) { described_class.new.select!(%w(arr left)) }

      it 'returns 4' do
        expect(icons.size).to eq(4)
      end

      it 'must equal icon names' do
        icon_ids = icons.map { |icon| icon.id }
        expectation = %w(
          arrow-circle-left
          arrow-circle-o-left
          arrow-left long-arrow-left
        )
        expect(icon_ids).to eq(expectation)
      end
    end

    context 'with "icons" (does not match)' do
      let(:icons) { described_class.new.select!(%w(icons)) }

      it 'returns an empty array' do
        expect(icons).to eq([])
      end
    end

    context 'with unknown arguments' do
      let(:icons) { described_class.new.select!([]) }

      it 'returns 549' do
        expect(icons.size).to eq(549)
      end

      it 'must equal icon names' do
        icon_ids = icons.map { |icon| icon.id }
        expect(icon_ids).to eq(Fixtures.icon_ids)
      end
    end

    context 'with "taxi"' do  # for ver.4.1.0
      let(:icons) { described_class.new.select!(%w(taxi)) }

      it 'must equal icon name' do
        icon_ids = icons.map { |icon| icon.id }
        expect(icon_ids).to eq(%w(taxi))
      end
    end

    context 'with "angellist"' do  # for ver.4.2.0
      let(:icons) { described_class.new.select!(%w(angellist)) }

      it 'must equal icon name' do
        icon_ids = icons.map { |icon| icon.id }
        expect(icon_ids).to eq(%w(angellist))
      end
    end
  end

  describe '#item_hash' do
    let(:item_hash) do
      icon = described_class::Icon.new('apple')
      described_class.new.item_hash(icon)
    end

    it 'returns 6' do
      expect(item_hash.size).to eq(6)
    end

    it 'must equal hash values' do
      expect(item_hash[:uid]).to eq('apple')
      expect(item_hash[:title]).to eq('apple')
      expect(item_hash[:subtitle]).to eq('Paste class name: fa-apple')
      expect(item_hash[:arg]).to eq('apple|||f179')
      expect(item_hash[:icon][:type]).to eq('default')
      expect(item_hash[:icon][:name]).to eq('./icons/fa-apple.png')
      expect(item_hash[:valid]).to eq('yes')
    end
  end

  describe '#item_xml' do
    let(:item_xml) do
      icon = described_class::Icon.new('apple')
      item_hash = described_class.new.item_hash(icon)
      described_class.new.item_xml(item_hash)
    end

    it 'returns the XML' do
      Timecop.freeze(FREEZE_TIME) do
        expectation = <<-XML
<item arg="apple|||f179" uid="#{Time.now.to_i}-apple">
<title>apple</title>
<subtitle>Paste class name: fa-apple</subtitle>
<icon>./icons/fa-apple.png</icon>
</item>
        XML
        expect(item_xml).to eq(expectation)
      end
    end
  end

  describe '#to_alfred' do
    let(:doc) do
      queries = ['bookmark']
      xml = described_class.new(queries).to_alfred
      REXML::Document.new(xml)
      # TODO: mute puts
    end

    it 'returns 2' do
      expect(doc.elements['items'].elements.size).to eq(2)
    end

    it 'must equal XML elements' do
      expect(doc.elements['items/item[1]'].attributes['arg']).to \
        eq('bookmark|||f02e')
      expect(doc.elements['items/item[1]/title'].text).to eq('bookmark')
      expect(doc.elements['items/item[1]/icon'].text).to \
        eq('./icons/fa-bookmark.png')
      expect(doc.elements['items/item[2]'].attributes['arg']).to \
        eq('bookmark-o|||f097')
      expect(doc.elements['items/item[2]/title'].text).to eq('bookmark-o')
      expect(doc.elements['items/item[2]/icon'].text).to \
        eq('./icons/fa-bookmark-o.png')
    end

    it 'must equal $stdout (test for puts)' do
      Timecop.freeze(FREEZE_TIME) do
        expectation = <<-XML
<?xml version='1.0'?><items><item arg="bookmark|||f02e" uid="#{Time.now.to_i}-bookmark"><title>bookmark</title><subtitle>Paste class name: fa-bookmark</subtitle><icon>./icons/fa-bookmark.png</icon></item><item arg="bookmark-o|||f097" uid="#{Time.now.to_i}-bookmark-o"><title>bookmark-o</title><subtitle>Paste class name: fa-bookmark-o</subtitle><icon>./icons/fa-bookmark-o.png</icon></item></items>
        XML

        actual = capture(:stdout) { described_class.new(['bookmark']).to_alfred }
        expect(actual).to eq(expectation)
      end
    end
  end

  describe '::Icon' do
    describe '#initialize' do
      context 'star-half-o (#detect_unicode_from_id)' do
        let(:icon) { described_class::Icon.new('star-half-o') }

        it 'returns "star-half-o"' do
          expect(icon.id).to eq('star-half-o')
        end

        it 'returns "f123"' do
          expect(icon.unicode).to eq('f123')
        end
      end

      context 'star-half-empty (#detect_unicode_from_aliases)' do
        let(:icon) { described_class::Icon.new('star-half-empty') }

        it 'returns "star-half-o"' do
          expect(icon.id).to eq('star-half-empty')
        end

        it 'returns "f123"' do
          expect(icon.unicode).to eq('f123')
        end
      end

      it 'includes these icons' do
        Fixtures.icon_ids.each do |id|
          icon = described_class::Icon.new(id)
          expect(icon.id).to eq(id)
          expect(icon.unicode).not_to be_nil
        end
      end
    end
  end
end
